//
//  MapViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 25/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController {
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let status = CLLocationManager.authorizationStatus()
    var circleRenderer = MKCircleRenderer()
    let geocoder = CLGeocoder()
    var resultSearchController: UISearchController?
    var selectedPin: MKPlacemark?
    var userIsInCouple: Bool?
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMapView()
        prepareLocationManager()
        checkLocationStatus()
        prepareSearchBar()
        prepareEventHandler()
    }
    
    
    
    // MARK: - Preparations
    func prepareMapView() {
        mapView.delegate = self
        mapView.tintColor = .honeyPrincessGold()
    }
    
    func prepareEventHandler() {
        EventHandler.Instance.delegate = self
        
        DatabaseHelper.Instance.doesCouplesKeyExistForCurrentUser(completionHandler: { (couplesKeyExists: Bool) in
            self.userIsInCouple = couplesKeyExists
            guard self.userIsInCouple != nil else { return }
            if self.userIsInCouple! {
        
                EventHandler.Instance.observeEventsForCurrentUser()
            } else {
                self.alertUser(title: "Sorry", message: "You Aren't In A Couple")
            }
        })
    }
    
    func prepareLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    func prepareSearchBar() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearch") as! LocationSearchViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
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
    
    //MARK: - Get Directions
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    //MARK: - IBActions
    @IBAction func recenterMap(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Alert User
    private func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = .honeyPrincessOrange()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "Icon-Original"), for: .normal)
        button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        print(locations)
        
        let location = locations.last
        
        guard location != nil else { return }
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        setupCircleOverlay(userLocation: center)
        
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

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        //        mapView.removeAnnotations(mapView.annotations)
        let title = placemark.name
        var subtitle: String?
        
        let alertController = UIAlertController(title: "What Did We Do Here?", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            
            subtitle = alertController.textFields?.first?.text
            
            let coordinate = placemark.coordinate
            print("\(coordinate.latitude) \(coordinate.longitude)")
            
            let annotation = EventAnnotation(title: title!, subtitle: subtitle ?? "", coordinate: coordinate)
            
            self.mapView.addAnnotation(annotation)
            print(AuthHelper.Instance.isLoggedIn())
            EventHandler.Instance.uploadEvent(title: title!, subtitle: subtitle!, coordinate: coordinate)
            
            let region = MKCoordinateRegionMake(placemark.coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.cancel,
                                         handler: nil)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Insert Activity Here"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MapViewController: EventHandlerDelegate {
    func eventAdded(title: String, subtitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let event = EventAnnotation(title: title, subtitle: subtitle, coordinate: coordinate)
        mapView.addAnnotation(event)
    }
}


