//
//  Team.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 7/9/2025.
//

import UIKit
import FirebaseFirestore

class Team: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
    var heroes: [Superhero]?
}
