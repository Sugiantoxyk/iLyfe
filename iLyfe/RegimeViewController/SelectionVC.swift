//
//  SelectionVC.swift
//  iLyfe - Smart Trainer
//
//  Created by ITP312 on 28/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SelectionVC: UIViewController {
    
    var viewContainer: UIView!
    
    // For profile pic
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    // Selected Body Parts
    var bodyPartsArr: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
    }
    
    // Body Parts Selection
    @IBOutlet weak var LeftBicepOutlet: UIButton!
    @IBOutlet weak var RightBicepOutlet: UIButton!
    @IBOutlet weak var LeftForearmOutlet: UIButton!
    @IBOutlet weak var RightForearmOutlet: UIButton!
    
    // For profile pic
    override func viewDidAppear(_ animated: Bool) {
        addProfileImage()
    }
    
    // Navigation bar setup icon
    func setupNavigationBar() {
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        containView.addSubview(imageView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.profileImagePressed))
        containView.addGestureRecognizer(gesture)
        let leftBarItem = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = leftBarItem
    }
    
    // Update profile image
    func addProfileImage() {
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
        DataManagerSugi.getProfileImage(userId, onComplete: {
            (imageData) in
            self.imageView.image = UIImage(data: imageData)
        })
    }
    
    // Go to profile page
    @objc func profileImagePressed(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goProfile", sender:nil)
    }
    // For profile pic end
    
    // Select Left Forearm Selected
    @IBAction func LeftForearmSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            RightForearmOutlet.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Forearms")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            RightForearmOutlet.isSelected = true
            bodyPartsArr.append("Forearms")
            print(bodyPartsArr)
        }
    }
    
    // Select Right Forearm Selected
    @IBAction func RightForearmSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            LeftForearmOutlet.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Forearms")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            LeftForearmOutlet.isSelected = true
            bodyPartsArr.append("Forearms")
            print(bodyPartsArr)
        }
    }
    
    // Select Left Bicep
    @IBAction func LeftBicepSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            RightBicepOutlet.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Biceps Triceps")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
            
        } else {
            sender.isSelected = true
            RightBicepOutlet.isSelected = true
            bodyPartsArr.append("Biceps Triceps")
            print(bodyPartsArr)
        }
    }
    
    // Select Right Bicep
    @IBAction func RightBicepSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            LeftBicepOutlet.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Biceps Triceps")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            LeftBicepOutlet.isSelected = true
            bodyPartsArr.append("Biceps Triceps")
            print(bodyPartsArr)
        }
    }
    
    // Select Shoulders
    @IBAction func ShouldersSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Shoulders")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            bodyPartsArr.append("Shoulders")
            print(bodyPartsArr)
        }
    }
    
    // Select Chest
    @IBAction func ChestSelection(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Chest")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            bodyPartsArr.append("Chest")
            print(bodyPartsArr)
        }
    }
    
    // Select Abs/Core
    @IBAction func AbsCore(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Abs Core")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            bodyPartsArr.append("Abs Core")
            print(bodyPartsArr)
        }
    }
    
    // Select Thighs
    @IBAction func Thighs(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Thighs")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            bodyPartsArr.append("Thighs")
            print(bodyPartsArr)
        }
    }
    
    // Select Calves
    @IBAction func Calves(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            let index = bodyPartsArr.lastIndex(of: "Calves")!
            bodyPartsArr.remove(at: index)
            print(bodyPartsArr)
        } else {
            sender.isSelected = true
            bodyPartsArr.append("Calves")
            print(bodyPartsArr)
        }
    }
    
    // Segue to RegimeInfoVC
    @IBAction func ConfirmBtn(_ sender: Any) {
        var bodyPartSelection = "You have selected "
        
        for bodyPart in bodyPartsArr
        {
            // Setting the string for the alert message
            if bodyPartsArr.count > 1{
                // Add comma to body parts except for ones in the second last and last index
                if bodyPart != bodyPartsArr[bodyPartsArr.count-1] && bodyPart != bodyPartsArr[bodyPartsArr.count-2]{
                    bodyPartSelection = bodyPartSelection + bodyPart + ", "
                // Add string " and " to second last body part index
                }else if bodyPart == bodyPartsArr[bodyPartsArr.count-2]{
                    bodyPartSelection = bodyPartSelection + bodyPart + " and "
                // Add "." to last body part index
                }else{
                    bodyPartSelection = bodyPartSelection + bodyPart + "."
                }
                // Add "." when only one body part is selected.
            }else if bodyPartsArr.count == 1{
                bodyPartSelection = bodyPartSelection + bodyPart + "."
            }
        }
        // Validation message when user did not make a selection
        if bodyPartsArr.count == 0 {
            bodyPartSelection = "You have not made a selection."
        }
        
        // Main Alert Controls
        let selectionAlert = UIAlertController(title: nil, message: bodyPartSelection, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let confirmSelection = UIAlertAction(title: "Confirm", style: .default) {(_) ->Void in
            self.performSegue(withIdentifier: "RegimeInfo", sender: self)
        }
        let noSelection = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        // Alert view when user did not make a selection
        if bodyPartsArr.count != 0{
        selectionAlert.addAction(cancel)
        selectionAlert.addAction(confirmSelection)
        }else{
            selectionAlert.addAction(noSelection)
        }
        
        present(selectionAlert, animated: true, completion: nil)
    }
    // Segue to RegimeInfo.swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegimeInfo"
        {
            let SelectVC = segue.destination as! RegimeInfoVC
            SelectVC.bodyParts = bodyPartsArr
        }
    }
}
