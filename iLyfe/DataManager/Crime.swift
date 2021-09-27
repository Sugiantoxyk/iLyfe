//
//  Crime.swift
//  iLyfe
//
//  Created by JT on 11/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class Crime: NSObject {
    var title:String
    var imagePath:String
    var desc:String
    init(_ title:String, _ image:String, _ desc:String){
        self.title = title
        self.imagePath = image
        self.desc = desc
    }
}
