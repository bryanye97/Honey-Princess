//
//  DatabaseHelper.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FetchUsers: class {
    func dataReceived(users: [User])
}

protocol FetchSingleUser: class {
    func dataReceived(user: User)
}

class DatabaseHelper {
    
    
    // MARK: - Properties
    private static let _instance = DatabaseHelper()
    
    private init () { }
    
    weak var fetchUsersDelegate: FetchUsers?
    weak var fetchSingleUserDelegate: FetchSingleUser?
    
    static var Instance: DatabaseHelper {
        return _instance
    }
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return databaseRef.child("users")
    }
    
    var eventsRef: FIRDatabaseReference {
        return databaseRef.child("events")
    }
    
    var couplesRef: FIRDatabaseReference {
        return databaseRef.child("couples")
    }
    
    
    //MARK: - User Functions
    func saveUser(uid: String, data: [String: AnyObject]) {
        let userReference = DatabaseHelper.Instance.usersRef.child(uid)
        
        userReference.updateChildValues(data, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            print("Save the user successfully into Firebase database")
        })
        
    }
    
    func getUsers() {
        usersRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            var users = [User]()
            
            if let usersInDatabase = snapshot.value as? NSDictionary {
                
                for (key, value) in usersInDatabase {
                    if let firebaseId = key as? String {
                        if firebaseId != AuthHelper.Instance.idForCurrentUser() {
                            if let userData = value as? NSDictionary {
                                if let email = userData["email"] as? String {
//                                    if let facebookId = userData["id"] as? String {
                                        if let name = userData["name"] as? String {
//                                            if let profilePicture = userData["picture"] as? String {
                                                let user = User(firebaseId: firebaseId, name: name, email: email)
                                                users.append(user)
                                            }
//                                        }
//                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.fetchUsersDelegate?.dataReceived(users: users)
        }
    }
    
    func getSingleUsers() {
        usersRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            var users = [User]()
            
            if let usersInDatabase = snapshot.value as? NSDictionary {
                
                for (key, value) in usersInDatabase {
                    if let firebaseId = key as? String {
                        if firebaseId != AuthHelper.Instance.idForCurrentUser() {
                            if let userData = value as? NSDictionary {
                                print(userData)
                                if userData["couple"] == nil {
                                    if let email = userData["email"] as? String {
//                                        if let facebookId = userData["id"] as? String {
                                            if let name = userData["name"] as? String {
//                                                if let profilePicture = userData["picture"] as? String {
                                                    let user = User(firebaseId: firebaseId,  name: name, email: email)
                                                    users.append(user)
                                                }
                                            }
//                                        }
//                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.fetchUsersDelegate?.dataReceived(users: users)
        }
    }
    
    
    func getUserForUid(uid: String) {
        usersRef.child(uid).observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            if let userData = snapshot.value as? NSDictionary {
                if let email = userData["email"] as? String {
//                    if let facebookId = userData["id"] as? String {
                        if let name = userData["name"] as? String {
//                            if let profilePicture = userData["picture"] as? String {
                                let user = User(firebaseId: uid, name: name, email: email)
                                self.fetchSingleUserDelegate?.dataReceived(user: user)
                            }
                        }
                    }
//                }
//            }
        }
    }
    
    //MARK: - Couple Functions
    func saveCouple (user1id: String, user2id: String) {
        let data: [String: Any] = [user1id: true, user2id: true]
        
        let newCoupleRef = couplesRef.childByAutoId()
        newCoupleRef.setValue(data) { (error, ref) in
            let userData: [String: Any] = ["couple": newCoupleRef.key]
            
            
            let user1Reference = DatabaseHelper.Instance.usersRef.child(user1id)
            let user2Reference = DatabaseHelper.Instance.usersRef.child(user2id)
            
            user1Reference.updateChildValues(userData)
            user2Reference.updateChildValues(userData)
        }
    }
    
    func getCoupleKeyForCurrentUser(completionHandler: @escaping (_ couplesKey: String)-> Void) {
        let currentUserId = AuthHelper.Instance.idForCurrentUser()
        
        usersRef.child(currentUserId).observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            if let userData = snapshot.value as? NSDictionary {
                if let couplesKey = userData["couple"] as? String {
                    completionHandler(couplesKey)
                }
            }
        }
    }
    
    func doesCouplesKeyExistForCurrentUser(completionHandler: @escaping (_ doesCouplesKeyExist: Bool)-> Void) {
        let currentUserId = AuthHelper.Instance.idForCurrentUser()
        
        usersRef.child(currentUserId).observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            if let userData = snapshot.value as? NSDictionary {
                if (userData["couple"] as? String) != nil {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
}

