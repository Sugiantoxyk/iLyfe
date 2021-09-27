//
//  InstructionViewController.swift
//  iLyfe
//
//  Created by JT on 12/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InstructionViewController: UIViewController {
    
    var level:[String:String] = ["Easy":"38", "Medium":"58", "Difficult":"88"]
    
    @IBOutlet weak var instructLbl: UILabel!
    
    var mode:String?
    var myRegion:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructLbl.text = CrimeStories.instruct()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap"
        {
            let dest = segue.destination as! startRunViewController
            if myRegion != nil
            {
                dest.myRegion = myRegion!
                dest.mode = mode
            }
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
