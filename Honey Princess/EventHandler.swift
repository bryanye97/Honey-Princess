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

protocol EventHandlerDelegate: class {
    func eventAdded(title: String, subtitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class EventHandler {
    private static let _instance = EventHandler()
    
    weak var delegate: EventHandlerDelegate?
    
    private init() {
        
    }
    
    static var Instance: EventHandler {
        return _instance
    }
    
    //    func uploadEvent(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
    //        let data: [String: Any] = ["title": title, "subtitle": subtitle, "latitude": coordinate.latitude, "longitude": coordinate.longitude]
    //
    //        DatabaseHelper.Instance.eventsRef.childByAutoId().setValue(data)
    //    }
    
    //    func observeEvents() {
    //        DatabaseHelper.Instance.eventsRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
    //            if let data = snapshot.value as? NSDictionary {
    //                if let title = data["title"] as? String {
    //                    if let subtitle = data["subtitle"] as? String {
    //                        if let latitude = data["latitude"] as? CLLocationDegrees {
    //                            if let longitude = data["longitude"] as? CLLocationDegrees {
    //                                self.delegate?.eventAdded(title: title, subtitle: subtitle, latitude: latitude, longitude: longitude)
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func uploadEvent(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let data: [String: Any] = ["title": title, "subtitle": subtitle, "latitude": coordinate.latitude, "longitude": coordinate.longitude]
        DatabaseHelper.Instance.getCoupleKeyForCurrentUser { (couplesKey: String) in
            DatabaseHelper.Instance.couplesRef.child(couplesKey).child("events").childByAutoId().setValue(data)
        }
    }
    
    func observeEventsForCurrentUser() {
        DatabaseHelper.Instance.getCoupleKeyForCurrentUser { (couplesKey: String) in
            print(couplesKey)
            DatabaseHelper.Instance.couplesRef.child(couplesKey).child("events").observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
                //                print(snapshot.value)
                if let data = snapshot.value as? NSDictionary {
                    print(data)
                    if let title = data["title"] as? String {
                        if let subtitle = data["subtitle"] as? String {
                            if let latitude = data["latitude"] as? CLLocationDegrees {
                                if let longitude = data["longitude"] as? CLLocationDegrees {
                                    self.delegate?.eventAdded(title: title, subtitle: subtitle, latitude: latitude, longitude: longitude)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
//    func observeEvents() {
//        DatabaseHelper.Instance.getCoupleKeyForCurrentUser { (couplesKey: String) in
//            print(couplesKey)
//            DatabaseHelper.Instance.couplesRef.child(couplesKey).child("events").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot: FIRDataSnapshot) in
//                print(snapshot)
//            })
//        }
//    }
//    
}
