//
//  Person.swift
//  HelloWorldApp
//
//  Created by Steven Kaing on 29/7/2025.
//

import UIKit

class Person: NSObject {
    var name: String
    var age: Int
    
    init(inputName: String, inputAge: Int) {
        name = inputName
        age = inputAge
    }
    
    func greeting() -> String {
        return "Hello \(name)! You are \(age) years old!"
    }

}
