//
//  RegimeInfoVC.swift
//  iLyfe - Smart Trainer
//
//  Created by ITP312 on 5/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RegimeInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var exercisesTableView: UITableView!
    
    @IBOutlet weak var continueBtn: UIBarButtonItem!
    
    // Selected Body Parts
    var bodyParts: [String] = []
    var bodyPart: String = ""
    var exerciseArray1: [[String]] = []
    var exerciseIndex = 0
    var exercise: String = ""
    struct Objects{
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBtn.isEnabled = false
        getData()
    }
    
    func getData(){
        let exerciseRef = Database.database().reference()
        for i in 0...bodyParts.count-1{
            exerciseRef.child("Exercises").child(bodyParts[i]).observeSingleEvent(of: .value, with: {
                (snapshot) in
                var exerciseArray: [String] = []
                for exercise in snapshot.children{
                    let exercise = exercise as! DataSnapshot
                    exerciseArray.append(String(exercise.key))
                    if exerciseArray.count == 2{
                        self.exerciseArray1.append(exerciseArray)
                    }
                }
                print(self.exerciseArray1)
                self.continueBtn.isEnabled = true
                self.exercisesTableView.reloadData()
            })
        }
    }
    
    // Set number of rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exerciseArray1[section].count
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.exerciseArray1.count
    }
    
    // Set header for section division
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return bodyParts[section]
    }
    
    // Set content of table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = self.exerciseArray1[indexPath.section][indexPath.row]
        return cell
    }
    
    // Segue for ViewHistoryVC.swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartRegime"
        {
            // Send Info to RegimeVC
            let RegimeVC = segue.destination as! RegimeVC
            RegimeVC.bodyParts = bodyParts
            RegimeVC.exerciseArray = exerciseArray1
        }else if segue.identifier == "ExerciseInfo" {
            // Send Info to ExerciseInfoVC
            let ExerciseInfoVC = segue.destination as! ExerciseInfoVC
            let selectedRow = exercisesTableView.indexPathForSelectedRow
            exercise = exerciseArray1[selectedRow![0]][selectedRow![1]]
            ExerciseInfoVC.exercise = exercise
            bodyPart = bodyParts[selectedRow![0]]
            ExerciseInfoVC.bodyPart = bodyPart
        }
    }
}
