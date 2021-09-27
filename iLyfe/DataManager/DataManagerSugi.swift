//
//  DataManager.swift
//  iLyfe
//
//  Created by Sugianto on 9/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DataManagerSugi {
    
    // Insert new user
    static func addUser(_ email: String, _ name: String) {
        let ref = FirebaseDatabase.Database.database().reference().child("users/").childByAutoId()
        ref.setValue(["email": email.lowercased(),
                      "name": name])
        
        uploadProfileImage(ref.key!, UIImage(named: "firstProfileImage")!)
    }
    
    // Get user autoId of logged in user
    static func retrieveUserId(_ email: String, onComplete: @escaping (String) -> Void) {
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {
            (snapshot) in
            // To get autoId
            let allUser = snapshot.value as? NSDictionary
            
            for userInfo in allUser! {
                // User autoId
                let userId = userInfo.key
                let userEmail = snapshot.childSnapshot(forPath: "\(userId)/email").value as! String
                
                // Finding the logged in user
                if (userEmail == email.lowercased()) {
                    onComplete(userId as! String)
                    break
                }
            }
            
        })
        
    }
    
    // Get all info of the logged in user for ProfilePage
    static func getUserInfo(_ userId: String, onComplete: @escaping (NSDictionary?) -> Void) {
        
        Database.database().reference().child("users").child("\(userId)").observeSingleEvent(of: .value) {
            (snapshot) in
            let userInfo = snapshot.value as? NSDictionary

            // Return Profile page information
            onComplete(userInfo)
        }
    }
    
    // Upload profile image
    static func uploadProfileImage(_ userId: String, _ image: UIImage) {
       
        let imageData = image.jpegData(compressionQuality: 1)
        
        Storage.storage().reference().child("profileImages").child("\(userId)").putData(imageData!)
    }
    
    // Get user profile image
    static func getProfileImage(_ userId: String, onComplete: @escaping (Data) -> Void) {
       
        Storage.storage().reference().child("profileImages").child("\(userId)").getData(maxSize: 1024 * 1024 * 12) {
            (data, err) in

            if let imageData = data {
                onComplete(imageData)
            }
        }
        
    }
    
    // Get all yoga pose
    static func getPoseList(_ userId: String, onComplete: @escaping ([Pose], [Pose], [Pose]) -> Void) {

        var poseListBasic: [Pose] = []
        var poseListIntermediate: [Pose] = []
        var poseListAdvance: [Pose] = []
        
        var achievement1 = ""
        var achievement2 = ""
        var achievement3 = ""
        
        // Get the users achievements
        Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) {
            (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            
            if (userInfo?["achievement1"] as? String != nil) {
                achievement1 = userInfo?["achievement1"] as! String
            }
            if (userInfo?["achievement2"] as? String != nil) {
                achievement2 = userInfo?["achievement2"] as! String
            }
            if (userInfo?["achievement3"] as? String != nil) {
                achievement3 = userInfo?["achievement3"] as! String
            }

            // Get all post
            Database.database().reference().child("yoga/").observeSingleEvent(of: .value, with: {
                (snapshot) in
                for pose in snapshot.children {
                    let data = pose as! DataSnapshot
                    
                    let keypoints = [[data.childSnapshot(forPath: "keypoints/0/0").value as! Double, data.childSnapshot(forPath: "keypoints/0/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/1/0").value as! Double, data.childSnapshot(forPath: "keypoints/1/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/2/0").value as! Double, data.childSnapshot(forPath: "keypoints/2/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/3/0").value as! Double, data.childSnapshot(forPath: "keypoints/3/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/4/0").value as! Double, data.childSnapshot(forPath: "keypoints/4/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/5/0").value as! Double, data.childSnapshot(forPath: "keypoints/5/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/6/0").value as! Double, data.childSnapshot(forPath: "keypoints/6/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/7/0").value as! Double, data.childSnapshot(forPath: "keypoints/7/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/8/0").value as! Double, data.childSnapshot(forPath: "keypoints/8/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/9/0").value as! Double, data.childSnapshot(forPath: "keypoints/9/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/10/0").value as! Double, data.childSnapshot(forPath: "keypoints/10/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/11/0").value as! Double, data.childSnapshot(forPath: "keypoints/11/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/12/0").value as! Double, data.childSnapshot(forPath: "keypoints/12/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/13/0").value as! Double, data.childSnapshot(forPath: "keypoints/13/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/14/0").value as! Double, data.childSnapshot(forPath: "keypoints/14/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/15/0").value as! Double, data.childSnapshot(forPath: "keypoints/15/1").value as! Double],
                                     [data.childSnapshot(forPath: "keypoints/16/0").value as! Double, data.childSnapshot(forPath: "keypoints/16/1").value as! Double]]
                    
                    // If user already gotten the medal
                    var imageName = data.childSnapshot(forPath: "image").value as! String
                    if (data.childSnapshot(forPath: "difficulty").value as! Int == 1) {
                        if (achievement1.contains(imageName)) {
                            imageName = imageName + "Achievement"
                        }
                    } else if (data.childSnapshot(forPath: "difficulty").value as! Int == 2) {
                        if (achievement2.contains(imageName)) {
                            imageName = imageName + "Achievement"
                        }
                    } else if (data.childSnapshot(forPath: "difficulty").value as! Int == 3) {
                        if (achievement3.contains(imageName)) {
                            imageName = imageName + "Achievement"
                        }
                    }
                    
                    let thisPose = Pose(
                        data.childSnapshot(forPath: "name").value as! String,
                        data.childSnapshot(forPath: "sanskritName").value as! String,
                        imageName,
                        data.childSnapshot(forPath: "difficulty").value as! Int,
                        keypoints)
                    
                    switch thisPose.difficulty {
                    case 1:
                        poseListBasic.append(thisPose)
                    case 2:
                        poseListIntermediate.append(thisPose)
                    case 3:
                        poseListAdvance.append(thisPose)
                    default:
                        continue
                    }
                }
                
                onComplete(poseListBasic, poseListIntermediate, poseListAdvance)
            })
        }
        
    }
    
    // Get achievement
    static func achievementGet(_ yogaImageName: String,_ difficulty: Int, _ userId: String) {
        
        // Get the users achievements
        Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) {
            (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            var achievements = ""
            
            if (difficulty == 1) {
                if (userInfo?["achievement1"] as? String != nil) {
                    achievements = userInfo?["achievement1"] as! String
                }
            } else if (difficulty == 2) {
                if (userInfo?["achievement2"] as? String != nil) {
                    achievements = userInfo?["achievement2"] as! String
                }
            } else if (difficulty == 3) {
                if (userInfo?["achievement3"] as? String != nil) {
                    achievements = userInfo?["achievement3"] as! String
                }
            }
            
            // Check if user gotten achievement
            if (achievements.contains(yogaImageName)){
                // Do nothing
            } else {
                achievements = achievements + yogaImageName + "Achievement,"
            
                // Update users achievements list
                let ref2 = FirebaseDatabase.Database.database().reference().child("users/").child(userId)
                ref2.updateChildValues(["achievement\(difficulty)" : achievements])
                
                // To reload table view data
                UserDefaults.standard.set(true, forKey: "tableViewReload")
            }
            
        }
        
    }
    
    // Store time doing yoga
    static func storeTimeYoga(_ autoId: String, _ totalTime: Int, _ difficulty: Int) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd,MM,yyyy"
        let result = formatter.string(from: date)
        
        var basicTime = 0
        var intermediateTime = 0
        var advanceTime = 0
        
       // Get time
        Database.database().reference().child("users").child(autoId).child("yogaHist").observeSingleEvent(of: .value) {
            (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            
            // If got same date data
            if (userInfo?[result] as? NSDictionary != nil) {
                // Get time for yoga done
                basicTime = snapshot.childSnapshot(forPath: "\(result)/basicTime").value as! Int
                intermediateTime = snapshot.childSnapshot(forPath: "\(result)/intermediateTime").value as! Int
                advanceTime = snapshot.childSnapshot(forPath: "\(result)/advanceTime").value as! Int
            }
            
            // Update the time arr int
            if (difficulty == 1) {
                basicTime = basicTime + totalTime
            } else if (difficulty == 2) {
                intermediateTime = intermediateTime + totalTime
            } else if (difficulty == 3) {
                advanceTime = advanceTime + totalTime
            }
            
            // Update time
            Database.database().reference().child("users").child(autoId).child("yogaHist").child(result).updateChildValues(
                ["basicTime" : basicTime,
                 "intermediateTime" : intermediateTime,
                 "advanceTime" : advanceTime]
            )
            
        }
        
    }
    
    static func getYogaHist(_ autoId: String, onComplete: @escaping ([YogaHistory]) -> Void) {
        
        var yogaHist: [YogaHistory] = []
        Database.database().reference().child("users").child(autoId).child("yogaHist").observeSingleEvent(of: .value) {
            (snapshot) in
            let histInfo = snapshot.value as? NSDictionary
            
            if histInfo == nil {
                
            } else {
                for histDate in histInfo! {
                    // History date
                    let date = histDate.key
                    
                    // Create object and push to yogaHistory
                    let thisHist = YogaHistory(
                        date as! String,
                        snapshot.childSnapshot(forPath: "\(date)/basicTime").value as! Int,
                        snapshot.childSnapshot(forPath: "\(date)/intermediateTime").value as! Int,
                        snapshot.childSnapshot(forPath: "\(date)/advanceTime").value as! Int
                    )
                    
                    yogaHist.append(thisHist)
                }
            }
            
            // Return history information
            onComplete(yogaHist)
        }
    }
    
}
