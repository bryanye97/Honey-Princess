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
import FirebaseStorage

class LoginViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var prineyLogo: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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

        
        customFBButton.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 75).isActive = true
        customFBButton.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor, constant: 0).isActive = true
        customFBButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 16).isActive = true
        customFBButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -16).isActive = true
        customFBButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func handleCustomFBLogin() {
        let readPermissions = ["email", "public_profile"]
        FBSDKLoginManager().logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
            if error != nil {
                print("Custom Facebook Login Failed: \(error)")
                return
            }
            
            self.logInWithFacebook()
        }
    }
    
    func logInWithFacebook() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: \(error)")
                return
            }
            
            guard let uid = user?.uid else { return }
            
            let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture"])
            
            graphRequest.start(completionHandler: { (connection, result, error) in
                var data: [String:AnyObject] = result as! [String : AnyObject]
                
                let storage = FIRStorage.storage()
                let storageRef = storage.reference(forURL: "gs://honey-princess.appspot.com")
                
                print(data)
                let pictureDictionary = data["picture"] as! [String: AnyObject]
                let pictureData = pictureDictionary["data"] as! [String: AnyObject]
                let urlForPicture = pictureData["url"] as! String
                
                if let imageData = NSData(contentsOf: NSURL(string: urlForPicture) as! URL) {
                    let profilePicRef = storageRef.child(uid + "/profile_pic.jpg")
                    _ = profilePicRef.put(imageData as Data, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print("Error uploading profile picture: \(error)")
                            return
                        }
                        
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        data["picture"] = downloadUrl as AnyObject?
                        DatabaseHelper.Instance.saveUser(uid: uid, data: data)
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
                
            })
        })
    }
    
    //MARK: - IBActions
    
    @IBAction func login(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if email != "" && password != "" {
            
            AuthHelper.Instance.logIn(email: email, password: password, loginHandler: { (message) in
                
                if message != nil {
                    self.alertUser(title: "Problem with Authentication", message: message!)
                } else {
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    print("Logging in")
                    self.dismiss(animated: true, completion: nil)
                }
            })
        } else {
            alertUser(title: "Email and Password are required.", message: "Please enter email and password in the fields")
        }
    }

    @IBAction func signUp(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    private func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    

}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Successfully logged out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error logging in \(error)")
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
}
