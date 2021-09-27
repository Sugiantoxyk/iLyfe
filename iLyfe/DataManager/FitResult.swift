//
//  FitResult.swift
//  iLyfe
//
//  Created by JT on 7/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import Foundation
class FitResult: NSObject {
    var date:String
    var userId:String
    var region:String
    var mode:String
    var name:String
    var pace:Double
    var time:Int
    var dist:Double
    var calories:Double
    var paraNo:Int
    init(_ date: String, _ userId: String, _ region: String, _ mode: String, _ name: String, _ pace: Double, _ time: Int, _ dist: Double, _ calories: Double, _ paraNo: Int){
        self.date = date
        self.userId = userId
        self.region = region
        self.mode = mode
        self.name = name
        self.pace = pace
        self.time = time
        self.dist = dist
        self.calories = calories
        self.paraNo = paraNo
    }
}
