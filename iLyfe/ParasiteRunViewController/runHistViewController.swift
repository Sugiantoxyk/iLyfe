//
//  runHistViewController.swift
//  iLyfe
//
//  Created by JT on 2/8/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class runHistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var userId = UserDefaults.standard.string(forKey: "userAutoId")!
    
    var count = 0
    var tryArr:[FitResult] = []
    var allReg:[String] = []
    var allMode = ["Easy", "Medium", "Difficult"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For back button
        navigationItem.title = "Run History"
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
        // For back button end
        
        // Do any additional setup after loading the view.
        
        let url = Bundle.main.url(forResource: "SGplace", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        let json = try? JSON(data: data!)
        for (key, value) in json!
        {
            allReg.append(key)
        }
        
        for x in 0..<allReg.count
        {
            for y in allMode
            {
                DataManager.loadResults(userId: userId, region: allReg[x], mode: y, onComplete: {
                    (runHist) in
                    if !runHist.isEmpty
                    {
                        self.count = runHist.count
                        self.tryArr += runHist
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("count: \(count)")
        return tryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "runCell", for: indexPath) as! runHistCell
        DataManager.loadResults(userId: userId, region: "Yishun", mode: "Easy", onComplete: {
            (runHist) in
            //print(runHist)
            let runItem = runHist[indexPath.row]
            cell.info1.text = "\(runItem.date)"
            cell.info2.text = "\(runItem.region) \(runItem.mode) \n\(runItem.dist/1000)km    \(runItem.time)secs"
            cell.info3.text = "\(String(format:"%.3f", runItem.calories))cal \(String(format: "%.2f",runItem.pace))m/s"
        })
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runSegue"
        {
            let dest = segue.destination as! runSumViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            if indexPath != nil
            {
                let runSum = tryArr[indexPath!.row]
                dest.fitRes = runSum
            }
        }
    }
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        self.dismiss(animated: true, completion: {});
        _ = navigationController?.popViewController(animated: true)
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
