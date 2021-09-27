//
//  RegisterViewController.swift
//  iLyfe
//
//  Created by Sugianto on 8/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextLabel: UITextField!
    @IBOutlet weak var passwordTextLabel: UITextField!
    @IBOutlet weak var nameTextLabel: UITextField!
    @IBOutlet weak var errorMessageForEmail: UILabel!
    @IBOutlet weak var errorMessageForPassword: UILabel!
    @IBOutlet weak var errorMessageForName: UILabel!
    
    @IBOutlet weak var topPassToEmailConstraint: NSLayoutConstraint!
    @IBOutlet weak var topNameToPassConstraint: NSLayoutConstraint!
        
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextLabel.delegate = self
        passwordTextLabel.delegate = self
        nameTextLabel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // Changing the UIPage up depending on the keyboard
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    // All keyboard "return" button close keyboard
    func hideKeyboard() {
        emailTextLabel.resignFirstResponder()
        passwordTextLabel.resignFirstResponder()
        nameTextLabel.resignFirstResponder()
    }
    
    // Keyboard "return" button close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // View did appear
    override func viewDidAppear(_ animated: Bool) {
        // Reset error message
        resetErrorMessage()
    }
    
    // When Sign Up button is pressed
    @IBAction func signUp(_ sender: Any) {
        
        // Reset error message
        resetErrorMessage()
        
        if emailTextLabel.text! == "" {
            errorMessageForEmail.text = "Please enter a valid email address."
            showEmailError()
            
        }
        if passwordTextLabel.text! == "" {
            errorMessageForPassword.text = "Please enter a password."
            showPasswordError()
            
        }
        if nameTextLabel.text! == "" {
            errorMessageForName.text = "Please enter a name."
            showNameError()
            
        }
        if emailTextLabel.text! != "" && passwordTextLabel.text! != "" && nameTextLabel.text! != ""{
            Auth.auth().createUser(withEmail: emailTextLabel.text!, password: passwordTextLabel.text!.trimmingCharacters(in: .whitespaces)) {
                (user, error) in
                if error == nil {
                    // Successful Create Account
                    // Remove all keyboard
                    self.hideKeyboard()
                    
                    // Add user to Firebase
                    DataManagerSugi.addUser(self.emailTextLabel.text!, self.nameTextLabel.text!)
                    
                    // Show alert
                    self.createAlert("Account Created", "You have successfully signed up.")
                    
                } else if error!.localizedDescription == "The email address is badly formatted." {
                    self.errorMessageForEmail.text = "Please enter a valid email address."
                    self.showEmailError()
                    
                } else if error!.localizedDescription == "The password must be 6 characters long or more." {
                    self.errorMessageForPassword.text = "The password must be 6 characters long or more."
                    self.showPasswordError()
                    
                } else if error!.localizedDescription == "The email address is already in use by another account." {
                    self.errorMessageForEmail.text = "The email address is already in use."
                    self.showEmailError()
                    
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    // Set error for Email Text Label
    func showEmailError() {
        errorMessageForEmail.isHidden = false
        emailTextLabel.layer.borderWidth = 1
        emailTextLabel.layer.cornerRadius = 5
        emailTextLabel.layer.borderColor = UIColor.red.cgColor
    }
    
    // Set error for Password Text Label
    func showPasswordError() {
        errorMessageForPassword.isHidden = false
        topPassToEmailConstraint.constant = 41
        passwordTextLabel.layer.borderWidth = 1
        passwordTextLabel.layer.cornerRadius = 5
        passwordTextLabel.layer.borderColor = UIColor.red.cgColor
    }
    
    // Set error for Confirm Password Text Label
    func showNameError() {
        errorMessageForName.isHidden = false
        topNameToPassConstraint.constant = 41
        nameTextLabel.layer.borderWidth = 1
        nameTextLabel.layer.cornerRadius = 5
        nameTextLabel.layer.borderColor = UIColor.red.cgColor
        
    }
    
    // Reset error message
    func resetErrorMessage() {
        errorMessageForEmail.isHidden = true
        emailTextLabel.layer.borderWidth = 0
        errorMessageForPassword.isHidden = true
        topPassToEmailConstraint.constant = 20
        passwordTextLabel.layer.borderWidth = 0
        errorMessageForName.isHidden = true
        topNameToPassConstraint.constant = 20
        nameTextLabel.layer.borderWidth = 0
    }
    
    // Create an alert
    func createAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action) in
            alert.dismiss(animated: true, completion: nil)
            // Go to Login Page
            self.backToLogin3()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Back to Login Page when backButton is pressed
    @IBAction func backToLogin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Back to Login Page
    @IBAction func backToLogin2(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Back to Login Page
    func backToLogin3() {
        dismiss(animated: true, completion: nil)
    }
    
}
