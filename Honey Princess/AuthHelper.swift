//
//  AuthHelper.swift
//  Honey Princess
//
//  Created by Bryan Ye on 26/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit

class AuthHelper {
    
    private static let _instance = AuthHelper()
    
    static var Instance: AuthHelper {
        return _instance
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
            print("Successfully logged in with our user \(user)")
        })
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
    
    func logOutOfFacebook() {
        FBSDKAccessToken.setCurrent(nil)
    }
    

}
