//
//  ViewHistoryVC.swift
//  iLyfe - Smart Trainer
//
//  Created by Guest User on 9/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct regimeStruct {
    var regimeName : String!
}

class ViewHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var regimeArray: [String] = []
    var regimeIdArray: [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For back button
        navigationItem.title = "Regime History"
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
        // For back button end
        // -------------
        let regimeRef = Database.database().reference()
        var index = 0
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
        
        // Get autoId
        regimeRef.child("users").child(userId).child("Regimes").observeSingleEvent(of: .value, with: {(snapshot) in
            let regimeIds = snapshot.children.allObjects as? [DataSnapshot]
            // Append autoid to an array
            for regime in regimeIds!{
                let regimeId = regime.key as String
                self.regimeIdArray.append(regimeId)
            }
            print(self.regimeIdArray)
            // Get regime name
            for regimeId in self.regimeIdArray{ regimeRef.child("users").child(userId).child("Regimes").child(regimeId).observeSingleEvent(of: .value, with: { (snapshot) in
                let regimes = snapshot.value as! [String:Any]
                // Append regime name to an array
                for regime in regimes{
                    self.regimeArray.append(String(regime.key))
                }
                print(self.regimeArray)
                self.tableView.reloadData()
            })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regimeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "regimeCell")
        
        cell?.textLabel?.text = self.regimeArray[indexPath.row]
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegimeResults"{
            let indexPath = (tableView.indexPathForSelectedRow?.row)!
            let regimeId = self.regimeIdArray[indexPath]
            let regimeName = self.regimeArray[indexPath]
            let regimeResultVC = segue.destination as! RegimeResultVC
            regimeResultVC.regimeId = regimeId
            regimeResultVC.regimeName = regimeName
        }
    }
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        self.dismiss(animated: true, completion: {});
        _ = navigationController?.popViewController(animated: true)
    }
}
