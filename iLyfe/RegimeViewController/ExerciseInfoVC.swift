//
//  ExerciseInfoVC.swift
//  iLyfe - Smart Trainer
//
//  Created by ITP312 on 15/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ExerciseInfoVC: UIViewController {
    
    var exercise: String = ""
    var bodyPart: String = ""
    var exDefaultReps: Int = 0
    var caloriesPerRep: Int = 0
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var caloriesLossLabel: UILabel!
    
    @IBOutlet weak var defaultRepsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(exercise)
        print(bodyPart)
        self.navigationItem.title=exercise
//        exerciseRef.child("Exercises").child(bodyPart).observeSingleEvent(of: .value, with: {
        let exerciseRef = Database.database().reference()
        exerciseRef.child("Exercises").child(bodyPart).child(exercise).observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.exDefaultReps = snapshot.childSnapshot(forPath: "exDefaultReps").value as! Int
            self.caloriesPerRep = snapshot.childSnapshot(forPath: "caloriesPerRep").value as! Int
            self.reloadInputViews()
            self.imageView.image = UIImage(named: self.exercise)
            self.defaultRepsLabel.text = "Number of Reps: \(self.exDefaultReps)"
            self.caloriesLossLabel.text = "Calories Per Rep: \(self.caloriesPerRep)"
        })
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
