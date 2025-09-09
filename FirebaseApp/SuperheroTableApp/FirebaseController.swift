//
//  FirebaseController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 7/9/2025.
//

import UIKit

/*
 The FirebaseCore import statement is needed to configure Firebase.
 FirebaseAuth includes classes to use the Firebase authentication features and
 FirebaseFirestore includes classes to interact with Firestore, including extensions that
 allow use of Codable with Firestore.
 */
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    
    //Delegate
    var authListener: AuthListener?
    
    let DEFAULT_TEAM_NAME = "My Team"
    var listeners = MulticastDelegate<DatabaseListener>()
    var heroesList: [Superhero]
    var defaultTeam: Team

    var authController: Auth
    var database: Firestore
    var heroesRef: CollectionReference?
    var usersRef: CollectionReference?
    var currentUserTeamRef: DocumentReference?
    var currentUser: FirebaseAuth.User?
    
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database =  Firestore.firestore()
        heroesList = [Superhero]()
        defaultTeam = Team()
        
        super.init()
        
        
    }
    
    func signInMethod(_ credentials: (email:String, password:String)) async throws {
        
        let authResult = try await Auth.auth().signIn(withEmail: credentials.email,
                                                      password: credentials.password)
        currentUser = authResult.user
        // now that we're signed in, set up Firestore listeners
        setupHeroListener()
        setupUserTeamListener()
        authListener?.isSignedIn(user: authResult.user)
        
        
    }
    
    func createUserAccount(_ credentials: (email:String, password:String)) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: credentials.email, password: credentials.password)
        
        currentUser = authResult.user
        
        // Create a user document with an empty team when account is created
        await createUserDocument()
        
        setupHeroListener()
        setupUserTeamListener()
        authListener?.isSignedIn(user: authResult.user)
        
        
    
    }
    
    // Create user document in Firestore with empty team
    func createUserDocument() async {
        guard let user = currentUser else { return }
        
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "teamName": DEFAULT_TEAM_NAME,
            "heroes": []
        ]
        
        do {
            try await database.collection("users").document(user.uid).setData(userData)
        } catch {
            print("Error creating user document: \(error)")
        }
    }
    
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .team || listener.listenerType == .all {
            listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes ?? [])
        }
        if listener.listenerType == .heroes || listener.listenerType == .all {
            listener.onAllHeroesChange(change: .update, heroes: heroesList)
        }
    }

    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    

    func addSuperhero(name: String, abilities: String,
                      universe: Int) -> Superhero {
        let hero = Superhero()
        hero.name = name
        hero.abilities = abilities
        hero.universe = universe
        
        //We need the reference to the heroes collection to add the new super hero to the database
        /*
         Adding a document to Firestore will return a Database Reference to that specific object
         if it succeeds. We then use this reference to get the documentID. These IDs are what
         we use to refer to documents in FIrestore, and are needed when we wish to update or
         delete the document.
         The encoding is happening inside addDocument(from:):
         addDocument(from:) tries to convert (encode) your Swift struct/class hero (which must conform to Encodable) into the Firestore format (a [String: Any] dictionary).
         That's why you need a do/try/catch — because the encoding step can throw an error if something in your hero struct can't be encoded (e.g. an unsupported type or missing coding key).
         */
        do {
            if let heroRef = try heroesRef?.addDocument(from: hero) {
                hero.id = heroRef.documentID
            }
        } catch {
            print("Failed to add new superhero into firestore!  ")
        }
        
        return hero
    }
    
    
    
    func addTeam(teamName: String) -> Team {
        // This method is now less relevant since teams are user-specific
        // But keeping for compatibility - could be used to rename user's team
        let team = Team()
        team.name = teamName
        
        // Update the current user's team name
        guard let user = currentUser else { return team }
        usersRef?.document(user.uid).updateData(["teamName": teamName])
        
        return team
    }
    
    
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool {
        
        //Check if the hero is valid and team has space
        guard let heroID = hero.id, let user = currentUser else {
            return false
        }
        
        // Get current team size first to check limit
        guard defaultTeam.heroes?.count ?? 0 < 6 else {
            return false
        }
        
        //FieldValue.arrayUnion allows us to add a number of new elements to an array within Firestore
        if let newHeroRef = heroesRef?.document(heroID) {
            usersRef?.document(user.uid).updateData(["heroes" : FieldValue.arrayUnion([newHeroRef])])
            return true
        }
        
        return false
    }
    
    
    
    func deleteSuperhero(hero: Superhero) {
        if let heroID = hero.id {
            heroesRef?.document(heroID).delete()
        }
        
    }
    
    func deleteTeam(team: Team) {
        // For user-specific teams, this would clear the user's hero list
        guard let user = currentUser else { return }
        usersRef?.document(user.uid).updateData(["heroes": []])
    }
    
    
    
    func removeHeroFromTeam(hero: Superhero, team: Team) {
        guard let heroID = hero.id, let user = currentUser else { return }
        
        if let removedHeroRef = heroesRef?.document(heroID) {
            usersRef?.document(user.uid).updateData(["heroes": FieldValue.arrayRemove([removedHeroRef])])
        }
    }
    
    
    func cleanup() {
        
    }
    
    // MARK: - Firebase Controller Specific Methods
    func getHeroByID(_ id: String) -> Superhero? {
        
        for hero in heroesList {
            if hero.id == id {
                return hero
            }
        }
        return nil
        
    }
    
    func setupHeroListener() {
        heroesRef = database.collection("superheroes")
        
        /*
         Once we have a reference we can then add a snapshot listener to it and provide a
         closure to be called whenever a change occurs
         As with last week's URL responses, this closure will be executed asynchronously at
         some later point. Unlike the URL responses however, this closure will continue to
         execute every single time a change is detected on the Superheroes collection.
         */
        
        /*
         Note: It is generally not advised to use snapshotListeners on top level collections. This is
         because the listeners will fire off every time there is a change on the collection, any
         document within the collection, and even nested collections and documents. For a large
         database, this might mean hundreds of thousands of records.
         When developing your final application make sure that your snapshotListeners are used in a
         narrow capacity to avoid this.
         It is less of an issue here because the Superhero collection does not contain any nested
         collections within the Super Hero documents.
         */
        heroesRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            //Ensure snapshot is valid
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            //If the querySnapshot is valid then we can call the parseHeroesSnapshot method to handle parsing changes made on Firestore.
            self.parseHeroesSnapshot(snapshot: querySnapshot)
        }
        
        
    }
    
    /*
     The setupUserTeamListener method sets up a snapshotListener for the current user's
     document in the users collection. This replaces the old team listener approach.
     */
    func setupUserTeamListener() {
        guard let user = currentUser else { return }
        
        usersRef = database.collection("users")
        currentUserTeamRef = usersRef?.document(user.uid)
        
        currentUserTeamRef?.addSnapshotListener {
            (documentSnapshot, error) in
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Error in fetching user team: \(String(describing: error))")
                return
            }
            
            self.parseUserTeamSnapshot(snapshot: documentSnapshot)
        }
    }
    
    //convert Firestore documents into your local Hero models.
    func parseHeroesSnapshot(snapshot: QuerySnapshot) {
        
        //loop through each document change in the snapshot
        snapshot.documentChanges.forEach {
            (change) in
            
            var hero: Superhero
            
            do {
                hero = try change.document.data(as: Superhero.self)
            } catch {
                fatalError("Unable to decode the current hero: \(error.localizedDescription)")
            }
            
            //if the change type is .added, we insert it into the array at the appropriate place
            if change.type == .added {
                heroesList.insert(hero, at: Int(change.newIndex))
            } else if change.type == .modified {
                heroesList.remove(at: Int(change.oldIndex))
                heroesList.insert(hero, at: Int(change.newIndex)) //we remove and readd the newly modified hero at the new location.
            } else if change.type == .removed {
                heroesList.remove(at: Int(change.oldIndex)) //delete the element at the given location
            }
            
            /*
             once all changes have been handled. We use the multicast delegate's
             invoke method to call onAllHeroesChange on each listener.
             */
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all {
                    listener.onAllHeroesChange(change: .update, heroes: heroesList)
                }
            }
        }
    }
    
    //convert Firestore user document into your local team model.
    func parseUserTeamSnapshot(snapshot: DocumentSnapshot) {
        
        //Get team info from the user document snapshot
        defaultTeam = Team()
        defaultTeam.name = snapshot.data()?["teamName"] as? String ?? DEFAULT_TEAM_NAME
        defaultTeam.id = snapshot.documentID  // Use user ID as team ID
        defaultTeam.heroes = []
        
        //Get heroes from the user's team in the snapshot
        if let heroReferences = snapshot.data()?["heroes"] as? [DocumentReference] {
            
            for reference in heroReferences {
                if let hero = getHeroByID(reference.documentID) {
                    defaultTeam.heroes?.append(hero)
                }
            }
        }
        
        /*
         once the team has been created and heroes added to it (if
         any), we call the MulticastDelegate's invoke method to update all listeners.
         */
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all {
                listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes ?? [])
            }
        }
    }
}
