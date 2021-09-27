//
//  RegimeResultVC.swift
//  iLyfe - Smart Trainer
//
//  Created by Wei Bin Tan on 2/8/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ResultTableViewCell: UITableViewCell{
    @IBOutlet weak var exNameLabel: UILabel!
    @IBOutlet weak var exRepsLabel: UILabel!
    @IBOutlet weak var exDuration: UILabel!
    @IBOutlet weak var exCaloriesLoss: UILabel!
    @IBOutlet weak var exImageView: UIImageView!
    
}

class RegimeResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var regimeId: String = ""
    var regimeName: String = ""
    var bodyPartArray: [String] = []
    var exerciseArr: [String] = []
    var exerciseArray: [[String]] = []
    var exerciseReps: [[String]] = []
    
    // Variables for Reps
    var exDefaultRepsArr: [Int] = []
    var exDefaultRepsArr2: [[Int]] = []
    
    // Variables for Time Taken
    var timeTakenArr: [Int] = []
    var timeTakenArr2: [[Int]] = []
    
    // Variables for Calories
    var caloriesLossArr: [Int] = []
    var caloriesLossArr2: [[Int]] = []
    
    var detailDictionary1: [String: Any] = [:]
    var detailDictionary2: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // For back button
        navigationItem.title = regimeName
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
        
        
        let regimeRef = Database.database().reference()
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
    regimeRef.child("users").child(userId).child("Regimes").child(regimeId).child(regimeName).observeSingleEvent(of: .value, with: {(snapshot) in
            let bodyParts = snapshot.children.allObjects as? [DataSnapshot]
            for bodyPart in bodyParts!{
                print(String(bodyPart.key))
                self.bodyPartArray.append(String(bodyPart.key))
            }
        // Append exercise to exerciseArray
            for bodyPart in self.bodyPartArray{ regimeRef.child("users").child(userId).child("Regimes").child(self.regimeId).child(self.regimeName).child(bodyPart).observeSingleEvent(of: .value, with: {(snapshot) in
                    let exercises = snapshot.value as! [String:Any]
                for exercise in exercises{
                    self.exerciseArr.append(String(exercise.key))
                    if self.exerciseArr.count == 2 {
                        self.exerciseArray.append(self.exerciseArr)
                        self.exerciseArr = []
                    }
                    print(String(exercise.key))
                regimeRef.child("users").child(userId).child("Regimes").child(self.regimeId).child(self.regimeName).child(bodyPart).child(String(exercise.key)).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let defaultReps = snapshot.childSnapshot(forPath: "Reps Completed").value as! Int
                    self.exDefaultRepsArr.append(defaultReps)
                    if self.exDefaultRepsArr.count == 2{
                    self.exDefaultRepsArr2.append(self.exDefaultRepsArr)
                        self.exDefaultRepsArr = []
                    }
                    
                    let defaultTime = snapshot.childSnapshot(forPath: "Time Taken").value as! Int
                    self.timeTakenArr.append(defaultTime)
                    if self.timeTakenArr.count == 2{
                        self.timeTakenArr2.append(self.timeTakenArr)
                        self.timeTakenArr = []
                    }
                    
                    let defaultCalories = snapshot.childSnapshot(forPath: "Calories Burnt").value as! Int
                    self.caloriesLossArr.append(defaultCalories)
                    if self.caloriesLossArr.count == 2{
                        self.caloriesLossArr2.append(self.caloriesLossArr)
                        self.caloriesLossArr = []
                    }
                    print(self.exDefaultRepsArr2)
                    print(self.caloriesLossArr2)
                    
                    
                    if self.caloriesLossArr2.count == self.exerciseArray.count{
                    self.tableView.reloadData()
                    }
                    })
                }
                })
            }
        })
    }
    
    func ArraySorter(array: [Int]) -> [[Int]]{
        var normalArray: [Int] = []
        var sortedArray: [[Int]] = []
        for i in 0...array.count-1{
            normalArray.append(array[i])
            if array.count == 2{
            sortedArray.append(normalArray)
            normalArray = []
            }
        }
        return sortedArray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseArray[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bodyPartArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if bodyPartArray.isEmpty{
            return ""
        }else{
        return bodyPartArray[section]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegimeResultCell", for: indexPath) as! ResultTableViewCell
        cell.exNameLabel.text =  exerciseArray[indexPath.section][indexPath.row]
        
        let Reps = String(exDefaultRepsArr2[indexPath.section][indexPath.row])
        let Duration = String(timeTakenArr2[indexPath.section][indexPath.row])
        let Calories = String(caloriesLossArr2[indexPath.section][indexPath.row])
        
        cell.exRepsLabel.text = "Reps: \(Reps)"
        cell.exDuration.text = "Duration: \(Duration)"
        cell.exCaloriesLoss.text = "Calories Burnt: \(Calories)"
        cell.exImageView.image = UIImage(named: exerciseArray[indexPath.section][indexPath.row])
        
        return cell
    }
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ""{
            
        }
    }
}
