//
//  CameraViewController.swift
//  iLyfe
//
//  Created by Sugianto on 2/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit
import Photos
import Fritz
import Speech

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var pose: Pose?
    var userKeypoints: [Keypoint]?
    
    // For pose estimation
    var previewView: UIImageView!
    lazy var poseModel = FritzVisionPoseModel()
    lazy var poseSmoother = PoseSmoother<OneEuroPointFilter>()
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        
        guard let frontCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front),
        let input = try? AVCaptureDeviceInput(device: frontCamera)
        else { return session }
        session.addInput(input)
        
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        return session
    }()
    
    // For human speech
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    // For AI speech
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // For get the time user do yoga
    var timer: Timer?
    var time = 0
    
    // PRESENT PURPOSE 1 of 3
    var timerForPresentation: Timer?
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCameraView()
        requestSpeechAuthorization()
        recordAndRecognizeSpeech()
        
        setTimer()
    }
    
    // View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        // Store time user do yoga in db
        timer?.invalidate()
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
        DataManagerSugi.storeTimeYoga(userId, time, pose!.difficulty)
        // Stop camera tracking
        captureSession.stopRunning()
        // Stop audio listening
        audioEngine.stop()
        // PRESENT PURPOSE 2 of 3
        timerForPresentation!.invalidate()
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.time = self.time + 1
        }
    }
    
    // Navigation bar setup icon
    func setupNavigationBar() {
        // Navigation title
        navigationItem.title = pose?.name
        
        let audioButton = UIBarButtonItem(
            image: UIImage(named: "audio"),
            style: .plain,
            target: self,
            action: #selector(audioButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = audioButton

        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // Setting up camera
    func setupCameraView() {
        // Add preview View as a subview
        previewView = UIImageView(frame: view.bounds)
        previewView.contentMode = .scaleAspectFill
        view.addSubview(previewView)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    // View will layout subviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewView.frame = view.bounds
    }
    
    func displayInputImage(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = UIImage(pixelBuffer: pixelBuffer)
        
        DispatchQueue.main.async {
            self.previewView.image = image
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Flip the video output
        DispatchQueue.main.async {
            connection.isVideoMirrored = true
        }
        
        let fritzImage = FritzVisionImage(buffer: sampleBuffer)
        
        let options = FritzVisionPoseModelOptions()
        options.minPoseThreshold = 0.1
        
        guard let result = try? poseModel.predict(fritzImage, options: options) else {
            // If there was no pose, display original image
            displayInputImage(sampleBuffer)
            return
        }
        
        guard let pose = result.decodePose() else {
            displayInputImage(sampleBuffer)
            return
        }
        
        guard let poseResult = result.drawPose(pose) else {
            displayInputImage(sampleBuffer)
            return
        }

        DispatchQueue.main.async {
            self.previewView.image = poseResult
        }
        
        // Set pose keypoints detail from camera into var "keypoints"
        userKeypoints = pose.keypoints
        
    }
    
    
    // Check for authorization
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("User authorized to speech recognition")
                case .denied:
                    print("User denied access to speech recognition")
                    
                    // Alert title and text
                    let alertController = UIAlertController(title: "Allow Speech Recognition?", message: "iLyfe needs access to your speech recognition to do pose checking.", preferredStyle: .alert)
                    
                    // Go to settings action
                    let settingAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                        let settingUrl = NSURL(string: UIApplication.openSettingsURLString)
                        if let url = settingUrl {
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        }
                    })
                    
                    // Cancel action
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    
                    // Add action to alert
                    alertController.addAction(settingAction)
                    alertController.addAction(cancelAction)
                    
                    // Show alert
                    self.present(alertController, animated: true, completion: nil);

                case .restricted:
                    print("Speech recognition restricted to this device")
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                @unknown default:
                    break
                }
            }
        }
    }
    
    // Start speech recognizer
    func recordAndRecognizeSpeech() {
        let node: AVAudioNode = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            buffer, _ in self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // A recognizer is not available right now
            return
        }
        
        // PRESENT PURPOSE 3 of 3
        timerForPresentation = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { (timer) in
            self.checkPose()
        }
        // PRESENT PURPOSE END
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    // Get the latest string said
                    lastString = String(bestString[indexTo...])
                }
                self.checkWordSaid(word: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    // Check if "capture" is said
    func checkWordSaid(word: String) {
        // Run checkPose to check for pose when user say the word "capture"
        if (word.lowercased() == "capture") {
            print("CAPTURE SAID")
            checkPose()
        }
    }
    
    // Check pose
    func checkPose() {
        
        // Voice for feedback
        var speechUtterance = AVSpeechUtterance(string: "")
        
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance.volume = 1
        
        // If cannot detect user pose, exit function
        if (userKeypoints == nil) {
            speechUtterance = AVSpeechUtterance(string: "No pose detected")
            speechSynthesizer.speak(speechUtterance)
            return
        }
        
        // Data (Default)           Data (Inverted due to Flipped video)
        // 0: Nose                  0: Nose
        // 1: Left Eye              1: Right Eye
        // 2: Right Eye             2: Left Eye
        // 3: Left Ear              3: Right Ear
        // 4: Right Ear             4: Left Ear
        // 5: Left Shoulder         5: Right Shoulder
        // 6: Right Shoulder        6: Left Shoulder
        // 7: Left Elbow            7: Right Elbow
        // 8: Right Elbow           8: Left Elbow
        // 9: Left Wrist            9: Right Wrist
        // 10: Right Wrist          10: Left Wrist
        // 11: Left Hip             11: Right Hip
        // 12: Right Hip            12: Left Hip
        // 13: Left Knee            13: Right Knee
        // 14: Right Knee           14: Left Knee
        // 15: Left Ankle           15: Right Ankle
        // 16: Right Ankle          16: Left Ankle
        
        // Point score
        var pointScore = 0
        
        // Data body length
        let dataShoulderHipX = abs((pose?.keypoints[5][0])! - (pose?.keypoints[11][0])!)
        let dataShoulderHipY = abs((pose?.keypoints[5][1])! - (pose?.keypoints[11][1])!)
        let dataShoulderElbowX = abs((pose?.keypoints[5][0])! - (pose?.keypoints[7][0])!)
        let dataShoulderElbowY = abs((pose?.keypoints[5][1])! - (pose?.keypoints[7][1])!)
        let dataElbowWristX = abs((pose?.keypoints[7][0])! - (pose?.keypoints[9][0])!)
        let dataElbowWristY = abs((pose?.keypoints[7][1])! - (pose?.keypoints[9][1])!)
        let dataHipKneeX = abs((pose?.keypoints[11][0])! - (pose?.keypoints[13][0])!)
        let dataHipKneeY = abs((pose?.keypoints[11][1])! - (pose?.keypoints[13][1])!)
        let dataKneeAnkleX = abs((pose?.keypoints[13][0])! - (pose?.keypoints[15][0])!)
        let dataKneeAnkleY = abs((pose?.keypoints[13][1])! - (pose?.keypoints[15][1])!)
        
        // User body length
        var userShoulderHipX = 0.0
        var userShoulderHipY = 0.0
        var userShoulderElbowX = 0.0
        var userShoulderElbowY = 0.0
        var userElbowWristX = 0.0
        var userElbowWristY = 0.0
        var userHipKneeX = 0.0
        var userHipKneeY = 0.0
        var userKneeAnkleX = 0.0
        var userKneeAnkleY = 0.0
        
        // Average diff of body length (will use this to determine the diff of user's body size and the data in database)
        // Data length / User length
        var lengthDiff = 0.0
        
        if (pose?.keypoints[0][0] == 0 && pose?.keypoints[0][1] == 0) {
            // When pose only requires one side of the body points
            print("ONE SIDE")
            
            if (userKeypoints![5].score >= 0.1 && userKeypoints![11].score >= 0.1) {
                // RIGHT body points is shown and used to check
                print("RIGHT")
                
                userShoulderHipX = abs(userKeypoints![5].position.x - userKeypoints![11].position.x)
                userShoulderHipY = abs(userKeypoints![5].position.y - userKeypoints![11].position.y)
                userShoulderElbowX = abs(userKeypoints![5].position.x - userKeypoints![7].position.x)
                userShoulderElbowY = abs(userKeypoints![5].position.y - userKeypoints![7].position.y)
                userElbowWristX = abs(userKeypoints![7].position.x - userKeypoints![9].position.x)
                userElbowWristY = abs(userKeypoints![7].position.y - userKeypoints![9].position.y)
                userHipKneeX = abs(userKeypoints![11].position.x - userKeypoints![13].position.x)
                userHipKneeY = abs(userKeypoints![11].position.y - userKeypoints![13].position.y)
                userKneeAnkleX = abs(userKeypoints![13].position.x - userKeypoints![15].position.x)
                userKneeAnkleY = abs(userKeypoints![13].position.y - userKeypoints![15].position.y)
                
                // Phytagoras Theorem
                lengthDiff = sqrt(pow(abs(dataShoulderHipX), 2) + pow(abs(dataShoulderHipY), 2))
                    / sqrt(pow(abs(userShoulderHipX), 2) + pow(abs(userShoulderHipY), 2))
                
            } else {
                // LEFT body points is shown and used to check
                print("LEFT")
                
                userShoulderHipX = abs(userKeypoints![6].position.x - userKeypoints![12].position.x)
                userShoulderHipY = abs(userKeypoints![6].position.y - userKeypoints![12].position.y)
                userShoulderElbowX = abs(userKeypoints![6].position.x - userKeypoints![8].position.x)
                userShoulderElbowY = abs(userKeypoints![6].position.y - userKeypoints![8].position.y)
                userElbowWristX = abs(userKeypoints![8].position.x - userKeypoints![10].position.x)
                userElbowWristY = abs(userKeypoints![8].position.y - userKeypoints![10].position.y)
                userHipKneeX = abs(userKeypoints![12].position.x - userKeypoints![14].position.x)
                userHipKneeY = abs(userKeypoints![12].position.y - userKeypoints![14].position.y)
                userKneeAnkleX = abs(userKeypoints![14].position.x - userKeypoints![16].position.x)
                userKneeAnkleY = abs(userKeypoints![14].position.y - userKeypoints![16].position.y)
                
                // Phytagoras Theorem
                lengthDiff = sqrt(pow(abs(dataShoulderHipX), 2) + pow(abs(dataShoulderHipY), 2))
                    / sqrt(pow(abs(userShoulderHipX), 2) + pow(abs(userShoulderHipY), 2))
                
            }
            
            // START CHECKING
            if ((dataShoulderHipX >= (userShoulderHipX * lengthDiff) - 20 && dataShoulderHipX <= (userShoulderHipX * lengthDiff) + 20) &&
                (dataShoulderHipY >= (userShoulderHipY * lengthDiff) - 20 && dataShoulderHipY <= (userShoulderHipY * lengthDiff) + 20)) {
                pointScore = pointScore + 1
            }
            if ((dataShoulderElbowX >= (userShoulderElbowX * lengthDiff) - 20 && dataShoulderElbowX <= (userShoulderElbowX * lengthDiff) + 20) &&
                (dataShoulderElbowY >= (userShoulderElbowY * lengthDiff) - 20 && dataShoulderElbowY <= (userShoulderElbowY * lengthDiff) + 20)) {
                pointScore = pointScore + 1
            }
            if ((dataElbowWristX >= (userElbowWristX * lengthDiff) - 20 && dataElbowWristX <= (userElbowWristX * lengthDiff) + 20) &&
                (dataElbowWristY >= (userElbowWristY * lengthDiff) - 20 && dataElbowWristY <= (userElbowWristY * lengthDiff) + 20)) {
                pointScore = pointScore + 1
            }
            if ((dataHipKneeX >= (userHipKneeX * lengthDiff) - 20 && dataHipKneeX <= (userHipKneeX * lengthDiff) + 20) &&
                (dataHipKneeY >= (userHipKneeY * lengthDiff) - 20 && dataHipKneeY <= (userHipKneeY * lengthDiff) + 20)) {
                pointScore = pointScore + 1
            }
            if ((dataKneeAnkleX >= (userKneeAnkleX * lengthDiff) - 20 && dataKneeAnkleX <= (userKneeAnkleX * lengthDiff) + 20) &&
                (dataKneeAnkleY >= (userKneeAnkleY * lengthDiff) - 20 && dataKneeAnkleY <= (userKneeAnkleY * lengthDiff) + 20)) {
                pointScore = pointScore + 1
            }
            
//            print(dataShoulderHipX)
//            print(dataShoulderHipY)
//            print(dataShoulderElbowX)
//            print(dataShoulderElbowY)
//            print(dataElbowWristX)
//            print(dataElbowWristY)
//            print(dataHipKneeX)
//            print(dataHipKneeY)
//            print(dataKneeAnkleX)
//            print(dataKneeAnkleY)
//
//            print("^TOP DATA vBOTTOM USER")
//
//            print(userShoulderHipX)
//            print(userShoulderHipY)
//            print(userShoulderElbowX)
//            print(userShoulderElbowY)
//            print(userElbowWristX)
//            print(userElbowWristY)
//            print(userHipKneeX)
//            print(userHipKneeY)
//            print(userKneeAnkleX)
//            print(userKneeAnkleY)
            
            // WILL DELETE
            // Set achievement in db
            // DataManagerSugi.achievementGet(pose!.imageName, UserDefaults.standard.string(forKey: "userAutoId")!)
            
            // Setup the feedback circle
            let circleView = UIView(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: 50, width: 50, height: 50))
            let shapeLayer = CAShapeLayer()
            let pulsatingLayer = CAShapeLayer()
            
            let circularPath = UIBezierPath(arcCenter: .zero, radius: 30, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            var pulseColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            // Set hollow circle
            shapeLayer.path = circularPath.cgPath
            shapeLayer.lineWidth = 5
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.position = CGPoint(x: 0, y: 100)
            
            // Set pulsing circle
            pulsatingLayer.path = circularPath.cgPath
            pulsatingLayer.lineWidth = 5
            pulsatingLayer.fillColor = UIColor.clear.cgColor
            pulsatingLayer.position = CGPoint(x: 0, y: 100)
            
            circleView.alpha = 0.0
            
            circleView.layer.addSublayer(pulsatingLayer)
            circleView.layer.addSublayer(shapeLayer)
            
            view.addSubview(circleView)
            
            // Animate pulsing circle
            let animation = CABasicAnimation(keyPath: "transform.scale")
            
            animation.toValue = 1.1
            animation.duration = 0.8
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.autoreverses = true
            animation.repeatCount = Float.infinity
            
            pulsatingLayer.add(animation, forKey: "pulsing")

            
            // Fade in + move to position
            UIView.animate(withDuration: 0.5) {
                circleView.alpha = 1.0
                circleView.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: 20, width: 50, height: 50)
            }
            
            // After 3 seconds
            _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
                // Fade away
                UIView.animate(withDuration: 0.5) {
                    circleView.alpha = 0.0
                }
            })
            
            print(pointScore)
            
            // Point scores
            switch pointScore {
            case 0...1:
                speechUtterance = AVSpeechUtterance(string: "Bad")
                
                // Color of circle
                pulseColor = #colorLiteral(red: 1, green: 0, blue: 0.4901960784, alpha: 1)
                shapeLayer.strokeColor = UIColor.red.cgColor
                pulsatingLayer.strokeColor = pulseColor.cgColor
                
            case 2...3:
                speechUtterance = AVSpeechUtterance(string: "Good")
                
                // Color of circle
                pulseColor = #colorLiteral(red: 1, green: 1, blue: 0.4901960784, alpha: 1)
                shapeLayer.strokeColor = UIColor.yellow.cgColor
                pulsatingLayer.strokeColor = pulseColor.cgColor
            case 4:
                speechUtterance = AVSpeechUtterance(string: "Great")
                
                // Color of circle
                pulseColor = #colorLiteral(red: 0, green: 0.4901960784, blue: 1, alpha: 1)
                shapeLayer.strokeColor = UIColor.blue.cgColor
                pulsatingLayer.strokeColor = pulseColor.cgColor
            case 5:
                speechUtterance = AVSpeechUtterance(string: "Perfect")
                
                // Color of circle
                pulseColor = #colorLiteral(red: 0.4901960784, green: 1, blue: 0, alpha: 1)
                shapeLayer.strokeColor = UIColor.green.cgColor
                pulsatingLayer.strokeColor = pulseColor.cgColor
                
                // Add image into circleView
                let myImage = CALayer()
                if (pose!.imageName.contains("Achievement")) {
                    myImage.contents = UIImage(named: pose!.imageName)?.cgImage
                } else {
                    myImage.contents = UIImage(named: pose!.imageName + "Achievement")?.cgImage
                }
                myImage.frame = CGRect(x: -30, y: -30, width: 60, height: 60)
                let imageLayer = CAShapeLayer()
                imageLayer.position = CGPoint(x: 0, y: 100)
                imageLayer.addSublayer(myImage)
                
                circleView.layer.addSublayer(imageLayer)
                
                // Set achievement in db
                DataManagerSugi.achievementGet(pose!.imageName, pose!.difficulty, UserDefaults.standard.string(forKey: "userAutoId")!)
                
            default: break
            }
            
            if (self.navigationItem.rightBarButtonItem!.action! == #selector(self.audioButtonPressed(sender:))) {
                speechSynthesizer.speak(speechUtterance)
            }
            
            
        } else {
            // When pose require the whole body points
            print("BOTH SIDE")
            
        }
        
    }
    
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        _ = navigationController?.popViewController(animated: true)
    }
    
    // When "audio" icon is pressed
    @objc func audioButtonPressed(sender: UIBarButtonItem) {
        let noAudioButton = UIBarButtonItem(
            image: UIImage(named: "noAudio"),
            style: .plain,
            target: self,
            action: #selector(noAudioButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = noAudioButton
    }
    
    // When "noAudio" icon is pressed
    @objc func noAudioButtonPressed(sender: UIBarButtonItem) {
        let audioButton = UIBarButtonItem(
            image: UIImage(named: "audio"),
            style: .plain,
            target: self,
            action: #selector(audioButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = audioButton
    }
    
}
