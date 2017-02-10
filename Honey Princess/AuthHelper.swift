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

typealias LoginHandler = (_ message: String?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email address, please provide a valid email address."
    static let WRONG_PASSWORD = "Wrong password. Please enter the correct password."
    static let PROBLEM_CONNECTING = "Problem connecting to database. Please try again later."
    static let USER_NOT_FOUND = "User not found. Please register."
    static let EMAIL_ALREADY_IN_USE = "Email is already in use."
    static let WEAK_PASSWORD = "Password must be at least 6 characters long."
}


class AuthHelper {
    
    
    //MARK: - Properties
    private static let _instance = AuthHelper()
    
    static var Instance: AuthHelper {
        return _instance
    }
    
    func logIn(email: String, password: String, loginHandler: LoginHandler?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleErrors(error: error as! NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
        })
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
                        
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        data["picture"] = downloadUrl as AnyObject?
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
    
    func register(email: String, name: String, password: String, loginHandler: LoginHandler?){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("Error creating user \(error)")
                self.handleErrors(error: error as! NSError, loginHandler: loginHandler)
            } else {
                if user?.uid != nil {
                    
                    
                    var data = [String: AnyObject]()
                    data["email"] = email as String as AnyObject?
                    data["name"] = name as String as AnyObject?
                    DatabaseHelper.Instance.saveUser(uid: user!.uid, data: data)
                    
                    self.logIn(email: email, password: password, loginHandler: loginHandler)
                }
            }
        })
    }

    
    private func handleErrors(error: NSError, loginHandler: LoginHandler?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            
            switch errorCode {
            case .errorCodeWrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
            case .errorCodeInvalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
            case .errorCodeUserNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
            case .errorCodeWeakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
            }
        }
        
    }
}
