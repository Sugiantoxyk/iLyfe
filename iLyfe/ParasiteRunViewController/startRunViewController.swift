//
//  startRunViewController.swift
//  iLyfe
//
//  Created by JT on 12/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ARKit
import SceneKit
import CoreVideo
import Vision

class startRunViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ARSCNViewDelegate, ARSessionDelegate, SCNPhysicsContactDelegate {
    
    var lm:CLLocationManager?
    
    
    @IBOutlet var arGame: UIView!
    @IBOutlet weak var ammoLbl: UILabel!
    @IBOutlet weak var arTimer: UILabel!
    @IBOutlet weak var attackBtn: UIButton!
    @IBOutlet weak var arView: ARSCNView!
    
    let speechSynthesizer = SpeechSynthesizer()
    
    var shootPnt = 0
    var paraDeath = 0
    var checkShoot = false
    @IBAction func attackPressed(_ sender: UIButton) {
        if ammoNo > 0
        {
            ammoNo -= 1
            ammoLbl.text = "\(ammoNo)"
            
            playSound()
            
            var hitTestOptions = [SCNHitTestOption: Any]()
            hitTestOptions[SCNHitTestOption.searchMode] = SCNHitTestSearchMode.all.rawValue as NSNumber
            let result = arView.hitTest(arView.center, options: hitTestOptions)
            
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = [.X, .Y, .Z]
            
            //print("paraNode child: \(paraNode.childNodes)")
            print("arview child: \(arView.scene.rootNode.childNodes)")
            if result.first != nil
            {
                for x in result
                {
                    if let xName = x.node.name
                    {
                        print("ownNode: \(xName)")
                        if xName == "ammoBox"
                        {
                            x.node.removeFromParentNode()
                            ammoNo += 10
                            ammoLbl.text = "\(ammoNo)"
                            print("removed")
                        }
                    }
                    //get the parent node of parts of the parasite which is the parasite itself
                    if x.node.parent != nil
                    {
                        let testNode = x.node.parent!
                        print("testNode name: \(testNode.name)")
                        //testNode.removeFromParentNode()
                        for child in self.arView.scene.rootNode.childNodes
                        {
                            print("nodeName: \(child.name)")
                            if let childnm = child.name
                            {
                                if childnm == testNode.name && childnm.contains("para")
                                {
                                    
                                    //child.removeFromParentNode()
                                    child.removeAllActions()
                                    child.removeAllAnimations()
                                    child.addAnimation(self.dieAnime!, forKey: "paraDie")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                        for x in child.childNodes
                                        {
                                            x.removeFromParentNode()
                                        }
                                        child.removeFromParentNode()
                                        if self.checkShoot == false
                                        {
                                            self.shootPnt += 1
                                            self.paraDeath += 1
                                            self.checkShoot = true
                                        }
                                    })
                                    break
                                }
                            }
                        }
                    }
                }
            }
            self.checkShoot = false
        }
    }
    
    var paraScene: SCNScene?
    var paraNode = SCNNode()
    var targetNode:SCNNode!
    
    var circleNode:SCNNode?
    var paraSceneAtk:SCNScene?
    var atkNode = SCNNode()
    var atkAnime:CAAnimation?
    var dieAnime:CAAnimation?
    
    var paraStruc = SCNNode()
    
    var ammoNo = 50
    var finishedRace = false
    
    
    @IBAction func resultPressed(_ sender: UIButton) {
    }
    @IBOutlet weak var checkResult: UIButton!
    @IBOutlet var finishRace: UIView!
    @IBOutlet weak var missionNo: UILabel!
    @IBOutlet var startRace: UIView!
    @IBOutlet weak var myTimer: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet var missionRes: UIView!
    @IBOutlet weak var mResLbl: UILabel!
    
    var regionID:[Int:String] = [:]
    var tryID:[Int:String] = [:]
    
    var totalDist:Double = 0
    
    var myRegion:String?
    var mode:String?
    var destArrLat:[Double] = []
    var destArrLong:[Double] = []
    var testYisLat = 0.0
    var testYisLong = 0.0
    
    var destTime:[Int] = []
    
    var sourcelocation:CLLocationCoordinate2D!
    var destlocation:CLLocationCoordinate2D!
    
    var username:String?
    var userid:String?
    
    var weight:Double?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult"
        {
            var latestResId = 0
            var pace = self.totalDist / Double(self.allTimeCount)
            var frObj:FitResult?
            
            let dest = segue.destination as! RunResults
            
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedDate = format.string(from: date)
            //print(formattedDate)
                
            dest.frObj = FitResult(formattedDate, self.userId, self.myRegion!, self.mode!, self.username!, pace, self.allTimeCount, self.totalDist, 0.0, self.paraDeath)
            dest.dist = self.totalDist
            dest.pace = pace
            dest.time = self.allTimeCount
            dest.weight = weight
            dest.prevPara = paraNum
            dest.finishedRace = self.finishedRace
        }
    }
    
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "art.scnassets/shotgun", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var userId = UserDefaults.standard.string(forKey: "userAutoId")!
    var paraNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let config = ARWorldTrackingConfiguration()
        //arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        config.planeDetection = .horizontal
        
        arView.scene.physicsWorld.contactDelegate = self
        arView.delegate = self
        arView.session.delegate = self
        arView.session.run(config)
        
        DataManagerSugi.getUserInfo(self.userId, onComplete: {
            (userInfo) in
            
            self.username = userInfo?["name"] as! String
            self.userid = userInfo?["email"] as! String
            self.weight = userInfo?["weight"] as! Double
            if let paraNo = userInfo?["TotalPara"] as? Int
            {
                self.paraNum = paraNo
            }
        })
        
        let cameraNode = self.arView!.pointOfView!
        //let target = SCNTorus(ringRadius: 0.01, pipeRadius: 0.005)
        let target = SCNTorus(ringRadius: 0.0011, pipeRadius: 0.0006)
        target.firstMaterial?.diffuse.contents = UIColor.red
        self.targetNode = SCNNode(geometry: target)
        self.targetNode.name = "targetNode"
        cameraNode.addChildNode(self.targetNode)
        self.targetNode.position = SCNVector3(0, 0, -0.1)
        self.targetNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
        
        startRace.layer.cornerRadius = 5
        
        mapView.delegate = self
        
        let url = Bundle.main.url(forResource: "SGplace", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        let json = try? JSON(data: data!)
        
        //get data from json based on the region
        for (key, value) in json!
        {
            if key == myRegion
            {
                //source coordinate
                testYisLat = json![key]["source"]["lat"].doubleValue
                testYisLong = json![key]["source"]["long"].doubleValue
                
                for x in json![key][mode!]["dest"].arrayValue
                {
                    let destCoord = x.dictionaryValue
                    var thisLat = destCoord["lat"]?.doubleValue
                    var thisLong = destCoord["long"]?.doubleValue
                    var thisTime = destCoord["time"]?.intValue
                    destArrLat.append(thisLat!)
                    destArrLong.append(thisLong!)
                    destTime.append(thisTime!)
                }
            }
        }
        
        sourcelocation = CLLocationCoordinate2D(latitude: testYisLat, longitude: testYisLong)
        destlocation = CLLocationCoordinate2D(latitude: destArrLat[destArrLat.count-1], longitude: destArrLong[destArrLong.count-1])
        
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        lm?.distanceFilter = 0
        lm?.requestAlwaysAuthorization()
        
        lm?.startUpdatingLocation()
        
        //TESTING!!!!!!(tap n find coordinates)
        let taptap = UITapGestureRecognizer()
        taptap.addTarget(self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(taptap)
        
        var point = MKPointAnnotation()
        point.title = "Start"
        point.coordinate = sourcelocation
        mapView.addAnnotation(point)
        point = MKPointAnnotation()
        point.title = "End"
        point.coordinate = destlocation
        mapView.addAnnotation(point)
        
        var sourcePlaceMark = MKPlacemark(coordinate: sourcelocation)
        var destPlaceMark:MKPlacemark?
        
        //add pins to each destination
        for i in 0..<destArrLat.count{
            if i != 0
            {
                sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destArrLat[i-1], longitude: destArrLong[i-1]))
            }
            destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destArrLat[i], longitude: destArrLong[i]))
            
            point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: destArrLat[i], longitude: destArrLong[i])
            mapView.addAnnotation(point)
            
            let directionReq = MKDirections.Request()
            directionReq.source = MKMapItem(placemark: sourcePlaceMark)
            directionReq.destination = MKMapItem(placemark: destPlaceMark!)
            directionReq.transportType = .walking
            
            let directions = MKDirections(request: directionReq)
            directions.calculate(completionHandler: {
                (response, error) in
                
                guard let directRes = response else {
                    if let error = error {
                        print("Error getting directions == \(error.localizedDescription)")
                    }
                    
                    return
                }
                //get first route
                let route = directRes.routes[0]
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                
                self.totalDist += route.distance
                
                /*let rect = route.polyline.boundingMapRect
                 self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)*/
                
            })
        }
        
        regionID[0] = "geofence"
        
        for i in 0..<destArrLat.count
        {
            let LatLong:String = String(destArrLat[i]) + String(destArrLong[i])
            regionID[i+1] = LatLong
        }
        originalCount = regionID.count
        
        
        //another
        for i in 0..<destArrLat.count
        {
            let LatLong:String = String(destArrLat[i]) + String(destArrLong[i])
            tryID[i] = LatLong
        }
    }
    
    //TESTING!!!!
    @objc func mapTapped(sender: UITapGestureRecognizer)
    {
        let touchPoint = sender.location(in: mapView)
        let touchCoord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let point = MKPointAnnotation()
        point.title = "\(touchCoord.latitude), \(touchCoord.longitude)"
        point.coordinate = touchCoord
        mapView.addAnnotation(point)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        
        var pin = self.mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if pin == nil
        {
            pin = MKPinAnnotationView()
        }
        pin?.annotation = annotation
        pin?.canShowCallout = true
        pin?.isSelected = true
        pin?.isUserInteractionEnabled = false
        return pin
    }
    
    //style overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3.0
        return renderer
    }
    
    var endRegionMon = true
    var sourceRegionMon = true
    var index = 0
    var originalCount = 0
    
    var said = false
    
    var time = 0
    var timer:Timer?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations.last
        let region = MKCoordinateRegion(
            center: location!.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        //print("lat: \(location?.coordinate.latitude), long: \(location?.coordinate.longitude)")
        mapView.setRegion(region, animated: true)
        
        /*if sourceRegionMon == true
         {
         self.monitorRegionAtLocation(center: sourcelocation, identifier: "geofence")
         sourceRegionMon = false
         }*/
        //remove the region from the array when didenterregion (which is first region of the dict)
        let tryReg = regionID[index]
        //print(index)
        //print(regionID)
        
        //this to check if user reach the starting point before starting the timer
        if index == 0
        {
            /*self.monitorRegionAtLocation(center: sourcelocation, identifier: "geofence")
             sourceRegionMon = false*/
            var nowloc = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            var clDest = CLLocation(latitude: sourcelocation.latitude, longitude: sourcelocation.longitude)
            let distNow = nowloc.distance(from: clDest)
            
            //when it's near or at the starting point
            if distNow <= 12 && sourceRegionMon == true
            {
                //pop up view to notify user when reach starting point
                self.speechSynthesizer.speak(text: "The race has started")
                self.view.addSubview(startRace)
                startRace.center = self.view.center
                startRace.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                startRace.alpha = 0
                UIView.animate(withDuration: 0.4, animations: {
                    self.startRace.alpha = 1
                    self.startRace.transform = CGAffineTransform.identity
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.startRace.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.startRace.alpha = 0
                    })
                    self.startRace.removeFromSuperview()
                })
                
                sourceRegionMon = false
                time = destTime[index]
                //index add one for the starting point also, so it's one more than destTime.count
                index += 1
                self.speechSynthesizer.speak(text: "Run to mission \(index)")
                missionNo.text = "Mission \(index):"
                setTime()
                overallTime()
                
            }
        }
        else
        {
            var nowloc = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            var clDest = CLLocation(latitude: destArrLat[index-1], longitude: destArrLong[index-1])
            
            let myLoc = "\(location?.coordinate.latitude), \(location?.coordinate.longitude)"
            let nowDest = "\(destArrLat[index-1]), \(destArrLong[index-1])"
            let distNow = nowloc.distance(from: clDest)
            
            //start speech synthesizer when within 5 metres
            if distNow < 50 && said == false
            {
                if skip == false
                {
                    self.speechSynthesizer.speak(text: "Mission 50 meters ahead")
                }
                said = true
            }
            
            //User reached location before time end
            if distNow <= 12 && time >= 0 && endRegionMon == true
            {
                print("Enter mission")
                endRegionMon = false
                timer?.invalidate()
                time = 0
                //Will call setTime() in updateTime() after validation
                updateTime()
            }
            //Only when user reach mission point, then start time
            if distNow <= 12 && time < 0  && endRegionMon == true && skip == true
            {
                print("Pass skip mission")
                time = destTime[index]
                index += 1
                missionNo.text = "Mission \(index):"
                self.speechSynthesizer.speak(text: "Run to mission \(index)")
                setTime()
                skip = false
                said = false
            }
        }
        
        //can use the code below to stop location update (prevent loop)
        //locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    func setTime()
    {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    var allTime:Timer?
    var allTimeCount = 0
    
    func overallTime()
    {
        allTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateAllTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateAllTime()
    {
        allTimeCount += 1
    }
    
    //Mission Tester!!
    var finishMsn = false
    var skip = false
    var arRunning = false
    
    var finishTime = 0
    var distance:Double = 0
    
    @objc func updateTime(){
        let mins:Int = time / 60
        let secs:Int = time % 60
        if time == 5
        {
            self.speechSynthesizer.speak(text: "You have 5 seconds left")
        }
        DispatchQueue.main.async {
            self.myTimer.text = "\(String(format: "%02i:%02i", mins, secs))"
        }
        
        //print ("x: \(endRegionMon) \(skip)")
        
        //when arrive and time > 0 (after didUpdate), then run the statement "if endRegionMon == false && skip == false"
        //Add "if endRegionMon == false" statement, if not time will continue to run, since it's more than 0
        if endRegionMon == false && skip == false
        {
            //print ("y")
            timer?.invalidate()
            
            //print("index: \(index), destArrLat: \(destArrLat.count)")
            if index < destArrLat.count
            {
                if finishMsn == false
                {
                    self.seconds = 30
                    allTime!.invalidate()
                    self.speechSynthesizer.speak(text: "Mission has started", onStoppedSpeaking: {
                        DispatchQueue.main.async {
                            
                            //ammo shoot
                            let circle = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.3)
                            self.circleNode = SCNNode(geometry: circle)
                            let colors = [
                                UIColor.brown,
                                UIColor.brown,
                                UIColor.brown,
                                UIColor.brown,
                                UIColor.brown,
                                UIColor.brown
                            ]
                            
                            var material:SCNMaterial?
                            for color in colors
                            {
                                material = SCNMaterial()
                                material!.diffuse.contents = color
                                material!.locksAmbientWithDiffuse = true
                                circle.materials.append(material!)
                            }
                            circle.materials[0].diffuse.contents = UIImage(named: "bullet")
                            self.circleNode!.name = "ammoBox"
                            //
                            
                            //add mission function here
                            self.arGame.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            self.view.addSubview(self.arGame)
                            self.arGame.center = self.view.center
                            self.arGame.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.arGame.alpha = 0
                            UIView.animate(withDuration: 0.4, animations: {
                                self.arGame.alpha = 1
                                self.arGame.transform = CGAffineTransform.identity
                            })
                            self.arView.session.run(self.arView.session.configuration!, options: [ .removeExistingAnchors])
                            self.arView.session.run(self.arView.session.configuration!, options: [ .resetTracking])
                            
                            self.arRunning = true
                            
                            self.ammoLbl.text = "\(self.ammoNo)"
                            
                            let sceneURL = Bundle.main.url(forResource: "art.scnassets/Walking-2/WalkingFixed", withExtension: "dae")
                            //paraScene!.rootNode.scale = SCNVector3(0.01, 0.01, 0.01)
                            
                            let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
                            
                            self.paraScene = SCNScene(named: "art.scnassets/Walking-2/WalkingFixed.dae")
                            
                            let paraCloneScn = SCNScene(named: "art.scnassets/Walking-2/WalkingFixed.dae")
                            for child in paraCloneScn!.rootNode.childNodes
                            {
                                self.paraStruc.addChildNode(child)
                            }
                            
                            
                            if let animationObject = sceneSource?.entryWithIdentifier("WalkingFixed-1", withClass: CAAnimation.self) {
                                print(animationObject)
                                // The animation will only play once
                                animationObject.repeatCount = 1
                                // To create smooth transitions between animations
                                animationObject.fadeInDuration = CGFloat(1)
                                animationObject.fadeOutDuration = CGFloat(0.5)
                                
                                // Store the animation for later use
                                //animations[withKey] = animationObject.
                                self.paraNode.addAnimation(animationObject, forKey: "paraAnime")
                            }
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                let sktSceneURL = Bundle.main.url(forResource: "art.scnassets/ZombieAttack/ZombieAttackFixed", withExtension: "dae")
                                let atkScene = SCNSceneSource(url: sktSceneURL!, options: nil)
                                let aObject = atkScene?.entryWithIdentifier("ZombieAttackFixed-1", withClass: CAAnimation.self)
                                aObject!.repeatCount = .greatestFiniteMagnitude
                                aObject!.fadeInDuration = CGFloat(1)
                                aObject!.fadeOutDuration = CGFloat(0.5)
                                self.atkAnime = aObject!
                                
                                let dieSceneURL = Bundle.main.url(forResource: "art.scnassets/ZombieDying/ZombieDyingFixed", withExtension: "dae")
                                let dieScene = SCNSceneSource(url: dieSceneURL!, options: nil)
                                let dObject = dieScene?.entryWithIdentifier("ZombieDyingFixed-1", withClass: CAAnimation.self)
                                dObject!.repeatCount = 1
                                dObject!.fadeInDuration = CGFloat(1)
                                dObject!.fadeOutDuration = CGFloat(0.5)
                                self.dieAnime = dObject!
                                
                            }
                        }
                    })
                }
                if finishMsn == true
                {
                    self.endRegionMon = true
                    self.finishMsn = false
                    self.said = false
                    self.arTimer.text = "Place camera over the ground"
                    DispatchQueue.main.async {
                        self.view.addSubview(self.missionRes)
                        self.missionRes.center = self.view.center
                        self.missionRes.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.missionRes.alpha = 0
                        print("shootPnt: \(self.shootPnt), handHits:\(self.handHits)")
                        self.mResLbl.text = "Finished Mission \n Time added:\(self.shootPnt) \n Time deducted: \(self.handHits)"
                        UIView.animate(withDuration: 0.4, animations: {
                            self.missionRes.alpha = 1
                            self.missionRes.transform = CGAffineTransform.identity
                        })
                        self.shootPnt = 0
                        self.handHits = 0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            UIView.animate(withDuration: 0.3, animations: {
                                self.missionRes.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                                self.missionRes.alpha = 0
                            })
                            self.missionRes.removeFromSuperview()
                        })
                    }
                    
                    time = destTime[index] + self.shootPnt - self.handHits
                    if time < 0
                    {
                        time = 0
                    }
                    index += 1
                    self.speechSynthesizer.speak(text: "Run to mission \(index)")
                    DispatchQueue.main.async {
                        self.missionNo.text = "Mission \(self.index):"
                    }
                    setTime()
                    
                    //invalidate all time when there's mission
                    
                    //myTimer.text = "00:00"
                    //time = -1
                    
                    self.stopTimer = false
                    self.finishMsn = false
                    self.seconds = 30
                    self.arView.session.pause()
                }
                
            }else {
                print("Finish run")
                finishedRace = true
                self.speechSynthesizer.speak(text: "You have finished the race")
                self.view.addSubview(finishRace)
                finishRace.center = self.view.center
                finishRace.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                finishRace.alpha = 0
                UIView.animate(withDuration: 0.4, animations: {
                    self.finishRace.alpha = 1
                    self.finishRace.transform = CGAffineTransform.identity
                })
                allTime?.invalidate()
            }
        }
            //Before the user reaches the location, so the time ends first, thus, "else if time < 1" is run first
        else if time < 1
        {
            timer?.invalidate()
            print("Skip mission")
            
            if index < destArrLat.count
            {
                self.speechSynthesizer.speak(text: "Mission skipped")
                DispatchQueue.main.async {
                    self.view.addSubview(self.missionRes)
                    self.missionRes.center = self.view.center
                    self.missionRes.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.missionRes.alpha = 0
                    self.mResLbl.text = "Skip mission"
                    UIView.animate(withDuration: 0.4, animations: {
                        self.missionRes.alpha = 1
                        self.missionRes.transform = CGAffineTransform.identity
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.missionRes.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.missionRes.alpha = 0
                        })
                        self.missionRes.removeFromSuperview()
                    })
                }
                DispatchQueue.main.async {
                    self.myTimer.text = "00:00"
                }
                time = -1
                skip = true
            } else {
                print("Finish run, but not on time")
                allTime?.invalidate()
            }
        }
        else
        {
            time -= 1
        }
    }
    
    func createFloorNode(anchor:ARPlaneAnchor)-> SCNNode{
        let floorNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        floorNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        floorNode.geometry?.firstMaterial?.isDoubleSided = true
        floorNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
        return floorNode
    }
    
    var pAnc:ARPlaneAnchor?
    var pNode:SCNNode?
    
    var planeNode:SCNNode?
    
    var seconds = 30
    var myARtimer:Timer?;
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        planeNode = createFloorNode(anchor: planeAnchor)
        planeNode!.name = "myFloor"
        node.addChildNode(planeNode!)
        if pAnc == nil || planeNode == nil
        {
            pAnc = planeAnchor
            pNode = planeNode
            
            var checkNode = false
            for x in self.arView.scene.rootNode.childNodes
            {
                if let xName = x.name
                {
                    if xName == "para1"
                    {
                        checkNode = true
                    }
                }
            }
            if checkNode == false
            {
                DispatchQueue.main.async {
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = [.X, .Y, .Z]
                    for child in self.paraScene!.rootNode.childNodes
                    {
                        self.paraNode.addChildNode(child)
                    }
                    //z coordinate is suppose to be along the camera ray z coordinate, so need convert to plane coordinates
                    self.paraNode.position = SCNVector3(0, 0, -5.0)
                    self.paraNode.scale = SCNVector3(0.01, 0.01, 0.01)
                    
                    let randomX = String(format: "%.1f", Double(self.paraNode.position.x))
                    let randomZ = String(format: "%.1f", Double(self.paraNode.position.z))
                    self.pcPostArr.append([randomX, randomZ])
                    
                    let camToPara = self.arView.pointOfView!.convertPosition(SCNVector3(0, 0, 0), to: nil)
                    let walkAction = SCNAction.move(to: SCNVector3(x: camToPara.x, y: self.pAnc!.transform.columns.3.y, z: camToPara.z), duration: 10)
                    self.paraNode.runAction(walkAction, forKey: "prevWalk")
                    self.paraNode.name = "para1"
                    self.paraName.append(self.paraNode.name!)
                    self.paraNode.constraints = [billboardConstraint]
                    self.planeNode!.addChildNode(self.paraNode)
                    self.arView!.scene.rootNode.addChildNode(self.paraNode)
                }
            }

        }
    }
    
    
    
    @objc func updateARtimer()
    {
        //print ("ARSession")
        if (self.pAnc != nil && self.planeNode != nil)
        {
            DispatchQueue.main.async {
                self.arTimer.text = "\(self.seconds) sec"
            }
        }
        if self.arRunning == true
        {
            print ("seconds = \(seconds)")
            if seconds < 1
            {
                self.finishMsn = true
                DispatchQueue.main.async{
                    
                    self.myARtimer!.invalidate()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.arGame.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.arGame.alpha = 0
                    })
                    
                    //added here
                    for x in self.paraNode.childNodes
                    {
                        x.removeFromParentNode()
                    }
                    for x in self.paraStruc.childNodes
                    {
                        x.removeFromParentNode()
                    }
                    
                    self.arView.scene.rootNode.enumerateChildNodes { (node, stop) in
                        if let n = node.name
                        {
                            if n != "targetNode"
                            {
                                node.removeFromParentNode()
                            }
                        }
                    }
                    //self.arView.session.run(self.arView.session.configuration!, options: [ .removeExistingAnchors])
                    self.arView.session.pause()
                    self.arGame.removeFromSuperview()
                }
                print ("self.finishMsn \(self.index) = true \(seconds)")
                
                updateTime()
                print("shootpntUpdate: \(self.shootPnt), handhitsUpdate: \(self.handHits)")
                self.seconds = 30
                self.currentTime = 30
                self.arRunning = false
                self.hitTime = 30
                self.ammoNo = 50
                self.ammoAppear = false
                self.pAnc = nil
                self.planeNode = nil
                self.arTimer.text = "Place camera over the ground"
                overallTime()
            }
            else
            {
                seconds -= 1
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes{
            (node, _) in
            node.removeFromParentNode()
        }
        if planeNode == nil || pAnc == nil
        {
            pAnc = planeAnchor
            planeNode = createFloorNode(anchor: planeAnchor)
            node.addChildNode(planeNode!)
            
            var checkNode = false
            for x in self.arView.scene.rootNode.childNodes
            {
                if let xName = x.name
                {
                    if xName == "para1"
                    {
                        checkNode = true
                    }
                }
            }
            if checkNode == false
            {
                DispatchQueue.main.async {
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = [.X, .Y, .Z]
                    for child in self.paraScene!.rootNode.childNodes
                    {
                        self.paraNode.addChildNode(child)
                    }
                    //z coordinate is suppose to be along the camera ray z coordinate, so need convert to plane coordinates
                    self.paraNode.position = SCNVector3(0, 0, -5.0)
                    self.paraNode.scale = SCNVector3(0.01, 0.01, 0.01)
                    
                    let randomX = String(format: "%.1f", Double(self.paraNode.position.x))
                    let randomZ = String(format: "%.1f", Double(self.paraNode.position.z))
                    self.pcPostArr.append([randomX, randomZ])
                    
                    let camToPara = self.arView.pointOfView!.convertPosition(SCNVector3(0, 0, 0), to: nil)
                    let walkAction = SCNAction.move(to: SCNVector3(x: camToPara.x, y: self.pAnc!.transform.columns.3.y, z: camToPara.z), duration: 10)
                    self.paraNode.runAction(walkAction, forKey: "prevWalk")
                    self.paraNode.name = "para1"
                    self.paraName.append(self.paraNode.name!)
                    self.paraNode.constraints = [billboardConstraint]
                    self.planeNode!.addChildNode(self.paraNode)
                    self.arView!.scene.rootNode.addChildNode(self.paraNode)
                }
            }
        }
        /*else
         {
         let pnNode = createFloorNode(anchor: planeAnchor)
         node.addChildNode(pnNode)
         }*/
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes{
            (node, _) in
            node.removeFromParentNode()
        }
    }
    
    var timeCount = 0
    var pcPostArr:[[String]] = [[]]
    var paraName:[String] = []
    
    var paraCloneArr:[SCNNode] = []
    var paraId = 2
    var currentTime = 30
    var prevTime = 0
    
    var stopTimer = false
    
    var handHits = 0
    var hitTime = 30
    
    var ammoAppear = false
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //print ("session")
        if pAnc != nil && stopTimer == false && finishMsn == false && planeNode != nil
        {
            print ("\(self.seconds)")
            myARtimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateARtimer), userInfo: nil, repeats: true)
            self.stopTimer = true
        }
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y, .Z]
        let camToPara = self.arView.pointOfView!.convertPosition(SCNVector3(0, 0, 0), to: nil)
        
        DispatchQueue.main.async {
            
            if self.circleNode != nil && self.seconds == 20 && self.ammoAppear == false
            {
                self.ammoAppear = true
                var circRandX = 0.0
                var circRandY = 0.0
                var circRandZ = 0.0
                
                while round(circRandZ) == 0 && round(circRandX) == 0
                {
                    circRandX = Double(String(format: "%.1f", Double.random(in: -1...1)))!
                    circRandY = Double(String(format: "%.1f", Double.random(in: -0.5...0.5)))!
                    circRandZ = Double(String(format: "%.1f", Double.random(in: -1...1)))!
                }
                
                self.circleNode!.position = SCNVector3(circRandX, circRandY, circRandZ)
                self.circleNode!.name = "ammoBox"
                self.circleNode!.constraints = [billboardConstraint]
                self.arView.scene.rootNode.addChildNode(self.circleNode!)
                print(self.circleNode!.description)
            }
            
            if self.seconds == 10
            {
                self.ammoAppear = false
                for x in self.arView.scene.rootNode.childNodes
                {
                    if let xName = x.name
                    {
                        if xName == "ammoBox"
                        {
                            
                            x.removeFromParentNode()
                        }
                    }
                }
            }
            
            if self.paraName.count != 0
            {
                for name in self.paraName
                {
                    for child in self.arView.scene.rootNode.childNodes
                    {
                        if let childName = child.name
                        {
                            if childName == name
                            {
                                if round(child.position.z) == round(camToPara.z)
                                {
                                    if !(child.animationKeys.contains("paraAttack"))
                                    {
                                        if !(child.animationKeys.contains("paraDie"))
                                        {
                                            child.removeAllAnimations()
                                            child.addAnimation(self.atkAnime!, forKey: "paraAttack")
                                        }
                                    }
                                }else{
                                    if child.animationKeys.contains("paraAttack")
                                    {
                                        child.removeAnimation(forKey: "paraAttack")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            //added here
            for child in self.arView.scene.rootNode.childNodes
            {
                if let cName = child.name
                {
                    if cName.contains("para") && child.animationKeys.contains("paraAttack")
                    {
                        if self.seconds < self.hitTime
                        {
                            let righthand = child.childNode(withName: "RightHand", recursively: true)
                            if righthand != nil
                            {
                                let rhPos = righthand!.convertPosition(SCNVector3(0, 0, 0), to: nil)
                                if String(format: "%.1f", rhPos.z) == String(format: "%.1f", camToPara.z)
                                {
                                    self.handHits += 1
                                    print("Hit: \(self.handHits)")
                                }
                            }
                            self.hitTime = self.seconds
                        }
                    }
                }
            }
            
            if self.seconds%4 == 0 && self.pAnc != nil
            {
                if self.seconds < self.currentTime{
                    var randomX = String(format: "%.1f", Double.random(in: -5...5))
                    var randomZ = String(format: "%.1f", Double.random(in: -5...5))
                    let checkPos = [randomX, randomZ]
                    while self.pcPostArr.contains(checkPos)
                    {
                        randomX = String(format: "%.1f", Double.random(in: -5...5))
                        randomZ = String(format: "%.1f", Double.random(in: -5...5))
                    }
                    self.pcPostArr.append(checkPos)
                    let pcVector = SCNVector3Make(Float(randomX)!, 0, Float(randomZ)!)
                    
                    var paraClone = self.paraStruc.clone()
                    paraClone.position = pcVector
                    paraClone.scale = SCNVector3(0.01, 0.01, 0.01)
                    let walkAction = SCNAction.move(to: SCNVector3(camToPara.x, self.pAnc!.transform.columns.3.y, camToPara.z), duration: 10)
                    paraClone.runAction(walkAction, forKey: "prevWalk")
                    paraClone.name = "para\(self.paraId)"
                    paraClone.constraints = [billboardConstraint]
                    self.planeNode!.addChildNode(paraClone)
                    self.arView!.scene.rootNode.addChildNode(paraClone)
                    
                    let sceneURL = Bundle.main.url(forResource: "art.scnassets/Walking-2/Walking", withExtension: "dae")
                    
                    let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
                    self.paraId += 1
                    self.paraName.append("para\(self.paraId)")
                    self.currentTime = self.seconds
                }
            }
        }
    }
    
}

