//
//  NewLocationDelegate.swift
//  MapsLocationServiceApp
//
//  Created by Steven Kaing on 9/9/2025.
//

import ObjectiveC

protocol NewLocationDelegate: NSObject {
    func annotationAdded(annotation: LocationAnnotation)
}
