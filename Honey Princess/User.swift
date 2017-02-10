//
//  User.swift
//  Honey Princess
//
//  Created by Bryan Ye on 27/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation

class User {
    private var _firebaseId = ""
    private var _facebookId = ""
    private var _name = ""
    private var _email = ""
    private var _profilePicture = ""
    
    init(firebaseId: String, name: String, email: String) {
        _firebaseId = firebaseId
        _name = name
        _email = email
    }
    
    var name: String {
        return _name
    }
    
    var firebaseId: String {
        return _firebaseId
    }
    
    var facebookId: String? {
        return _facebookId
    }
    
    var email: String {
        return _email
    }
    
    var profilePicture: String? {
        return _profilePicture
    }
}
