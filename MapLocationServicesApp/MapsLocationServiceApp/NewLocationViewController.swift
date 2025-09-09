//
//  NewLocationViewController.swift
//  MapsLocationServiceApp
//
//  Created by Steven Kaing on 9/9/2025.
//

import UIKit
import MapKit


/*
 Because this class will be listening for location changes, we need to make sure the
 class implements the CLLocationManagerDelegate. This will allow us to respond to
 changes in location as well as changes in permissions from the user. When dealing
 with location we cannot assume we have permission to access this sensitive dat
 */
class NewLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    weak var locationDelegate: NewLocationDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    
    @IBOutlet weak var latitudeTextField: UITextField!
    
    @IBOutlet weak var longitudeTextField: UITextField!
    
    
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        } else {
            displayMessage(title: "Error", message: "Location has not yet been determined!")
            
        }
    }
    
    
    @IBAction func saveLocation(_ sender: Any) {
        
        //Validate fields
        guard let latitude = Double(latitudeTextField.text ?? ""), let longitude = Double(longitudeTextField.text ?? "") else {
            
            let alertController = UIAlertController(title: "Coordinates invalid", message: "Latitude and longitude must be numbers", preferredStyle: .alert)
                
            alertController.addAction(UIAlertAction(title: "Dismiss",style: .default, handler: nil))
                
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let title = titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty,
              let description = descriptionTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !description.isEmpty
        
        else {
            let alertController = UIAlertController(title: "Title or Description is Empty", message: "Please enter a title and description", preferredStyle: .alert)
                
            alertController.addAction(UIAlertAction(title: "Dismiss",style: .default, handler: nil))
                
            present(alertController, animated: true, completion: nil)
            return
        }
        
        //Instantiate new location annotation
        let newLocationAnnotation = LocationAnnotation(title: title, subtitle: description, lat: latitude, long: longitude)
        
    
        
        //add this new locatio annotation to NewLocationDelegate
        locationDelegate?.annotationAdded(annotation: newLocationAnnotation)
    
        navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //When the view loads, we need to set up the desired accuracy, distance filter and delegate of the location manager
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //the minimum distance required for the user to move for an update request to fire off
        //in this case its 10 metres
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        //Check if we have authorisation status to access location data
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse {
            
            //We cannot assume that the user will share their location. So the app still needs to be functional without knowledge of the user's location
            /*
             For this we will hide the "useCurrentLocationButton" if we do not have authorisation,
             and if we have not yet asked the user for permission then we will request permission to
             access the location data.
             */
            useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Tell the location manager to start updating
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Tell the location manager to stop updating
        locationManager.stopUpdatingLocation()
        
    }
    
    /*
     
     This method will be called whenever a change in authorization has been detected. We
     need to check to see if the authorization status hasbecome authorizedWhenInUse and
     if it has, unhide the useCurrentLocationButton.
     
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            useCurrentLocationButton.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        
        currentLocation = locations.last?.coordinate
        
    }
    


}
