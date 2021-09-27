//
//  DataManager(1).swift
//  iLyfe
//
//  Created by JT on 8/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//
import UIKit
import Foundation
import FirebaseDatabase

class DataManager
{
    static func loadResults(userId: String, region: String, mode: String, onComplete: @escaping ([FitResult]) -> Void){
        var fitArray:[FitResult] = []
        let ref = FirebaseDatabase.Database.database().reference().child("RunUsers/\(userId)/\(region)/\(mode)")
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            for record in snapshot.children
            {
                let r = record as! DataSnapshot
                //print("date: \(r.key)")
                fitArray.append(FitResult(r.key, userId, region, mode, r.childSnapshot(forPath: "Name").value as! String, r.childSnapshot(forPath: "Pace").value as! Double, r.childSnapshot(forPath: "Time").value as! Int, r.childSnapshot(forPath: "Distance").value as! Double, r.childSnapshot(forPath: "Calories").value as! Double, r.childSnapshot(forPath: "ParaNo").value as! Int))
            }
            onComplete(fitArray)
        })
    }
    
    static func insertResult(_ date:String, _ userId:String, _ region:String, _ mode:String, _ name:String,  _ pace:Double, _ time:Int, _ dist:Double, _ calories:Double, _ paraNo:Int)
    {
        let ref = FirebaseDatabase.Database.database().reference().child("RunUsers/\(userId)/\(region)/\(mode)/\(date)")
        ref.setValue([
            "Name": name,
            "Pace": pace,
            "Time": time,
            "Distance": dist,
            "Calories": calories,
            "ParaNo": paraNo
            ])
    }
}
