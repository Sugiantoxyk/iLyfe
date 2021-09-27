//
//  LoginViewController.swift
//  iLyfe
//
//  Created by Sugianto on 8/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageForEmail: UILabel!
    @IBOutlet weak var errorMessageForPassword: UILabel!
    
    @IBOutlet weak var topPassToEmailConstraint: NSLayoutConstraint!
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
    
    // Keyboard "return" button close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // View did appear
    override func viewDidAppear(_ animated: Bool) {
        
        // Reset error message
        resetErrorMessage()
        
        // If user is Logged in
        if (UserDefaults.standard.bool(forKey: "isLoggedIn")) {
            self.performSegue(withIdentifier: "toMainPage", sender:nil)
        } else {
            return
        }
    }

    // When "Log In" button is pressed
    @IBAction func loggingIn(_ sender: Any) {
        
        // Reset error message
        resetErrorMessage()
        
        if emailTextField.text == "" {
            errorMessageForEmail.text = "Please enter a valid email address."
            showEmailError()
            
        }
        if passwordTextField.text == "" {
            errorMessageForPassword.text = "Please enter a password."
            showPasswordError()
            
        }
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {
                (user, error) in
                if error == nil {
                    // Successful Login
                    let emailLoggedIn = self.emailTextField.text
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    DataManagerSugi.retrieveUserId(emailLoggedIn!, onComplete: {
                        (autoId) in
                        UserDefaults.standard.set(autoId, forKey: "userAutoId")
                        self.performSegue(withIdentifier: "toMainPage", sender:nil)
                    })
                    
                } else if error!.localizedDescription == "The email address is badly formatted." {
                    self.errorMessageForEmail.text = "Please enter a valid email address."
                    self.showEmailError()
                    
                } else if error!.localizedDescription == "The password is invalid or the user does not have a password." || error!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    self.errorMessageForEmail.text = "Your email or password was entered incorrectly."
                    self.showErrorLoginIn()
                    
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    // Set error for both Text Label
    func showErrorLoginIn() {
        errorMessageForEmail.isHidden = false
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderColor = UIColor.red.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = UIColor.red.cgColor
    }
    
    // Set error for Email Text Label
    func showEmailError() {
        errorMessageForEmail.isHidden = false
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderColor = UIColor.red.cgColor
    }
    
    // Set error for Password Text Label
    func showPasswordError() {
        errorMessageForPassword.isHidden = false
        topPassToEmailConstraint.constant = 41
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = UIColor.red.cgColor
    }
    
    // Reset error message
    func resetErrorMessage() {
        errorMessageForEmail.isHidden = true
        emailTextField.layer.borderWidth = 0
        errorMessageForPassword.isHidden = true
        topPassToEmailConstraint.constant = 20
        passwordTextField.layer.borderWidth = 0
    }
    
}
