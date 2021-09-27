//
//  runSumViewController.swift
//  iLyfe
//
//  Created by JT on 2/8/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class runSumViewController: UIViewController {
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var pace: UILabel!
    
    var fitRes:FitResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let fr = fitRes
        {
            var dist = fr.dist/1000
            print("\(dist)")
            let hour:Int = fr.time / 60
            let min:Int = (fr.time % 60) / 60
            let sec:Int = fr.time % 60 % 60
            distance.text = "\(dist) km"
            time.text = "\(hour)hrs \(min)mins \(sec)secs"
            pace.text = "\(String(format: "%.2f", fr.pace)) m/s"
        }
    }

}
