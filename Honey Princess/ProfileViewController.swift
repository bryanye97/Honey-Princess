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
    
    //MARK: - IBOutlets
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profileImageView
    : UIImageView!
    
    //MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    //    func lol() {
    //        if let user = FIRAuth.auth()?.currentUser {
    //            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
    //            self.profileImageView.clipsToBounds = true
    //
    //            let name = user.displayName
    ////            let email = user.email
    //            let photoUrl = user.photoURL
    ////            let uid = user.uid
    //
    //            self.displayNameLabel.text = name
    //
    //            let data = NSData(contentsOf: photoUrl!)
    //            self.profileImageView.image = UIImage(data: data! as Data)
    //        }
    //
    //    }
    
    func setupViews() {
        if AuthHelper.Instance.isLoggedIn() {
            let uid = AuthHelper.Instance.idForCurrentUser()
            DatabaseHelper.Instance.fetchSingleUserDelegate = self
            DatabaseHelper.Instance.getUserForUid(uid: uid)
            
        }
        
        circleImageView()
    }
    
    func circleImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        self.profileImageView.clipsToBounds = true
    }
}

extension ProfileViewController: FetchSingleUser {
    func dataReceived(user: User) {
        displayNameLabel.text = user.name
        guard user.profilePicture != "" else { return }
        let url = URL(string: user.profilePicture)
        let request = NSMutableURLRequest(url: url!)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            
            print(data)
            
            self.profileImageView.image = UIImage(data: data!)

        }.resume()
            
        
    }
}
