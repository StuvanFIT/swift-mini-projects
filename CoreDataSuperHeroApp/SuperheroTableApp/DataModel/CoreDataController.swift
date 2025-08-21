//
//  CoreDataController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 21/8/2025.
//

import UIKit
import CoreData


/*
 Why we need the listeners
 
 Imagine you have:
 A HeroesListViewController showing all heroes.
 A TeamDetailViewController showing heroes for just one team.
 
 Without listeners:
 If you add Iron Man in one screen, the other screen wouldn’t know.
 You’d have to reload manually every time.
 
 With listeners:
 Both screens register as listeners.
 When a new hero is added → database calls back to all registered listeners.
 Each listener can update its UI immediately.
 
 
 */



class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    
    
    let DEFAULT_TEAM_NAME = "Default Team"
    
    //This controller will watch for changes to all heroes within the database. When a change
    //occurs, the Core Data controller will be notified and can let its listeners know.
    var allHeroesFetchedResultsController: NSFetchedResultsController<Superhero>?
    
    var teamHeroesFetchedResultsController: NSFetchedResultsController<Superhero>?
    
    //The “listeners” property holds all listeners added to the database inside of the MulticastDelegate class that was added above
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    /*
     A fetch request is used here to find all instances of teams with the name "Default
     Team". If none are found, we create one. This will be done on the first run of the
     application. After this point, there should always be a Default Team.
     */
    lazy var defaultTeam: Team = {
        var teams = [Team]()
        
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_TEAM_NAME)
        request.predicate = predicate
        
        do {
            try teams = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request has failed: \(error)")
        }
        
        if let firstTeam = teams.first{
            return firstTeam
        }
        
        return addTeam(teamName: DEFAULT_TEAM_NAME)
    }()
    
    
    
    
    
    override init() {
        
        //Instantiate the core data stack before the call to super init (all properties must have values before this call)
        // initializes the Persistent Container property using the data model named "DataModel".
        persistentContainer = NSPersistentContainer(name:"DataModel")
        
        //loads the core data stack
        //if there is an error, most likely becuase the name given did not match what the xcdatamodeld object in XCODE
        persistentContainer.loadPersistentStores() {(description, error) in
            if let error = error {
                fatalError("Failed to load core data stack with error: \(error)")
            }
            
        }
        super.init()
        
        
        //Initialise default heroes
        if (fetchAllHeroes().count == 0) {
            createDefaultHeroes()
        }
        
    }
    
    
    
    
    func createDefaultHeroes() {
        //The "_" is used to stop getting the compiler warning for not using the returned values
        let _ = addSuperhero(name: "Bruce Wayne",
                             abilities: "Money",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Superman",
                             abilities: "Superhuman Strength",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Wonder Woman",
                             abilities: "Goddess",
                             universe: .dc)
        
        let _ = addSuperhero(name: "The Flash",
                             abilities: "Speed",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Green Lantern",
                             abilities: "Power Ring",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Cyborg",
                             abilities: "Robot Beep Beep",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Aquaman",
                             abilities: "Atlantian",
                             universe: .dc)
        
        let _ = addSuperhero(name: "Captain Marvel",
                             abilities: "Superhuman Strength",
                             universe: .marvel)
        
        let _ = addSuperhero(name: "Spider-Man",
                             abilities: "Spider Sense",
                             universe: .marvel)
        let _ = addSuperhero(name: "Lebron James",
                             abilities: "Lebronto",
                             universe: .other)
        
        // Save changes to Core Data
        cleanup()
    }
    
    
    
    
    /*
     This method will check to see if there are changes to be saved inside of the view
     context and then save, as necessary.
     
     Changes made to the managed object context must be explicitly saved by calling the
     save method on the managed object context
     */
    func cleanup() {
        
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to core data with error: \(error)")
            }
        }
    }
    
    /*
     The addListener method does two things. Firstly it adds the new database listener to
     the list of listeners. And secondly, it will provide the listener with initial immediate
     results depending on what type of listener it is.
     */
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .heroes || listener.listenerType == .all {
            listener.onAllHeroesChange(change: .update, heroes:
                                        fetchAllHeroes())
        }
        
        if listener.listenerType == .team || listener.listenerType == .all {
            listener.onTeamChange(change: .update, teamHeroes: fetchTeamHeroes())
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /*
     The addSuperhero method is responsible for adding new superheroes to Core Data. It
     takes in a name and abilities, generates a new Superhero object then returns it. The
     Superhero is a Core Data managed object stored within a specific managed object
     context.
     */
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero {
        
        //created inside the main context (the one linked to UI updates).
        //Every NSManagedObject has to belong to an NSManagedObjectContext.
        //The context is like the workspace that tracks the object's state
        //Without the context, CoreData wouldnt know where to save the object, what database it belongs to
        let hero = Superhero(context: persistentContainer.viewContext)
        hero.name = name
        hero.abilities = abilities
        hero.universe = universe.rawValue
        
        return hero
    }
    
    func deleteSuperhero(hero: Superhero) {
        persistentContainer.viewContext.delete(hero)
    }
    
    /*
     The fetchAllHeroes method is used to query Core Data to retrieve all hero entities
     stored within persistent memory. It requires no input parameters and will return an array
     of Superhero objects.
     */
    func fetchAllHeroes()-> [Superhero] {
        
        if allHeroesFetchedResultsController == nil {
            //Fetch all Superhero objects in the context
            //In this query request, you need to specifiy the entity (SUPER HERO), any filters or sorting order
            let request: NSFetchRequest<Superhero> = Superhero.fetchRequest() //no filters, no sorting, just superhero entity
            
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            
            // Initialise Fetched Results Controller
            allHeroesFetchedResultsController =
            NSFetchedResultsController<Superhero> (
                fetchRequest: request,
                managedObjectContext: persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            // Set this class to be the results delegate
            allHeroesFetchedResultsController?.delegate = self
            
            //Next, perform the fetch request (whcih will begin the listening process and when updates occur to all heroestable, then this listens to the changes)
            do {
                try allHeroesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch request failed: \(error)")
            }
        }
        

        return allHeroesFetchedResultsController?.fetchedObjects ?? []
    }
    
    // MARK: - Fetched Results Controller Protocol methods
    /*
     As part of the
     NSFetchedResultsControllerDelegate we must implement another method. This being
     the controllerDidChangeContent method. This will be called whenever the
     FetchedResultsController detects a change to the result of its fetch.
     
     We first check to see if the controller is our allHeroesFetchedResultsController.
     (Once teams are implemented there will be two separate FetchedResultsControllers
     that trigger calls to this method when changes are detected.)
     
     If it is the correct method, we call the MulticastDelegate’s invoke method and provide it
     with a closure that will be called for each listener. For each listener, it checks if it is
     listening for changes to heroes. If it is, it calls the onAllHeroesChange method, passing
     it the updated list of heroes.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allHeroesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .heroes || listener.listenerType == .all {
                    listener.onAllHeroesChange(change: .update,
                                               heroes: fetchAllHeroes())
                }
            }
        } else if controller == teamHeroesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .team || listener.listenerType == .all {
                    listener.onTeamChange(change: .update,teamHeroes: fetchTeamHeroes())
                }
            }
        }
    }
        
    /*
     This method will add a new team to the database given a team name and then return it.
     It is very similar to how the addSuperhero method works.
     */
    func addTeam(teamName: String) -> Team {
        let team = Team(context: persistentContainer.viewContext)
        team.name = teamName
        return team
    }
    //This method deletes a given team from the managed object context
    func deleteTeam(team: Team) {
        persistentContainer.viewContext.delete(team)
    }
        
    /*
     This method attempts to add a hero to a given team and will return a boolean to
     indicate whether it was successful. It can fail if the team already has 6 or more heroes
     or if the team already contains the hero.
     */
    func addHeroToTeam(hero: Superhero, team: Team)-> Bool {
        guard let heroes = team.heroes, heroes.contains(hero) == false, heroes.count < 6 else {
            return false
        }
        team.addToHeroes(hero)
        return true
        
    }
    
    func removeHeroFromTeam(hero: Superhero, team: Team) {
        team.removeFromHeroes(hero)
    }
    
    /*
     This method will be like the fetchAllHeroes method with a few main diﬀerences. Firstly,
     it returns an array of superheroes which are part of a specified team. For this
     application, we have hard-coded it to be the default team. All of this will be done
     through a fetched results controller as well
     */
    
    func fetchTeamHeroes() -> [Superhero] {
        // If the results controller has not been created yet, set it up
        if teamHeroesFetchedResultsController == nil {
            // 1. Create a fetch request for Superhero objects
            let fetchRequest: NSFetchRequest<Superhero> = Superhero.fetchRequest()
            
            // 2. Sort the superheroes alphabetically by their "name" attribute
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            // 3. Add a predicate to filter only heroes that belong to the DEFAULT_TEAM_NAME
            // "ANY teams.name" means: look at the hero's teams relationship and check if any team matches
            let predicate = NSPredicate(format: "ANY teams.name == %@", DEFAULT_TEAM_NAME)
            fetchRequest.predicate = predicate
            
            // 4. Create the fetched results controller
            teamHeroesFetchedResultsController = NSFetchedResultsController<Superhero>(
                fetchRequest: fetchRequest,
                managedObjectContext: persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            // 5. Set delegate so we get notified when the data changes
            teamHeroesFetchedResultsController?.delegate = self
            
            // 6. Perform the fetch from Core Data
            do {
                try teamHeroesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        // 7. Extract and return the fetched superheroes, or an empty array if nil
        var heroes = [Superhero]()
        if let fetchedHeroes = teamHeroesFetchedResultsController?.fetchedObjects {
            heroes = fetchedHeroes
        }
        
        return heroes
    }
}
