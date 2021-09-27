//
//  Pose.swift
//  iLyfe
//
//  Created by ITP312 on 15/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class Pose: NSObject {
    
    var name: String
    var imageName: String
    var sanskritName: String
    var difficulty: Int
    var keypoints: [[Double]]
    
    init(_ name: String, _ sanskritName: String, _ imageName: String, _ difficulty: Int, _ keypoints: [[Double]] ) {
        
        self.name = name
        self.sanskritName = sanskritName
        self.imageName = imageName
        self.difficulty = difficulty
        self.keypoints = keypoints
    }
}
