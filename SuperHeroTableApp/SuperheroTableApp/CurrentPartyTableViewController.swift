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

class CurrentPartyTableViewController: UITableViewController, AddSuperheroDelegate {
    
    //Store an array of superheroes
    var currentParty: [Superhero] = []
    
    
    
    func initialiseSuperheroes() {
        currentParty.append(Superhero(name: "Superman", abilities: "Super Powered Alien", universe:
        .dc))
        currentParty.append(Superhero(name: "Wonder Woman", abilities: "Goddess", universe: .dc))
        currentParty.append(Superhero(name: "The Flash", abilities: "Speed", universe: .dc))
        currentParty.append(Superhero(name: "Green Lantern", abilities: "Power Ring", universe:
        .dc))
        currentParty.append(Superhero(name: "Cyborg", abilities: "Robot Beep Beep", universe: .dc))
        currentParty.append(Superhero(name: "Aquaman", abilities: "Atlantian", universe: .dc))
    }
    
    func addSuperhero(_ newHero: Superhero) -> Bool {
        
        //Before we add a super hero, need to check if there is enough space
        if currentParty.count >= MAX_PARTY_SIZE{
            return false
        }
        
        tableView.performBatchUpdates({
            
            currentParty.append(newHero)
            
            tableView.insertRows(at: [IndexPath(row: currentParty.count - 1, section: SECTION_HERO)],
                                 with: .automatic)
            
            tableView.reloadSections([SECTION_INFO], with: .automatic)
        }, completion: nil)
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allHeroesSegue" {
            let destination = segue.destination as! AllHeroesTableViewController
            destination.superHeroDelegate = self
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //initialiseSuperheroes()
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
            
            //The below 3 steps need to be executed in one single batch.
            //This is necessary when multiple changes occur at once to a table view or collection view
            tableView.performBatchUpdates({
                //Remove the hero from the current party
                self.currentParty.remove(at: indexPath.row)
                //Delete the row from the table view/
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                //Update the info section
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
            
            }, completion: nil)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
