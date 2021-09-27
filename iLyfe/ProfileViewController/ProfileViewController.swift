//
//  ProfileViewController.swift
//  iLyfe
//
//  Created by Sugianto on 9/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var openAchievementView: UIView!
    @IBOutlet weak var imageInOverlay: UIImageView!
    @IBOutlet weak var labelNameInOverlay: UILabel!
    @IBOutlet weak var labelInOverlay: UILabel!
    
    @IBOutlet weak var runHistButton: UIButton!
    @IBOutlet weak var regimeHistButton: UIButton!
    @IBOutlet weak var yogaHistButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    // For blur screen
    var blurEffect: UIBlurEffect?
    var blurredEffectView: UIVisualEffectView?
    var buttonView: UIImageView?
    
    // For award (imageName & desc)
    var myAward: [String] = []
    var myAwardName: [String] = ["Beginner's Luck", "Usain Bolt", "Eager Starter", "On That Grind", "Ecstatic Beginner", "Experienced Poser", "Yoga Master"]
    var myAwardDesc: [String] = ["Kill 5 zombies.", "Complete a race on time.", "Complete 10 regimes.", "Complete 50 regimes." , "Complete all Basic yoga pose.", "Complete all Intermediate yoga pose.", "Complete all Advance yoga pose."]
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup overlay UIView
        openAchievementView.layer.cornerRadius = 5
        
        // Create blur background
        blurEffect = UIBlurEffect(style: .dark)
        blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView!.frame = view.bounds
        
        // Create "X" button
        let xButton = UIImage(named: "xButton")
        buttonView = UIImageView(image: xButton)
        buttonView!.frame = CGRect(x: openAchievementView.bounds.width - 35, y: 10, width: 25, height: 25)
        
        // Create tap gesture for "X" button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(xButtonTap(sender:)))
        buttonView!.addGestureRecognizer(tapGesture)
        buttonView!.isUserInteractionEnabled = true
        
        // Setup buttons
        runHistButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        runHistButton.layer.borderWidth = 1.0
        runHistButton.layer.cornerRadius = 3.0
        regimeHistButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        regimeHistButton.layer.borderWidth = 1.0
        regimeHistButton.layer.cornerRadius = 3.0
        yogaHistButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        yogaHistButton.layer.borderWidth = 1.0
        yogaHistButton.layer.cornerRadius = 3.0
        
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
        DataManagerSugi.getUserInfo(userId, onComplete: {
            (userInfo) in
            
            let name = userInfo?["name"] as! String
            
            self.myAward = ["runAward1Blur", "runAward2Blur", "trainerAward1Blur", "trainerAward2Blur", "yogaAward1Blur", "yogaAward2Blur", "yogaAward3Blur"]
            
            // If run medal
            if let runAchievement = userInfo?["Finish"] as! String? {
                if (runAchievement == "true") {
                    self.myAward[1] = "runAward2"
                }
            }
            
            // If kill zombie medal
            if let runZombieAchievement = userInfo?["TotalPara"] as! Int? {
                if (runZombieAchievement >= 5) {
                    self.myAward[0] = "runAward1"
                }
            }
            
            // If complete 10 regimes or 50 regimes
            var num = 0
            if let regimes = userInfo?["Regimes"] as! NSDictionary? {
                for regime in regimes {
                    num = num + 1
                }
                
                if (num >= 10) {
                    self.myAward[2] = "trainerAward1"
                }
                
                if (num >= 50) {
                    self.myAward[3] = "trainerAward2"
                }
            }
            
            // If got all Basic yoga medal
            if let achievement = userInfo?["achievement1"] as! String? {
                
                var achievementArr = achievement.components(separatedBy: ",")
                achievementArr.removeLast()
                
                if (achievementArr.count == 13) {
                    self.myAward[4] = "yogaAward1"
                }
            }
            // If got all Intermediate yoga medal
            if let achievement = userInfo?["achievement2"] as! String? {
                
                var achievementArr = achievement.components(separatedBy: ",")
                achievementArr.removeLast()
                
                if (achievementArr.count == 10) {
                    self.myAward[5] = "yogaAward2"
                }
            }
            // If got all Advance yoga medal
            if let achievement = userInfo?["achievement3"] as! String? {
                
                var achievementArr = achievement.components(separatedBy: ",")
                achievementArr.removeLast()
                
                if (achievementArr.count == 3) {
                    self.myAward[6] = "yogaAward3"
                }
            }
            
            // Set user name
            self.nameLabel.text = name.uppercased()
            
            // Reload data
            self.collectionView.reloadData()
            
        })
        
        // START LOAD
        DataManagerSugi.getProfileImage(userId) {
            (imageData) in
            
            // END LOAD
            self.imageView.image = UIImage(data: imageData)
        }
        
        imagePicker.delegate = self
        
        // Make image circle and clickable
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.profileImagePressed))
        containView.addGestureRecognizer(gesture)
    }
    
    // Choose image from library
    @objc func profileImagePressed(sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Finish picking image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
            
            // Upload image to firebase
            let userId = UserDefaults.standard.string(forKey: "userAutoId")!
            DataManagerSugi.uploadProfileImage(userId, imageView.image!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myAward.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementCollectionViewCell", for: indexPath) as! AchievementCollectionViewCell
        
        cell.imageView.image = UIImage(named: myAward[indexPath.row])
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collectionTap(sender :))))
        
        return cell
    }
    
    @objc func collectionTap(sender: UITapGestureRecognizer) {
        // Getting index of collection view cell tapped
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        let index = indexPath![1]
        
        // Update information
        imageInOverlay.image = UIImage(named: myAward[index])
        labelNameInOverlay.text = myAwardName[index]
        labelInOverlay.text = myAwardDesc[index]
        
        // Add sub view
        view.addSubview(blurredEffectView!)
        openAchievementView.addSubview(buttonView!)
        view.addSubview(openAchievementView!)
        
        blurredEffectView?.effect = nil
        
        openAchievementView.center = self.view.center
        openAchievementView.alpha = 0
        openAchievementView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        // Animation
        UIView.animate(withDuration: 0.4) {
            self.blurredEffectView?.effect = self.blurEffect
            self.openAchievementView.alpha = 1
            self.openAchievementView.transform = CGAffineTransform.identity
        }
        
    }
    
    // When "X" button is tapped
    @objc func xButtonTap(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.4) {
            self.blurredEffectView?.effect = nil
            self.openAchievementView.alpha = 0
            self.openAchievementView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }
        
        // Remove subview
        self.openAchievementView.removeFromSuperview()
        self.blurredEffectView?.removeFromSuperview()
    }
    
    // Log out to login page
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set("", forKey: "userAutoId")
        self.performSegue(withIdentifier: "logOut", sender:nil)
    }
    
    // Back to previous page
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
