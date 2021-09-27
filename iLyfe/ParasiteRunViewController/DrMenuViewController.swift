//
//  DrMenuViewController.swift
//  iLyfe
//
//  Created by JT on 11/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class DrMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var crimeList:[Crime]?
    
    // For profile pic
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Parasite Run"
        crimeList = CrimeStories.stories()
        
        setupNavigationBar()
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CrimeStories.stories().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CrimeCell", for: indexPath)
        let crimeItem = crimeList![indexPath.row]
        cell.textLabel?.text = crimeItem.title
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: URL(string: crimeItem.imagePath)!)
            DispatchQueue.main.async {
                cell.imageView?.image = UIImage(data: data!)
                cell.layoutSubviews()
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"
        {
            let dest = segue.destination as! ChosenStoryViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            if indexPath != nil
            {
                let storyItem = crimeList![indexPath!.row]
                dest.storyItem = storyItem
            }
        }
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
