//
//  DatabaseProtocol.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 21/8/2025.
//


/*
 
 This file is a contract that any database implementation must follow. This includes
 - CORE DATA
 - FIREBASE
 - REALM
 - even IN-MEMORY-MOCK
 */



/*
 The DatabaseChange enumeration is used to define what type of change has been
 done to the database. There are several possible cases here that are very useful, these
 being add, remove, and update.
 
 Useful for notifying listeners about what specifically changed.
 */
enum DatabaseChange {
    case add
    case remove
    case update
}


/*
 The database we are building has multiple diﬀerent sets of data that each require their
 own specific behaviour to handle. It can prove useful to specify the type of data each of
 our listeners will be dealing with. In the case of this app, we can have listeners that
 listen for team, hero or both. These will be used when the database has any changes
 (the changes from our previous enum!)
 
 Specifies what kind of data a listener cares about
 */

enum ListenerType {
    case team
    case teams
    case heroes
    case all
}


/*
 This protocol defines the delegate we will use for receiving messages from the
 database. It has three things that any implementation must take care of.
 
    - The implementation must always specify the listener’s type
    - An onTeamChange method for when a change to heroes in a team has occurred.
    - An onAllHeroesChange method for when a change to any of the heroes has occurred.
 
 This is the delegate protocol for objects that want to be notified about database changes.
 
 Every listener must declare what type of changes it wants (listenerType).
 Provides two callback methods:
    onTeamChange → Called when heroes in a team are modified.
    onAllHeroesChange → Called when the set of all superheroes changes.
 
 For example, a Team Detail Screen might implement onTeamChange to update its table view when members change, while a Hero List Screen might implement onAllHeroesChange.
 */
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
    func onTeamsChange(change: DatabaseChange, teams:[Team])
}


/*
 Database Protocol
 This is the main abstraction of your database. Any class (e.g. CoreDataDatabase or FirebaseDatabase) must implement this.
 
 */
protocol DatabaseProtocol: AnyObject {
    
    
    var currentTeam: Team? {get}
    
    func setCurrentTeam(team: Team)
    
    
    func addTeam(teamName: String) -> Team
    
    func deleteTeam(team: Team)
    
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
    
    func removeHeroFromTeam(hero: Superhero, team: Team)
    
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero
    
    func deleteSuperhero(hero: Superhero)
    
    func fetchAllTeams() -> [Team]

}
