//
//  ModesViewController.swift
//  iLyfe
//
//  Created by JT on 12/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class ModesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    let modes = ["Easy", "Medium", "Difficult"]
    @IBOutlet weak var tableView: UITableView!
    
    var json:JSON?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Mode"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModeCell", for: indexPath)
        let showMode = modes[indexPath.row]
        cell.textLabel?.text = showMode
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modeInstruct"
        {
            let dest = segue.destination as! InstructionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            if indexPath != nil {
                let myMode = modes[indexPath!.row]
                dest.mode = myMode
                dest.myRegion = textPicker.text
            }
        }
    }
    
    @IBOutlet weak var textPicker: UITextField!
    
    var pv:UIPickerView! = UIPickerView()
    var regionList:[String] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let regionItem = regionList[row]
        return regionItem
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textPicker.text = regionList[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textPicker.delegate = self
        self.navigationItem.title = "Mode"
        
        //append all regions from json file to display in the picker view
        let url = Bundle.main.url(forResource: "SGplace", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        json = try? JSON(data: data!)
        
        for (key, value) in json!
        {
            regionList.append(key)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //show toolbar and picker view
        pv.delegate = self
        pv.dataSource = self
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        
        toolbar.setItems([doneBtn, cancelBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textPicker.inputView = pv
        textPicker.inputAccessoryView = toolbar
    }
    
    @objc func donePressed()
    {
        let indexPath = pv.selectedRow(inComponent: 0)
        if indexPath != nil
        {
            textPicker.text = regionList[indexPath]
        }
        textPicker.endEditing(true)
        textPicker.inputView = nil
    }
    
    @objc func cancelPressed()
    {
        textPicker.endEditing(true)
        textPicker.inputView = nil
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
