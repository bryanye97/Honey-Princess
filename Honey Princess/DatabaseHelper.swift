//
//  DatabaseHelper.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FetchData: class {
    func dataReceived(users: [User])
}

class DatabaseHelper {
    
    private static let _instance = DatabaseHelper()
    
    private init () { }
    
    weak var delegate: FetchData?
    
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
            print(snapshot.value)
            if let usersInDatabase = snapshot.value as? NSDictionary {
                
                for (key, value) in usersInDatabase {
                    if let firebaseId = key as? String {
                        if let userData = value as? NSDictionary {
                            if let email = userData["email"] as? String {
                                if let facebookId = userData["id"] as? String {
                                    if let name = userData["name"] as? String {
                                        let user = User(firebaseId: firebaseId, facebookId: facebookId, name: name, email: email)
                                        users.append(user)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
            }
            self.delegate?.dataReceived(users: users)
        }
    }
}
