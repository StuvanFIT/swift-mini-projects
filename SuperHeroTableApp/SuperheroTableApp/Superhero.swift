//
//  Superhero.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 11/8/2025.
//

import UIKit


enum Universe: Int {
    case marvel = 0;
    case dc = 1;
    case other = 2;
}

class Superhero: NSObject {
    var name: String?
    var abilities: String?
    var universe: Universe?
    
    init(name: String?, abilities: String?, universe: Universe?) {
        self.name = name
        self.abilities = abilities
        self.universe = universe
    }

}
