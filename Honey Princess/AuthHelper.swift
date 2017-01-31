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
            
            let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"])
            
            graphRequest.start(completionHandler: { (connection, result, error) in
                let data: [String:AnyObject] = result as! [String : AnyObject]
                
                DatabaseHelper.Instance.saveUser(uid: uid, data: data)

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
