//
//  ChosenStoryViewController.swift
//  iLyfe
//
//  Created by JT on 11/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class ChosenStoryViewController: UIViewController {
    
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyImg: UIImageView!
    @IBOutlet weak var storyDesc: UILabel!
    @IBAction func modeBtnPressed(_ sender: UIButton) {
    }
    @IBAction func testBtn(_ sender: UIButton) {
    }
    
    var storyItem:Crime?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if storyItem != nil
        {
            storyTitle.text = storyItem?.title
            DispatchQueue.global(qos: .background).async {
                let data = try? Data(contentsOf: URL(string: self.storyItem!.imagePath)!)
                DispatchQueue.main.async {
                    self.storyImg.image = UIImage(data: data!)
                }
            }
            storyDesc.text = storyItem?.desc
        }
        self.navigationItem.title = "Story"
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
