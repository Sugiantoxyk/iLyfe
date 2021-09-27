//
//  RunResults.swift
//  iLyfe
//
//  Created by JT on 7/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RunResults: UIViewController {
    
    @IBOutlet weak var distLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var record: UILabel!
    @IBOutlet weak var caloriesLbl: UILabel!
    
    
    var dist:Double?
    var time:Int?
    var pace:Double?
    var frObj:FitResult?
    var weight:Double?
    var prevPara:Int?
    var finishedRace:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        record.isHidden = true
        
        if weight == nil
        {
            weight = 50.0
        }
        
        //Check best record
        let step = Double(self.time!)/60.0 * 8.0 * 3.5 * weight!
        let calories = step / (200 * 60)
        
        let newParaNo = self.prevPara! + self.frObj!.paraNo
        let ref = FirebaseDatabase.Database.database().reference().child("users/\(frObj!.userId)")
        ref.updateChildValues(["TotalPara":newParaNo])
        if finishedRace == true
        {
            ref.updateChildValues(["Finish": "true"])
        }
        
        
                
        DataManager.loadResults(userId: frObj!.userId, region: self.frObj!.region, mode: self.frObj!.mode, onComplete: {
            (fitArray) in
            if fitArray.isEmpty
            {
                self.record.isHidden = false
                self.record.text = "Best Time!"
            }
            else
            {
                var best = true
                for x in fitArray
                {
                    if x.time < self.frObj!.time
                    {
                        best = false
                    }
                }
                if best == true
                {
                    self.record.isHidden = false
                    self.record.text = "Best Time!"
                }
                
            }
            DataManager.insertResult(self.frObj!.date, self.frObj!.userId, self.frObj!.region, self.frObj!.mode, self.frObj!.name, self.frObj!.pace, self.frObj!.time, self.frObj!.dist, calories, self.frObj!.paraNo)
        })
        
        
            
        //calculate time
        let hour:Int = self.time! / 60
        let min:Int = (self.time! % 60) / 60
        let sec:Int = self.time! % 60 % 60
        self.distLbl.text = "\(self.dist!/1000) km"
        self.timeLbl.text = "\(hour)hrs \(min)mins \(sec)secs"
        self.paceLbl.text = "\(String(format: "%.2f", self.pace!)) m/s"
        self.caloriesLbl.text = "\(String(format: "%.3f", calories)) cal"
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackHome"
        {
            segue.destination as! DrMenuViewController
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
