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
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var prineyLogo: UIImageView!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFacebookLoginButton()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Preparations
    func setupFacebookLoginButton() {
        
        let customFBButton = UIButton()
        customFBButton.backgroundColor = .honeyPrincessOrange()
        customFBButton.setTitle("Login with Facebook", for: .normal)

        if openSansExists() {
            customFBButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 16)
        } else {
            customFBButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        }
        
        customFBButton.setTitleColor(.white, for: .normal)
        customFBButton.layer.cornerRadius = 10
        
        customFBButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(customFBButton)

        
        customFBButton.bottomAnchor.constraint(equalTo: prineyLogo.bottomAnchor, constant: 50).isActive = true
        customFBButton.centerXAnchor.constraint(equalTo: prineyLogo.centerXAnchor, constant: 0).isActive = true
        customFBButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 16).isActive = true
        customFBButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -16).isActive = true
        customFBButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
//    func setupTextFields(triggerPlaceholder: String, triggerTitle: String, routinePlaceholder: String, routineTitle: String, tintColor: UIColor, selectedTitleColor: UIColor, selectedLineColor: UIColor, textColor: UIColor) {
//        
//        let textFieldWidth: CGFloat = 250
//        let textFieldHeight: CGFloat = 45
//        let textFieldSize = CGSize(width: textFieldWidth, height: textFieldHeight)
//        
//        let middleOfScreenX = view.frame.origin.x + view.frame.size.width/2
//        let middleOfScreenY = view.frame.origin.y + view.frame.size.height/2
//        
//        let triggerTextFieldPoint = CGPoint(x:  middleOfScreenX - textFieldWidth/2, y:  middleOfScreenY - textFieldHeight/2 - 25)
//        
//        let routineTextFieldPoint = CGPoint(x:  middleOfScreenX - textFieldWidth/2, y:  middleOfScreenY - textFieldHeight/2 + 25)
//        
//        let triggerTextFieldRect = CGRect(origin: triggerTextFieldPoint, size: textFieldSize)
//        triggerTextField = SkyFloatingLabelTextField(frame: triggerTextFieldRect)
//        triggerTextField?.placeholder = triggerPlaceholder
//        triggerTextField?.title = triggerTitle
//        triggerTextField?.tintColor = tintColor
//        triggerTextField?.selectedTitleColor = selectedTitleColor
//        triggerTextField?.selectedLineColor = selectedLineColor
//        triggerTextField?.textColor = textColor
//        
//        let routineTextFieldRect = CGRect(origin: routineTextFieldPoint, size: textFieldSize)
//        routineTextField = SkyFloatingLabelTextField(frame: routineTextFieldRect)
//        routineTextField?.placeholder = routinePlaceholder
//        routineTextField?.title = routineTitle
//        routineTextField?.tintColor = tintColor
//        routineTextField?.selectedTitleColor = selectedTitleColor
//        routineTextField?.selectedLineColor = selectedLineColor
//        routineTextField?.textColor = textColor
//        
//        
//        guard triggerTextField != nil else {
//            print("Error producing triggerTextField")
//            return
//        }
//        
//        guard routineTextField != nil else {
//            print("Error producing routineTextField")
//            return
//        }
//        
//        triggerTextField?.delegate = self
//        routineTextField?.delegate = self
//        
//        if let system = system {
//            triggerTextField?.text = system.trigger
//            routineTextField?.text = system.routine
//        } else {
//            triggerTextField?.text = ""
//            routineTextField?.text = ""
//        }
//        
//        self.view.addSubview(triggerTextField!)
//        self.view.addSubview(routineTextField!)
//    }

    
    func handleCustomFBLogin() {
        let readPermissions = ["email", "public_profile"]
        FBSDKLoginManager().logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
            if error != nil {
                print("Custom Facebook Login Failed: \(error)")
                return
            }
            
            AuthHelper.Instance.logInWithFacebook()
            self.dismiss(animated: true, completion: nil)
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
    }
}
