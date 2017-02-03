//
//  AuthHelper.swift
//  Honey Princess
//
//  Created by Bryan Ye on 26/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class AuthHelper {
    
    
    //MARK: - Properties
    private static let _instance = AuthHelper()
    
    static var Instance: AuthHelper {
        return _instance
    }
    
    
    //MARK - Facebook Functions
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
                        
                        let downloadUrl = metadata?.downloadURL()
                        data["picture"] = downloadUrl?.path as AnyObject?
                        DatabaseHelper.Instance.saveUser(uid: uid, data: data)
                    })
                    
                }

            })
        })
    }
    
    func logOutOfFacebook() {
        FBSDKAccessToken.setCurrent(nil)
    }
    
    
    //MARK - Firebase User Functions
    func idForCurrentUser() -> String {
        if isLoggedIn() {
           return (FIRAuth.auth()?.currentUser?.uid)!
        } else {
            return ""
        }
    }

    
    func isLoggedIn() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func logOut() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                return true
            } catch {
                return false
            }
        }
        return true
    }
}
