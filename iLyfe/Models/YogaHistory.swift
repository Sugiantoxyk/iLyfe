//
//  YogaHistory.swift
//  iLyfe
//
//  Created by Sugianto on 4/8/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class YogaHistory: NSObject {

    var date: String
    var basicTime: Int
    var intermediateTime: Int
    var advanceTime: Int
    
    init(_ date: String, _ basicTime: Int, _ intermediateTime: Int, _ advanceTime: Int) {
        
        self.date = date
        self.basicTime = basicTime
        self.intermediateTime = intermediateTime
        self.advanceTime = advanceTime
    }
    
}
