//
//  LocationsTableViewController.swift
//  MapsLocationServiceApp
//
//  Created by Steven Kaing on 9/9/2025.
//

import UIKit

let CELL_LOCATION = "locationCell"


class LocationsTableViewController: UITableViewController, NewLocationDelegate {
    
        
    weak var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()
    
    var isFirstViewApperance = true
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var location = LocationAnnotation(title: "Monash Uni - Caulfield",
                                          subtitle: "The Caulfield Campus of the Uni",
                                          lat: -37.877623, long: 145.045374)
        locationList.append(location)
        
        location = LocationAnnotation(title: "Monash Uni - Clayton",subtitle: "The Clayton Campus of the Uni", lat: -37.9105238, long: 145.1362182)
        locationList.append(location)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        
        //Get the annotation for this row
        let annotation = locationList[indexPath.row]
        
        //Set the cell's text label to be the annotation title
        cell.textLabel?.text = annotation.title ?? "Default Title of Location"
        
        //Set the cell's detail text label to be the latittude and longitude formatted in a string
        let latitudeCoord = annotation.coordinate.latitude
        let longitudeCoord = annotation.coordinate.longitude
        cell.detailTextLabel?.text = String(format: "Latitude: %.4f, Longitude: %.4f", latitudeCoord, longitudeCoord)
        
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //Remove annotation from mapView
            mapViewController?.mapView.removeAnnotation(locationList[indexPath.row])
            
            //Remove from locationList
            locationList.remove(at: indexPath.row)
        
            //Remove from tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    //Selecting a annotation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Get annotation that was selected
        let annotation = locationList[indexPath.row]
        
        //When a row is selected, we want to tell the map view controller to focus on the specified annotation.
        mapViewController?.focusOn(annotation: annotation)
            
        /*
         To ensure that the application correctly works on devices in vertical layout or that are
         too small to support a split screen, we should also tell the split view to show the detail
         view controlle
         */
        
        splitViewController?.show(.secondary)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         This approach would not be needed if we were using CoreData to load the
         annotations. As we could easily have both the Map View Controller and Locations Table View
         Controller both listen to the database for changes to the set of locations.
         */
        if isFirstViewApperance {
            mapViewController?.mapView.addAnnotations(locationList)
            isFirstViewApperance = false
        }
    }
    
    func annotationAdded(annotation: LocationAnnotation) {
        tableView.performBatchUpdates() {
            locationList.append(annotation)
            tableView.insertRows(at: [IndexPath(row: locationList.count-1, section: 0)], with: .automatic)
        }
        mapViewController?.mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "addLocationSegue" {
             if let destination = segue.destination as? NewLocationViewController {
                 destination.locationDelegate = self
             }
         }
     }


}
