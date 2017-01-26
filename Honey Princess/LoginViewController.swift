//
//  LoginViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 26/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFacebookLoginButton()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Preparations
    func setupFacebookLoginButton() {
        
        let fbLoginButton = FBSDKLoginButton()
        view.addSubview(fbLoginButton)
        fbLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
        
        let customFBButton = UIButton()
        customFBButton.backgroundColor = .orange
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func handleCustomFBLogin() {
        let readPermissions = ["email", "public_profile"]
        FBSDKLoginManager().logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
            if error != nil {
                print("Custom Facebook Login Failed: \(error)")
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    //MARK: - Show Email Address
    func showEmailAddress() {
        AuthHelper.Instance.logInWithFacebook()
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print("Failed to start graph request: \(error)")
                return
            }
            
            print(result ?? "")
        }
        
    }
    
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Successfully logged out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        dismiss(animated: true, completion: nil)
    }
}
