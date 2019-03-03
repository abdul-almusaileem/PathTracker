//
//  Path.swift
//  Path Tracker
//
//  Created by Abdul Almusaileem on 11/20/18.
//  Copyright © 2018 Abdul Almusaileem. All rights reserved.
//

// this is a class Path
// this class sotres:
// the walked path to repam the path
// number of steps
// distance
// MAYBE (distance walekd only)
// the date that these data were recorded
//

import Foundation
import CoreLocation
//import RealmSwift

//
//
class Path/*: Object*/ {
    
    // declare used data
    //
    /*@objc dynamic*/ var pathName: String = ""
    var walkedPath: [CLLocation] = [] // walkaround an array for realm
    /*@objc dynamic*/ var numSteps: Double = 0.0
    /*@objc dynamic*/ var distance: Double = 0.0
   /* @objc dynamic*/ var date: Date = Date()
    
    /*convenience */init(name: String = "" ,path: [CLLocation], steps: Double, distance: Double) {
        //self.init()
        self.numSteps = steps
        self.distance = distance
        self.walkedPath = path
        self.pathName = name
        
        // initialized date
        //
        let todaysDate = Date()
        self.date = todaysDate
    }
    
   

    
    
    // TODO: add method to change path
    //
    
    
    // this method resets the path
    //
    func resetPath() {
        pathName = ""
        walkedPath = [] //List<Location>()
        numSteps = 0
        distance = 0
        //date = Date()
    }
    
}

// MARK:- location class
//

class Location/*: Object*/ {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var location: CLLocation?
    
    /// Computed properties are ignored in Realm
    //
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
}

