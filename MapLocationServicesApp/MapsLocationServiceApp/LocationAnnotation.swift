//
//  LocationAnnotation.swift
//  MapsLocationServiceApp
//
//  Created by Steven Kaing on 9/9/2025.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle:String?
    
    init(title: String, subtitle: String, lat: Double, long: Double) {
        self.title = title
        self.subtitle = subtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
    }
    

}
