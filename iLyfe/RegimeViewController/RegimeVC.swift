//
//  RegimeVC.swift
//  iLyfe - Smart Trainer
//
//  Created by ITP312 on 2/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import CoreMotion
import CoreML
import Speech
import FirebaseDatabase

class RegimeVC: UIViewController {
    
    @IBOutlet weak var startTimerBtn: UIButton!
    @IBOutlet weak var pauseTimerBtn: UIButton!
    @IBOutlet weak var nextExerciseBtn: UIButton!
    @IBOutlet weak var Reps: UILabel!
    @IBOutlet weak var CountdownLabel: UILabel!
    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var CaloriesLabel: UILabel!
    // Regime variables
    var bodyParts : [String] = []
    var exerciseArray: [[String]] = []
    var mode = 0
    var exerciseIndex = 0
    var bodyPartIndex = 0
    var currentExercise: String = ""
    var currentBodyPart: String = ""
    var exDefaultReps: Int = 0
    var repsArr1: [Int] = []
    var repsArr2: [[Int]] = []
    
    //Calories Variables
    var caloriesPerRep: Int = 0
    var caloriesArr: [Int] = []
    var caloriesArr2: [[Int]] = []
    var caloriesBurnt: Int = 0
    var totalCaloriesBurnt: Int = 0
    
    // Duration Variables
    var timeTakenArr: [Int] = []
    var timeTakenArr2: [[Int]] = []
    
    // Timer variables
    var duration = 60
    lazy var seconds = duration
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    // Speech Synthesizer
    var speechSynthesizer = AVSpeechSynthesizer()
    
    // AC Variables
    struct ModelConstants {
        static let numOfFeatures = 6
        static let predictionWindowSize = 50
        static let sensorsUpdateInterval = 1.0 / 50.0
        static let hiddenInLength = 200
        static let hiddenCellInLength = 200
    }
    // let activityClassificationModel = MyActivityClassifier()
    
