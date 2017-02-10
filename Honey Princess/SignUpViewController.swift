//
//  SignUpViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 10/2/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUp(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        guard let name = nameTextField.text else { return }
        
        if email != "" && password != "" && name != "" {
            AuthHelper.Instance.register(email: email, name: name, password: password, loginHandler: { (message) in
                if message != nil {
                    self.alertUser(title: "Problem Creating New User", message: message!)
                } else {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.nameTextField.text = ""
                    
                    print("Logging in")
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        } else {
            alertUser(title: "Email and Password are required.", message: "Please enter email and password in the fields")
        }

    }
    
    private func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}
