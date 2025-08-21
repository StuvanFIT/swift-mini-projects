//
//  Superhero+CoreDataProperties.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 21/8/2025.
//
//

import Foundation
import CoreData

enum Universe: Int32 {
    case marvel = 0
    case dc = 1
    case other = 2
}


extension Superhero {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Superhero> {
        return NSFetchRequest<Superhero>(entityName: "Superhero")
    }

    @NSManaged public var abilities: String?
    @NSManaged public var name: String?
    @NSManaged public var universe: Int32
    @NSManaged public var teams: NSSet?

}

// MARK: Generated accessors for teams
extension Superhero {

    @objc(addTeamsObject:)
    @NSManaged public func addToTeams(_ value: Team)

    @objc(removeTeamsObject:)
    @NSManaged public func removeFromTeams(_ value: Team)

    @objc(addTeams:)
    @NSManaged public func addToTeams(_ values: NSSet)

    @objc(removeTeams:)
    @NSManaged public func removeFromTeams(_ values: NSSet)

}

extension Superhero : Identifiable {

}


extension Superhero {
    var herouniverse: Universe {
        //Get Methods to return superhero universe
        get {
            return Universe(rawValue: self.universe)!
        }
        
        //Set method to set super hero universe
        //note that the raw value type is Int32 values to allow them to be entered in the core data database
        set {
            self.universe = newValue.rawValue
        }
    }
}
