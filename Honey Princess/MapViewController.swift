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
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMapView()
        prepareLocationManager()
        checkLocationStatus()
        prepareSearchBar()
        
//        geocoder.geocodeAddressString("1 Infinite Loop, CA, USA") { (placemarks: [CLPlacemark]?, error: Error?) in
//            print(placemarks?.first?.location)
//        }
//        
//        let pin = EventAnnotation(title: "hey", subtitle: "subtitle here", coordinate: CLLocationCoordinate2D(latitude: 37.787359, longitude: -122.408227))
//        mapView.addAnnotation(pin)
        
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
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
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

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let title = placemark.name
        var subtitle: String?
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            subtitle = "\(city) \(state)"
        }
        let coordinate = placemark.coordinate
        print("\(coordinate.latitude) \(coordinate.longitude)")
        
        let annotation = EventAnnotation(title: title!, subtitle: subtitle!, coordinate: coordinate)
        
        mapView.addAnnotation(annotation)
        EventHandler.Instance.uploadEvent(title: title!, subtitle: subtitle!, coordinate: coordinate)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


