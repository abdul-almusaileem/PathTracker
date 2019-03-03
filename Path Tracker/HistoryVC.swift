//
//  History.swift
//  Path Tracker
//
//  Created by Abdul Almusaileem on 11/18/18.
//  Copyright © 2018 Abdul Almusaileem. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

// TODO: use core data framwork
//

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //
    //
    var steps: Double = 0
    var distance: Double = 0
    var walkedPath: [CLLocation] = []
    
    //
    //
    var currentPath: Path!
    
    //
    //
    //var paths_walked: [(name: String, path: Path!)] = []
    var paths_walked: [Path]! = []
    //var paths_walked: Set<Path>! = []
    
    //
    //
    let cellIdentifier = "history_cell"
    
    //
    //
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var pathHistoryTable: UITableView!
    
    
    // Realm stuff...
    //
    let realm = try! Realm()
    //var paths: Results<Path> = { self.realm.objects(Path) }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pathHistoryTable.delegate = self
        pathHistoryTable.dataSource = self
        
        //
        //
        addBtn.addTarget(self, action: #selector(addPath), for: .touchUpInside)

        // update the labels
        //
        if let currentPath = currentPath {
            updateLabels(path: currentPath)
        }
        
       // writeDummyPath()
        //prtintPaths()
        
        // FIXME: this is a stupid solution for the the add btn thing
        //
        let dummyPath = Path(path: [], steps: 0, distance: 0)
        //paths_walked.append((name: "", path: dummyPath))
        paths_walked.append(dummyPath)
    }
    
    
    // MARk:- action
    //
    
    // this method would take the current Path and store it in the dataBase
    // it would then reset the Path by creating a new instance of the app
    // then relaod the tableView
    // FIXME: the first path added doesn't update the table
    //
    @objc func addPath(sender: UIButton!) {
        
        // store the current path
        //
        let pathToSave = currentPath
        var pathName  = ""
 
        let ac = UIAlertController(title: "Save Path", message: "What do you want to call this path?", preferredStyle: .alert)
        
        // append the path to the list
        // TODO: make it story to Database
        //
        let saveAction = UIAlertAction(title: "Save path", style: .default, handler: { _ in
            //self.paths_walked.append((name: pathName, path: pathToSave))
            if let pathToSave = pathToSave {
                pathToSave.pathName = pathName
                self.paths_walked.append(pathToSave)
            }
        })
        saveAction.isEnabled = false
        
        // take the pathName using a textfield
        //
        ac.addTextField(configurationHandler: { (textField) in
            let textField = ac.textFields![0] as UITextField
            textField.placeholder = "Path name"
            textField.textAlignment = .center
            
            // check if the textfield has values to determan if emabling the saveBtn
            // then store the path's name
            // copied from: https://gist.github.com/TheCodedSelf/c4f3984dd9fcc015b3ab2f9f60f8ad51
            //
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count ?? 0
                let textIsNotEmpty = textCount > 0
                saveAction.isEnabled = textIsNotEmpty
                pathName = textField.text!
                /*
                if let pathToSave = pathToSave {
                    pathToSave.pathName = textField.text!
                }
                */
            })
        })

        // add the actions
        //
        ac.addAction(saveAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)

        // reset the current path and steps
        // FIXME: make the path and the numsteps reset (viewDidAppear)
        // FIXME: reset the map << delete overlays
        //
        if let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home_vc") as? ViewController {
            if let path = homeVC.currentPath {
                path.resetPath()
            }
            if let pedometer = homeVC.pedometer {
                pedometer.reset()
            }
        }
        
        //self.currentPath.resetPath()
        pathHistoryTable.reloadData()

    }
    
    // MARK:- TableView
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths_walked.count
    }
    

    // fill out the cells using the names from the list
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if !paths_walked.isEmpty {
            cell.textLabel?.text = paths_walked[indexPath.row].pathName
            //cell.textLabel?.text = "\(paths_walked[indexPath.row].distance)"
        }
        DispatchQueue.main.async {
            self.pathHistoryTable.reloadData()
        }
        return cell
    }
    
    // when clicking on a cell a new VC is loaded
    // it shows the walked path, distance and steps
    //
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        // load tha path in a new MapView
        //
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "walked_path") as? WalkedPathVC {
            
            // pass data
            // TODO: pass path from the path list not the current path
            //
            vc.walkedPath = paths_walked[indexPath.row]
            
            // show the vc
            //
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK:-
    //
    
    //
    //
    func updateLabels(path: Path) {
        stepsLabel.text = "\(Int(currentPath.numSteps))"
        distanceLabel.text = String(format: "%.3f Km", currentPath.distance)
        
        //
        //
        /*if let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home_vc") as? ViewController {
            if let path = homeVC.currentPath {
                stepsLabel.text = "\(Int(path.numSteps))"
                distanceLabel.text = String(format: "%.3f Km", path.distance)
            }
        }*/
    }

    
    // MARK:- Realm
    //
    
   /* func writeDummyPath() {
        do {
            let realm = try! Realm()
            try realm.write {
                var dummyPath = Path(name: "dummy", path: [], steps: 20, distance: 0.1)
                realm.add(dummyPath)
            }
        }
        catch let error as NSError {
            print("something went wrong...\(error.localizedDescription)")
        }
    }*/
    
    /*func prtintPaths() {
        //let paths = realm.objects(Path.self)
        for path in paths {
            print(path)
        }
    }*/
    
    
    // this method would the added paths then update the database
    //
    func updateDatabase(Paths: [(name: String, path: Path!)]) {
        print("this would take all the paths and update the database ")
    }

}
