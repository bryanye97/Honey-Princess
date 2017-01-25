//
//  MapViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let status = CLLocationManager.authorizationStatus()
    var circleRenderer = MKCircleRenderer()
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMapView()
        prepareLocationManager()
        checkLocationStatus()
    }
    
    // MARK: - Preparations
    func prepareMapView() {
        mapView.delegate = self
    }
    
    func prepareLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func checkLocationStatus() {
        guard status != .restricted || status != .denied else { return }
        
        guard status != .notDetermined else {
            locationManager.requestLocation()
            return
        }
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            print("Location Authorized by User")
        }
        
    }
    
    func setupCircleOverlay(userLocation: CLLocationCoordinate2D) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let regionRadius = 300.0
            let circle = MKCircle(center: userLocation , radius: regionRadius)
            if mapView.overlays.count == 0 {
                mapView.add(circle)
            }
        }
        else {
            print("System can't track regions")
        }
    }

}

extension MapViewController: MKMapViewDelegate {
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        let location = locations.last
        
        guard location != nil else { return }
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        setupCircleOverlay(userLocation: center)

//        UserConstants.currentUser.location = center
//        UserConstants.currentUser.time = Int(TimeHelper.getTimeStamp())
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:\(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = mapView.tintColor
        circleRenderer.fillColor = mapView.tintColor.withAlphaComponent(0.1)
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
}