    var currentIndexInPredictionWindow = 0
    let predictionWindowDataArray = try? MLMultiArray(shape: [1 , ModelConstants.predictionWindowSize , ModelConstants.numOfFeatures] as [NSNumber], dataType: MLMultiArrayDataType.double)
    var lastHiddenOutput = try? MLMultiArray(shape:[ModelConstants.hiddenInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    var lastHiddenCellOutput = try? MLMultiArray(shape:[ModelConstants.hiddenCellInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    
    // Exercise Counts
    var current = 0
    var target = 30
    
    // Call runTimer()
    @IBAction func StartTimerBtn(_ sender: UIButton) {
        if isTimerRunning == false{
            runTimer()
            startTimerBtn.isEnabled = false
            nextExerciseBtn.isHidden = false
            pauseTimerBtn.isHidden = false
        }
    }
    // Toggle Pause
    @IBAction func PauseTimerBtn(_ sender: UIButton) {
        // Stop Timer
        if self.resumeTapped == false{
            timer.invalidate()
            isTimerRunning = false
            self.resumeTapped = true
            pauseTimerBtn.isSelected = true
        // Resume Timer
        }else{
            runTimer()
            isTimerRunning = true
            self.resumeTapped = false
            pauseTimerBtn.isSelected = false
        }
    }
    
    // Format seconds to a String, (Min : Sec).
    func timeString(time: TimeInterval) -> String {
        let min = Int(time) / 60 % 60
        let sec = Int(time) % 60
        return String(format: "%02i:%02i", min, sec)
    }
    
    // Start Timer
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RegimeVC.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    // Update Timer
    @objc func updateTimer() {
        // Update Countdown Label
        if seconds > 0 {
            seconds -= 1
            CountdownLabel.text = timeString(time: TimeInterval(seconds))
        // End Timer Countdown
        }else{
            print("Time is up!")
            timer.invalidate()
            isTimerRunning = false
        }
    }
    // VIEW DID LOAD
    //
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseTimerBtn.isHidden = true
        CountdownLabel.text = timeString(time: TimeInterval(seconds))
        print(bodyParts)
        print(exerciseArray)
        nextExerciseBtn.isHidden = true
        currentExercise = exerciseArray[bodyPartIndex][exerciseIndex]
        self.navigationItem.title = currentExercise
        exerciseImage.image = UIImage(named: currentExercise)
        getCurrentExerciseInfo(exIndex: exerciseIndex, bpIndex: bodyPartIndex)
        exerciseIndex = exerciseIndex - 1
    }
    
    func getCurrentExerciseInfo (exIndex:Int, bpIndex:Int) {
        var exerciseRef = Database.database().reference()
    exerciseRef.child("Exercises").child(bodyParts[bpIndex]).child(exerciseArray[bpIndex][exIndex]).observeSingleEvent(of: .value, with: {
        (snapshot) in
        // print(snapshot.childSnapshot(forPath: "exDefaultReps").value as! Int)
        self.mode = self.mode + 1
        self.exDefaultReps = snapshot.childSnapshot(forPath: "exDefaultReps").value as! Int
        self.caloriesPerRep = snapshot.childSnapshot(forPath: "caloriesPerRep").value as! Int
        print(self.caloriesPerRep)
        self.Reps.text = "\(self.current)/\(self.exDefaultReps)"
        self.Reps.reloadInputViews()
        })
        
        if exIndex == 0{
            exerciseIndex = exerciseIndex + 1
        }else{
            exerciseIndex = exerciseIndex - 1
            bodyPartIndex = bodyPartIndex + 1
        }
    }
    
    func appendRep(){
        repsArr1.append(current)
        if repsArr1.count == 2{
            repsArr2.append(repsArr1)
            repsArr1 = []
        }
        
    }
    
    func appendCalories(){
        caloriesArr.append(caloriesBurnt)
        if caloriesArr.count==2{
            caloriesArr2.append(caloriesArr)
            caloriesArr = []
        }
    }
    
    @IBAction func nextExerciseBtnPressed(_ sender: Any) {
        // Get time taken
        var timeTaken = 0
        timeTaken = duration - seconds
        timeTakenArr.append(timeTaken)
        if timeTakenArr.count == 2{
            timeTakenArr2.append(timeTakenArr)
            timeTakenArr = []
        }
        
        if mode < bodyParts.count*2{
            appendRep()
            appendCalories()
            print(caloriesArr)
            
            // Call getCurrentExerciseInfo()
            getCurrentExerciseInfo(exIndex: exerciseIndex, bpIndex: bodyPartIndex)
            
            // Reset Rep & Calorie Value
            current = 0
            caloriesBurnt = 0
            
            // Show Buttons
            startTimerBtn.isEnabled = true
            nextExerciseBtn.isHidden = true
            pauseTimerBtn.isHidden = true
            
            // Reset Timer
            timer.invalidate()
            isTimerRunning = false
            seconds = 60
            CountdownLabel.text = timeString(time: TimeInterval(seconds))
            
            // Set exercise details
            currentExercise = exerciseArray[bodyPartIndex][exerciseIndex]
            navigationItem.title = currentExercise
            exerciseImage.image = UIImage(named: currentExercise)
            if mode == bodyParts.count*2-1{
                nextExerciseBtn.setTitle("Finish", for: .normal)
            }
            
            }else{
            appendRep()
            appendCalories()
            timer.invalidate()
            isTimerRunning = false;
            
            // Combine bodyParts array to a single string
            var bodyPartSelection = ""
            for bodyPart in bodyParts{
                // Add comma to body parts not in the last index
                if bodyParts[bodyParts.count-1] != bodyPart{
                    bodyPartSelection = bodyPartSelection + bodyPart + ", "
                }else{
                    bodyPartSelection = bodyPartSelection + bodyPart
                }
            }
            let resultAlert = UIAlertController(title: nil, message: "You have completed the regime! Give it a name.", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let confirmSelection = UIAlertAction(title: "Confirm", style: .default) {(_) ->Void in
                // Push to ViewHistoryVC
                var regimeName = "regimeName"
                let textField = resultAlert.textFields![0] as UITextField
                if textField.text != ""{
                    regimeName = textField.text!
                }else{
                    regimeName = bodyPartSelection
                }
                self.performSegue(withIdentifier: "ViewHistory", sender: self)
                // Add data to database
                let userId = UserDefaults.standard.string(forKey: "userAutoId")!
                let regimeRef = FirebaseDatabase.Database.database().reference().child("users").child(userId).child("Regimes").childByAutoId().child(regimeName)
                for bodyPart in self.bodyParts{
                    var bpIndex = self.bodyParts.index(of: bodyPart)!
                    for i in 0...1{
                        regimeRef.child("\(bodyPart)").child("\(self.exerciseArray[bpIndex][i])").child("Reps Completed").setValue(self.repsArr2[bpIndex][i])
                        regimeRef.child("\(bodyPart)").child("\(self.exerciseArray[bpIndex][i])").child("Time Taken").setValue(self.timeTakenArr2[bpIndex][i])
                        regimeRef.child("\(bodyPart)").child("\(self.exerciseArray[bpIndex][i])").child("Calories Burnt").setValue(self.caloriesArr2[bpIndex][i])
                    }
                }
            }
            
            resultAlert.addTextField { (textField) in
                textField.placeholder = "Regime Title"
            }
            resultAlert.addAction(cancel)
            resultAlert.addAction(confirmSelection)
            
            present(resultAlert, animated: true, completion: nil)
        }
    }
    
    func countRep(){
            print("Counted")
            current = self.current + 1
            self.totalCaloriesBurnt = self.totalCaloriesBurnt + self.caloriesPerRep
            self.caloriesBurnt = self.current * self.caloriesPerRep
            self.Reps.text = "\(self.current)/\(self.exDefaultReps)"
            self.CaloriesLabel.text = "Calories Burnt: \(self.totalCaloriesBurnt)"
            let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: String(self.current))
            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.speechSynthesizer.speak(speechUtterance)
    }
    
    // Motion Manager
    var motionManager = CMMotionManager()
    
    // Set to update every 0.3 seconds
    override func viewDidAppear(_ animated: Bool) {
        motionManager.accelerometerUpdateInterval = 0.75
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data{
                print(myData)
                if self.isTimerRunning{
                    if self.currentExercise == "Squats" || self.currentExercise == "Dips" {
                        if myData.acceleration.y < 0.6 && myData.acceleration.z > 0.1 {
                            self.countRep()
                        }
                    }else if self.currentExercise == "Press up with spinal rotation"{
                        if myData.acceleration.x < -0.5{
                            self.countRep()
                        }
                    }else{
                        if myData.acceleration.x > 0.2 && myData.acceleration.z > 0.2{
                            self.countRep()
                        }
                    }
                }
            }
        }
    }
        // Activity Classifier
//        //motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable else { return }
//
//        motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
//        motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
//
//        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
//            guard let accelerometerData = accelerometerData else { return }
//            // Add the current data sample to the data array
//            self.addAccelSampleToDataArray(accelSample: accelerometerData)
//        }
//    }
//
//    func addAccelSampleToDataArray (accelSample: CMAccelerometerData) {
//        // Add the current accelerometer reading to the data array
//        guard let dataArray = predictionWindowDataArray else { return }
//        dataArray[[0 , currentIndexInPredictionWindow ,0] as [NSNumber]] = accelSample.acceleration.x as NSNumber
//        dataArray[[0 , currentIndexInPredictionWindow ,1] as [NSNumber]] = accelSample.acceleration.y as NSNumber
//        dataArray[[0 , currentIndexInPredictionWindow ,2] as [NSNumber]] = accelSample.acceleration.z as NSNumber
//
//        // Update the index in the prediction window data array
//        currentIndexInPredictionWindow += 1
//
//        // If the data array is full, call the prediction method to get a new model prediction.
//        // We assume here for simplicity that the Gyro data was added to the data array as well.
//        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
//            let predictedActivity = performModelPrediction() ?? "N/A"
//
//            // Use the predicted activity here
//            // ...
//
//            // Start a new prediction window
//            currentIndexInPredictionWindow = 0
//        }
//    }
//
//    func performModelPrediction () -> String? {
//        guard let dataArray = predictionWindowDataArray else { return "Error!"}
//
//        // Perform model prediction
//        let modelPrediction = try? activityClassificationModel.prediction(features: dataArray, hiddenIn: lastHiddenOutput, cellIn: lastHiddenCellOutput)
//
//        // Update the state vectors
//        if (isTimerRunning){
//            lastHiddenOutput = modelPrediction?.hiddenOut
//            lastHiddenCellOutput = modelPrediction?.cellOut
//            print(modelPrediction?.activity)
//        }
//        if (modelPrediction?.activity == "climbing_downstairs"){
//            print("Push up")
//            self.current = self.current + 1
//            self.Reps.text = "\(self.current)/\(self.target)"
//        }
//
//        // Return the predicted activity - the activity with the highest probability
//        return modelPrediction?.activity
}
