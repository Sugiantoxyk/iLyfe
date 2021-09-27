//
//  PostListViewController.swift
//  iLyfe
//
//  Created by ITP312 on 2/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var poseListBasic: [Pose] = []
    var poseListIntermediate: [Pose] = []
    var poseListAdvance: [Pose] = []
    
    var filteredPoseListBasic: [Pose] = []
    var filteredPoseListIntermediate: [Pose] = []
    var filteredPoseListAdvance: [Pose] = []
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupPoseList()
        setupSearchBar()
    }
    
    // View did appear
    override func viewDidAppear(_ animated: Bool) {
        
        // If just gotten achievement, reload table
        if (UserDefaults.standard.bool(forKey: "tableViewReload")) {
            setupPoseList()
            UserDefaults.standard.set(false, forKey: "tableViewReload")
        }
        
        addProfileImage()
        
        // Check if user have seen walkthrough guide
        if UserDefaults.standard.bool(forKey: "walkthroughViewed") {
            return
        }
        
        // Show walkthrough guide
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
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
    
    // Search bar
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pose"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // Returns true if user search for something
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // Filtering array list based on searched text
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
     
        filteredPoseListBasic = poseListBasic.filter({( pose : Pose) -> Bool in
            return pose.name.lowercased().contains(searchText.lowercased()) || pose.sanskritName.lowercased().contains(searchText.lowercased())
        })
        filteredPoseListIntermediate = poseListIntermediate.filter({( pose : Pose) -> Bool in
            return pose.name.lowercased().contains(searchText.lowercased()) ||
                pose.sanskritName.lowercased().contains(searchText.lowercased())
        })
        filteredPoseListAdvance = poseListAdvance.filter({( pose : Pose) -> Bool in
            return pose.name.lowercased().contains(searchText.lowercased()) ||
                pose.sanskritName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    // Fill poseLists with data from Firebase
    func setupPoseList() {
        DataManagerSugi.getPoseList(UserDefaults.standard.string(forKey: "userAutoId")!) {
            (basicPose, intermediatePose, advancePose) in
            self.poseListBasic = basicPose
            self.poseListIntermediate = intermediatePose
            self.poseListAdvance = advancePose
            self.tableView.reloadData()
        }
    }
    
    // Table view Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Filtered
        if isFiltering() {
            
            if (section == 0) {
                return filteredPoseListBasic.count
            } else if (section == 1) {
                return filteredPoseListIntermediate.count
            } else {
                return filteredPoseListAdvance.count
            }
        } else { // Non-filtered
            
            if (section == 0) {
                return poseListBasic.count
            } else if (section == 1) {
                return poseListIntermediate.count
            } else {
                return poseListAdvance.count
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: YogaTableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! YogaTableViewCell
        
        var object: Pose
        
        // Filtered
        if isFiltering() {
            
            if (indexPath.section == 0) {
                object = filteredPoseListBasic[indexPath.row]
            } else if (indexPath.section == 1) {
                object = filteredPoseListIntermediate[indexPath.row]
            } else {
                object = filteredPoseListAdvance[indexPath.row]
            }
        } else { // Non-filtered
            
            if (indexPath.section == 0) {
                object = poseListBasic[indexPath.row]
            } else if (indexPath.section == 1) {
                object = poseListIntermediate[indexPath.row]
            } else {
                object = poseListAdvance[indexPath.row]
            }
        }
        
        cell.tableName.text = object.name
        cell.tableSanskritName.text = object.sanskritName
        cell.tableImage.image = UIImage(named: object.imageName)
        
        return cell
    }

    // Table view Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == 0) {
            return "Basic"
        } else if (section == 1) {
            return "Intermediate"
        } else {
            return "Advance"
        }
    }
    
    // Remove grey color cell after selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Go to profile page
    @objc func profileImagePressed(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goProfile", sender:nil)
    }
    
    // Go to camera page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCamera"
        {
            let cameraVC = segue.destination as! CameraViewController
            
            let selectedRow = tableView.indexPathForSelectedRow
            
            var pose : Pose
            
            if selectedRow != nil {
                if (selectedRow!.section == 0) {
                    pose = poseListBasic[(selectedRow!.row)]
                } else if (selectedRow!.section == 1) {
                    pose = poseListIntermediate[(selectedRow!.row)]
                } else {
                    pose = poseListAdvance[(selectedRow!.row)]
                }
                
                cameraVC.pose = pose
            }
        }
    }

}
