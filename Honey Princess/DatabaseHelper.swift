//
//  DatabaseHelper.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseHelper {
    
    private static let _instance = DatabaseHelper()
    
    private init () { }
    
    static var Instance: DatabaseHelper {
        return _instance
    }
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var eventsRef: FIRDatabaseReference {
        return databaseRef.child("Events")
    }
    
}
