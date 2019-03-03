//
//  ViewController.swift
//  Path Tracker
//
//  Created by Abdul Almusaileem on 11/10/18.
//  Copyright © 2018 Abdul Almusaileem. All rights reserved.
//

// TODO: add a COREMOTION
// TODO: use core data
//

import UIKit
import MapKit
import CoreLocation


// extentions
//


// extend Integer class to have abelity to convert numbers from dgrees to radian
//
extension BinaryInteger {
    var degreesToRad: CGFloat {return CGFloat(Int(self)) / .pi * 180}
}

// extend the Float data type to be able to convert from degrees to radian and reverce
//
extension FloatingPoint {
    var degreesToRad: Self {return self * .pi / 180 }
    var radToDegrees: Self {return self * 180 / .pi}
}


//
//
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    

    // outlets
    //
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distaceLbl: UILabel!
    @IBOutlet weak var currentLocationBtn: UIButton!
    @IBOutlet weak var activityLabel: UILabel!
    
    
    // objects
    //
    var locationManager: CLLocationManager!
    var pedometer: Pedometer!

    var currentPath: Path!

    
    // used vars
    //
    var startLocation: CLLocation!
    var endLocation: CLLocation!
    var startDate: Date!
    
    
    
    var distanceWalked: Double = 0.0
    var walkedPath: [CLLocation] = []
    
    var numSteps: Double = 0.0
    var pace: Double = 0.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a navi bar button
        //
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(load_history))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(load_setting))
        
        // UI changes
        //
        distaceLbl.font = UIFont.boldSystemFont(ofSize: 16)
        
        // authinticat the pedometer
        //
        startDate = Date()
        pedometer = Pedometer(numSteps: numSteps, startDate: startDate, activity: activityLabel.text!)
        pedometer.Authorize()
        
        // map access auth
        //
        MapsAuthrize()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // to make the reset once path is added to the db
        
    }

    
    
    
    // checks if the user's location was updated
    //
    //
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // sets the curretn location to the last location added to the location list
        //
        let currentLocation: CLLocation = locations[locations.count - 1]
        
        // set the starting location
        //
        if startLocation == nil{
            startLocation = currentLocation
        }
    
        // add the new location to the path if it was less than 50m
        // if not add the previos location to the path again
        //
        if (currentLocation.horizontalAccuracy > 0  && currentLocation.horizontalAccuracy < 50) {
             walkedPath.append(currentLocation)
        }
        else {
            if !(walkedPath.count <= 1) {
                walkedPath.append(walkedPath[walkedPath.count - 1])
            }
        }
       
        //
        //
        if !(walkedPath.count <= 1) {
            
            if let lastLocation = walkedPath[walkedPath.count - 1]  as CLLocation? {
                let oldCoordinant = lastLocation.coordinate
                let currentCoordinate = currentLocation.coordinate
                
                // the area ?
                //
                var area = [oldCoordinant, currentCoordinate]
                // updates the path on the map
                //
                let path = MKPolyline(coordinates: &area, count: area.count)
                
                // aplay the drown path to the map
                //
                mapView.addOverlay(path)
            }
        }
        else{
            print("i didn't move...")
        }
 
        // update the distance and pedometer data
        //
        if !(walkedPath.count <= 1) {
            distanceWalked = updateDistance(walkedDistance: distanceWalked, startingPoint: startLocation, lastPoint: walkedPath[walkedPath.count - 1])
            pedometer.Update()
            
        }
        
        //
        //
        currentPath = Path(path: walkedPath, steps: pedometer.numSteps, distance: distanceWalked)
        
        updateUI(currentPath: currentPath, pedometer: pedometer)
    }
    
    
    // this method create a path that could be overlayed on the mapview
    //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //
        //
        let line = MKPolylineRenderer(overlay: overlay)
        
        // check how the user is moving
        // if the user is running or walking draw the path with red line
        // if the user is driving draw the path with blue line
        // other than that draw a path with gray line
        //
        if (overlay is MKPolyline) {
            if pedometer.activity == "🚶🏾‍♂️" || pedometer.activity == "🏃🏾‍♂️" {
                line.strokeColor = UIColor.red
                line.lineWidth = 3
                return line
            }
            else if pedometer.activity == "🚙" {
                line.strokeColor = UIColor.blue
                line.lineWidth = 3
                return line
            }
            else {
                line.strokeColor = UIColor.gray
                line.lineWidth = 3
                return line
            }
        }
        
        return line
    }
 
    
    // MARK:- distanceCalc
    
    // this method calculates the distance that the user walked on each step
    // this method also updates the distance label
    //
    func updateDistance(walkedDistance: Double, startingPoint: CLLocation, lastPoint: CLLocation) -> Double {
       
        // get the ∆ latitude and ∆ longitude
        // and the radiance
        //
        let earthR = 6371e3
        var latitudeDiff = abs(startingPoint.coordinate.latitude - lastPoint.coordinate.latitude)
        var longitudeDiff = abs(startingPoint.coordinate.longitude - lastPoint.coordinate.longitude)
        
        // update the latitude and longitude differences to be in Rad
        //
        latitudeDiff = latitudeDiff.degreesToRad
        longitudeDiff = longitudeDiff.degreesToRad
        
        // math...
        //
        let a = pow(sin(latitudeDiff / 2), 2) + cos(startingPoint.coordinate.latitude) * cos(lastPoint.coordinate.latitude) * pow(sin(longitudeDiff / 2), 2)
        let c = 2 * (pow(atan2(sqrt(a), sqrt((1 - a)) ), 2))
        let distance = c * earthR
        
        let updatedDistance = walkedDistance + distance
        //print(String(format: "Distance: %.3f Km", updatedDistance))
 
        return updatedDistance
    }
    
    
    
    // MARK:- actions
    //
    
    // reset the mapview to the user's current location
    //
    @IBAction func CurrentLocationClicked(_ sender: UIButton) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)

    }
    
    // MARK:- NAVIGATION
    //
    
    // present the history page
    //
    @objc func load_history(btn: UIBarButtonItem) {
        // load the vc
        //
        if let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "history_vc") as? HistoryVC {
            vc.currentPath = currentPath
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // present the setting page
    //
    @objc func load_setting(btn: UIBarButtonItem) {

        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "setting") as? SettingVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK:- Auth
    //
    
    // this method sets up the location maneger and the mapview
    //
    //
    func MapsAuthrize() {
        // setup the locatation maneger obj...?
        //
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        
        // setup the mapview obj
        //
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        // Authorize location services...
        // if the user didn't give location auth
        // alert the user that location is required...
        //
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //
        //
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK:- UI stuff
    //
    
    //
    //
    func updateUI(currentPath: Path, pedometer: Pedometer) {
        activityLabel.text = pedometer.activity
        distaceLbl.text = String(format: "Distance: %.3f Km", currentPath.distance)
        
    }
   
}


