//
//  ProfileViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 27/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profileImageView
    : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lol()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lol() {
        if let user = FIRAuth.auth()?.currentUser {
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
            self.profileImageView.clipsToBounds = true
            
            let name = user.displayName
//            let email = user.email
            let photoUrl = user.photoURL
//            let uid = user.uid
            
            self.displayNameLabel.text = name
            
            let data = NSData(contentsOf: photoUrl!)
            self.profileImageView.image = UIImage(data: data! as Data)
        } else {
            
        }
        
    }
}
