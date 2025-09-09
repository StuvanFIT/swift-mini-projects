//
//  CurrentPartyTableViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 11/8/2025.
//

import UIKit

//Section Indices: start from 1
let SECTION_HERO = 0
let SECTION_INFO = 1

//Good practice to create constants for cell identifiers
let CELL_HERO = "heroCell"
let CELL_INFO = "partySizeCell"

let MAX_PARTY_SIZE = 6



/*
 When the TableView is about to appear, UIKit:
 1. Finds out how big the table is and calls:
 
    numberOfSections(in: tableView)
    tableView(_:numberOfRowsInSection:)
 this tells it: " I have X sections and each section has Y rows"
 
 2. Ask for each cell individually
 For each row in each section, UIKit calls:
    tableView(_:cellForRowAt:)
 Passes in an IndexPath telling you which section and row it’s asking for.
 */

class CurrentPartyTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = .team
    weak var databaseController: DatabaseProtocol?

    //Store an array of superheroes
    var currentParty: [Superhero] = []

    
    func addSuperhero(_ newHero: Superhero) -> Bool {
        
        return databaseController?.addHeroToTeam(hero: newHero, team: databaseController!.defaultTeam) ?? false
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allHeroesSegue" {
            let destination = segue.destination as! AllHeroesTableViewController
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    //Number of sections in the Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        //We want to have 2 sections
        return 2
    }
    
    
    /*
     The next series of methods look like they are all named tableView, but each have different parameters
     and a different purpose
     
     */
    
    //Given a section, it determines the number of rows in the specified section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*
         SECTION_INFO -> ALWAYS 1 ROW (HERO INFO)
         SECTION_HERO -> Number of rows === Number of super heroes in the current party
         */
        switch section {
            case SECTION_INFO:
                return 1
            case SECTION_HERO:
                return currentParty.count
            default:
                return 0
        }
    }
    
    //Creates the cells to be displayed to the user.
    //We call the dequeReusableCell method and provide it an identifier and the index path to create a cell object.
    //The identifier must match the Reuse Identifier we created on the Storyboard
    //Index path specifies a section and row.
    /*
     Every time a table view needs to draw a row on screen, it calls cellForRowAt to ask:
     “Here’s the section and row I’m showing — please give me a cell, already filled with the right content.”
     */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_HERO {
            let heroCell = tableView.dequeueReusableCell(withIdentifier: CELL_HERO, for: indexPath)
            
            var content =  heroCell.defaultContentConfiguration()
            let hero = currentParty[indexPath.row]
            content.text = hero.name
            content.secondaryText = hero.abilities
            
            heroCell.contentConfiguration = content
            
            return heroCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            
            //If there are no superheroes
            if currentParty.isEmpty {
                content.text = "No Heroes in your Party! Tap + to add some!"
            } else {
                content.text = "\(currentParty.count)/6 Heroes in the party!"
            }
            
            infoCell.contentConfiguration = content
            
            return infoCell
        }
    }

    // Override to support conditional editing of the table view.
    // Allows us to specify whether a certain row can be edited by the user: updating or deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case SECTION_HERO:
            return true
        case SECTION_INFO:
            return false
        default:
            return false
        }
    }

    // Override to support editing the table view.
    // This method allows us to handle deletion or insertion of rows into our table view
    // we use the editing style to check if there is a deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_HERO {
            
            let removedHero = currentParty[indexPath.row]
            self.databaseController?.removeHeroFromTeam(hero: removedHero, team: databaseController!.defaultTeam)
            databaseController?.cleanup()
            

            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    /*
     This method is called before the view appears on
     screen. In this method, we need to add ourselves to the database listeners.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    /*
     This method is called before the view appears on
     screen. In this method, we need to remove ourselves from the database listeners.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        currentParty = teamHeroes
        tableView.reloadData()
    }
    
    //THIS IS NOW EMPTY as we are not listening to these changes in this view
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {

    }
    
    
    
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
