//
//  EventAnnotation.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import MapKit

class EventAnnotation: NSObject, MKAnnotation {
    let title: String?
    var subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    

}
