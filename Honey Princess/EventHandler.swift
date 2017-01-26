//
//  EventHandler.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class EventHandler {
    private static let _instance = EventHandler()
    
    private init() {
        
    }
    
    static var Instance: EventHandler {
        return _instance
    }
    
    func uploadEvent(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let data: [String: Any] = ["title": title, "subtitle": subtitle, "latitude": coordinate.latitude, "longitude": coordinate.longitude]
        
        DatabaseHelper.Instance.eventsRef.childByAutoId().setValue(data)
    }
}

