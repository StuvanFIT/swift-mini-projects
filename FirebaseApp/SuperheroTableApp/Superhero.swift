//
//  Superhero.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 7/9/2025.
//

import UIKit
import FirebaseFirestore

class Superhero: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var abilities: String?
    var universe: Int?
}
    