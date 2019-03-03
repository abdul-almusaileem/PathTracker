//
//  Pedometer.swift
//  
//
//  Created by Abdul Almusaileem on 11/21/18.
//

import Foundation
import CoreMotion
import Dispatch

// this is a Pedometer class that uses Core Morion framework
// this class h
//
class Pedometer {
    var pedometer = CMPedometer()
    var activityManager = CMMotionActivityManager()
    var startDate: Date
    var numSteps: Double
    var activity: String
    
    init(numSteps: Double, startDate: Date, activity: String) {
        self.numSteps = numSteps
        self.startDate = startDate
        self.activity = activity
    }
    
    //
    //
    func Authorize() {
        updateStepsCountLabelUsing(startDate: self.startDate)
        checkAuthorizationStatus()
    }
    
    //
    //
    func reset() {
        self.numSteps = 0
    }
    
    
    //
    //
    func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) { pedometerData, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    print(String(describing: pedometerData.numberOfSteps))
                }
            }
        }
    }
    
    //
    //
    func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            print("Not available...")
            break
        default:
            break
        }
    }
    
    

    // start updating
    //
    func Update() {
 
        // check what activity the user is doing
        //
        if CMMotionActivityManager.isActivityAvailable() {
           self.activity = activityType()
        }
        
        // update the stepcount
        //
        if CMPedometer.isStepCountingAvailable() {
            numSteps = countSteps()
        }
    }
    
    
    // this method would count the number of steps that the user walks
    //
    func countSteps() -> Double {
        //
        //
        var steps = 0.0
        
        pedometer.startUpdates(from: Date(), withHandler: { pedometerData, error in
            // unwrap the pedometerData and the are no errors
            //
            guard let pedometerData = pedometerData, error == nil else {return}
            
            // update the steps counter
            //
            DispatchQueue.main.async {
                steps = pedometerData.numberOfSteps.doubleValue
            }
        })
        return steps
    }
    
    // this method checks the useers statues
    //
    func activityType() -> String{

        
        //
        //
        activityManager.startActivityUpdates(to: .main, withHandler: { (activity: CMMotionActivity?) in
            
            // unwrap the activity var
            //
            guard let activity = activity else {return}
            
            // check which activity is the user doing and print it
            // TODO: check why using main disppatch?
            //
            DispatchQueue.main.async {
                if activity.walking {
                    print("the user is walking right now...🚶🏾‍♂️")
                    return self.activity = "🚶🏾‍♂️"
                }
                else if activity.running {
                    print("the user is running right now...🏃🏾‍♂️")
                    return self.activity = "🏃🏾‍♂️"
                }
                else if activity.stationary {
                    print("the user is standing right now...🕴🏾")
                    return self.activity = "🕴🏾"
                }
                else if activity.automotive {
                    print("in da car!")
                    return self.activity = "🚙"
                }
                else {
                    print("the user is....")
                    return self.activity = "🚫"
                }
            }
        })
        return self.activity
    }
}
