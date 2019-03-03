//
//  WalkedPathVC.swift
//  
//
//  Created by Abdul Almusaileem on 12/21/18.
//

import UIKit
import MapKit


// MARK:- extentions
//

// to catch indexOutOfRange
//
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


class WalkedPathVC: UIViewController, MKMapViewDelegate{
    
    // outlelts
    //
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var distance_label: UILabel!
    @IBOutlet weak var steps_label: UILabel!
    
    


    //
    //
    //var walkedPath: (name: String, path: Path!) = (name: "", Path(path: [], steps: 0, distance: 0))
    var walkedPath: Path! = Path(path: [], steps: 0, distance: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.delegate = self
        
        print(walkedPath.pathName)
        
        // update the mapvie and the UI
        //
        updateMap(path: walkedPath)
        
        printPath(path: walkedPath)
        
    }
    
    //MARK:- updatingMap
    
    // this method takes a path then update the map view with that path
    // FIXME: check why isn't the labels showing
    //
    func updateMap(path: Path) {
        // update the labels
        //
        distance_label.text = String(format: "%.3f Km", path.distance)
        
        //
        //
        if path.numSteps != 1 {
            steps_label.text = "\(Int(path.numSteps)) steps"
        }
        else {
            steps_label.text = "\(Int(path.numSteps)) step"
        }
        
        // TODO:
        //
        loadWalkedPath(walkedPath: path.walkedPath, map: map)
        
    }
    
    
    // this method takes an array of location CC
    // then reDrows the walked path in the mapView
    // TODO: LOAD THE PATH
    //
    func loadWalkedPath(walkedPath: [CLLocation], map: MKMapView) {
        print("this would redrow the path 🗾")
        
        // if true load the path
        //
        if !walkedPath.isEmpty {
            print("loading path... 🕐")
            
            // loop over the locatoins walked and draw a path over the map
            //
            for location in 0 ..< walkedPath.count {
                if let currentPoint = walkedPath[safe: location]{
                    if let nextPoint = walkedPath[safe: location + 1] {
                        
                        //
                        //
                        let directionRequest = MKDirections.Request()
                        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: currentPoint.coordinate))
                        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: nextPoint.coordinate))
                        directionRequest.transportType = .any // change to walking?
                        
                        //
                        //
                        let direction = MKDirections(request: directionRequest)
                        direction.calculate { (response, error) in
                            guard let directionResponse = response else {
                                    if let error = error {
                                        print("something went wrong...")
                                    }
                                    return
                            }
                            //
                            //
                            let route = directionResponse.routes[0]
                            map.addOverlay(route.polyline, level: .aboveLabels)
                            
                            //
                            //
                            let rect = route.polyline.boundingMapRect
                            map.setVisibleMapRect(rect, animated: true)
                            map.setCenter(walkedPath[0].coordinate, animated: true)
                            //map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                        } // end calculate
                        
                    } // end nextPoint
                } // end currentPoint
            } // end for
        } // end if !isEmpty
        else {
            print("u never walked!")
        }
    }
    
    
    // this is a test method to print all the data that is passed to this class
    //
    func printPath(path: Path) -> Void {
        print("this path was on \(path.date)")
        print("you walked \(path.distance)")
        print("num of steps is \(path.numSteps)")
        print("this is your path ->:")
        
        for location in path.walkedPath {
            print(location.coordinate)
        }
    }
    
    
    
    // MARK:- mapKit delegates
    //
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = UIColor.green
        render.lineWidth = 3
        return render
    }

}
