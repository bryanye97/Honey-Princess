//
//  ProfileViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 27/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    //MARK: - Properties
    var user: User?
    var userIsInACouple: Bool?
    
    //MARK: - IBOutlets
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profileImageView
    : UIImageView!
    
    //MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()

    }
    
    
    //MARK: - Preparations
    func setupViews() {
        print(AuthHelper.Instance.isLoggedIn())
        if AuthHelper.Instance.isLoggedIn() {
            let uid = AuthHelper.Instance.idForCurrentUser()
            DatabaseHelper.Instance.fetchSingleUserDelegate = self
            DatabaseHelper.Instance.getUserForUid(uid: uid)
        }
        
        setupProfileImageView()
    }
    
    func setupProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        self.profileImageView.layer.borderColor = UIColor.lightGrayBorder().cgColor
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.clipsToBounds = true

    }
    
    //MARK: - IBActions
    @IBAction func matchWithAnotherUser(_ sender: UIButton) {
        DatabaseHelper.Instance.doesCouplesKeyExistForCurrentUser(completionHandler: { (doesCouplesKeyExist) in
            self.userIsInACouple = doesCouplesKeyExist
            guard self.userIsInACouple != nil else { return }
            if self.userIsInACouple! {
                self.alertUser(title: "Warning", message: "You Are Already In A Couple")
            } else {
                self.performSegue(withIdentifier: "showUsers", sender: nil)
            }
        })
        
    }
    
    @IBAction func logout(_ sender: UIButton) {
        if AuthHelper.Instance.logOut() {
            print("logged out")
            AuthHelper.Instance.logOutOfFacebook()
            showLoginScreen()
        }
    }
    
    //MARK: - Logout Helpers
    func showLoginScreen() {
        let appDelegateTemp = UIApplication.shared.delegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        appDelegateTemp?.window??.makeKeyAndVisible()
        
        appDelegateTemp?.window??.rootViewController?.present(loginViewController, animated: true, completion: nil)
    }
    
    //MARK: - Alert User
    private func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}

extension ProfileViewController: FetchSingleUser {
    func dataReceived(user: User) {
        displayNameLabel.text = user.name
        guard user.profilePicture != "" else { return }
//        let url = URL(string: user.profilePicture)
//        let request = NSMutableURLRequest(url: url!)
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            if error != nil {
//                print("Error Downloading Profile Picture: \(error)")
//                return
//            }
//            
//            print("Profile Picture Data: \(data)")
//            
//            self.profileImageView.image = UIImage(data: data!)
//
//        }.resume()
            
        
    }
}
