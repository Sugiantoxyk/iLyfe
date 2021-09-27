//
//  YogaHistListViewController.swift
//  iLyfe
//
//  Created by Sugianto on 4/8/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class YogaHistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var yogaHistTableView: UITableView!
    
    var yogaHist: [YogaHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        getAllYogaHist()
    }
    
    // Set nav bar
    func setNavigationBar() {
        // Title
        navigationItem.title = "Yoga History"
        
        // Create back button
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // Get yoga history
    func getAllYogaHist() {
        let userId = UserDefaults.standard.string(forKey: "userAutoId")!
        DataManagerSugi.getYogaHist(userId, onComplete: {
            (histInfo) in
            self.yogaHist = histInfo

            self.yogaHistTableView.reloadData()
        })
    }
    
    // Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return yogaHist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        
        // Current object
        let object = yogaHist[indexPath.row]
        
        let date = object.date
        // Change the format of date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd,MM,yyyy"
        
        let showDate = inputFormatter.date(from: date)
        inputFormatter.dateFormat = "dd MMM yyyy"
        
        let resultStr = inputFormatter.string(from: showDate!)
        
        // Get total time doing yoga
        let total = object.basicTime + object.intermediateTime + object.advanceTime
        
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = (total / 60) / 60
        
        let totalStr = "Total time spend: \(hours) Hours \(minutes) Minutes \(seconds) Seconds"
        
        cell?.textLabel?.text = resultStr
        cell?.detailTextLabel?.text = totalStr
        
        return cell!
    }
    
    // Remove grey color cell after selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        self.dismiss(animated: true, completion: {});
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Go to graph page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goGraph"
        {
            let yogaHistVC = segue.destination as! YogaHistViewController
            
            let selectedRow = yogaHistTableView.indexPathForSelectedRow
            
            var histDetail : YogaHistory
            
            if selectedRow != nil {
                histDetail = yogaHist[(selectedRow!.row)]
                
                yogaHistVC.histDetail = histDetail
            }
        }
    }

}
