//
//  MapViewController.swift
//  MapsLocationServiceApp
//
//  Created by Steven Kaing on 9/9/2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /*
    displaying the MapView and focussing in on annotations when they
    are selected in the location list screen
     */
    func focusOn(annotation: MKAnnotation) {
        
        mapView.selectAnnotation(annotation, animated: true)
        
        /*
        if the map is focused elsewhere it will not be
        visible. We can also zoom in on a specific region and centre it on screen using the
        following two lines of code.
         */
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate,
        latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
