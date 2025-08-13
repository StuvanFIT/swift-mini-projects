//
//  CurrentPartyTableViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 11/8/2025.
//

import UIKit

//Section Indices: start from 0
let MARVEL_SECTION = 0
let DC_SECTION = 1
let OTHER_SECTION = 2
let SECTION_INFO = 3

let heroSections = [MARVEL_SECTION, DC_SECTION, OTHER_SECTION]

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
    
    //Store an array of superheroes arrays (marvel, dc and other array)
    var currentParty: [[Superhero]] = [[],[],[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //initialiseSuperheroes()
    }

    
    func addSuperhero(_ newHero: Superhero) -> Bool {
        
        //The raw value of the Universe
        guard let heroSection = newHero.universe?.rawValue else {
            return false
        }
        
        //Before we add a super hero, need to check if there is enough space
        //We need to calulcate the total number of heroes in each section
        let totalHeroes = getTotalHeroes()
        if totalHeroes >= MAX_PARTY_SIZE{
            return false
        }
        
        //Make sure there are no duplicate heroes
        let isDuplicateHero = checkDuplicateHeroes(newHero: newHero)
        if (isDuplicateHero) {
            return false
        }

        tableView.performBatchUpdates({
            currentParty[heroSection].append(newHero)
            
            tableView.insertRows(at: [IndexPath(row: currentParty[heroSection].count - 1, section: heroSection)],
                                 with: .automatic)
            
            tableView.reloadSections([SECTION_INFO], with: .automatic)
        }, completion: nil)
        
        return true
    }
    
    
    /*
     Finds the total number of heroes in the current party across all hero sections
     */
    func getTotalHeroes() -> Int{
        var totalHeroes = 0
        for heroSection in currentParty {
            totalHeroes += heroSection.count
        }
        return totalHeroes
    }
    /*
     For each hero section, check it the input hero already exists in one of the sections based on the name
     */
    func checkDuplicateHeroes(newHero: Superhero) -> Bool {
        for heroSection in currentParty {
            if heroSection.contains(where: {hero in hero.name?.lowercased() == newHero.name?.lowercased()}) {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allHeroesSegue" {
            let destination = segue.destination as! AllHeroesTableViewController
            destination.superHeroDelegate = self
        }
    }
    

        
    //Number of sections in the Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        //We want to have 4 sections: Marvel, DC, Other, Party Info
        return 4
    }
    
    
    /*
     The next series of methods look like they are all named tableView, but each have different parameters
     and a different purpose
     */
    
    //Given a section, it determines the number of rows in the specified section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*
         SECTION_INFO -> ALWAYS 1 ROW (HERO INFO)
         MARVEL/DC/OTHER_SECTION -> Number of rows === Number of super heroes in the current party in their respective sections
         */
        switch section {
        case MARVEL_SECTION:
            return currentParty[MARVEL_SECTION].count
        case DC_SECTION:
            return currentParty[DC_SECTION].count
        case OTHER_SECTION:
            return currentParty[OTHER_SECTION].count
        case SECTION_INFO:
            return 1
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
        if heroSections.contains(indexPath.section){
            let heroCell = tableView.dequeueReusableCell(withIdentifier: CELL_HERO, for: indexPath)
            
            var content =  heroCell.defaultContentConfiguration()
            let hero = currentParty[indexPath.section][indexPath.row]
            content.text = hero.name
            content.secondaryText = hero.abilities
            
            heroCell.contentConfiguration = content
            
            return heroCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            
            //If there are no superheroes
            if getTotalHeroes() == 0{
                content.text = "No Heroes in your Party! Tap + to add some!"
            } else {
                content.text = "\(getTotalHeroes())/6 Heroes in the party!"
            }
            
            infoCell.contentConfiguration = content
            
            return infoCell
        }
    }
    
    /*
     These gives us the headers for each section
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case MARVEL_SECTION:
            return "Marvel Heroes (\(currentParty[MARVEL_SECTION].count))"
        case DC_SECTION:
            return "DC Heroes (\(currentParty[DC_SECTION].count))"
        case OTHER_SECTION:
            return "Other Heroes (\(currentParty[OTHER_SECTION].count))"
        case SECTION_INFO:
            return "Party Information"
        default:
            return nil
        }
    }

    // Override to support conditional editing of the table view.
    // Allows us to specify whether a certain row can be edited by the user: updating or deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case MARVEL_SECTION:
            return true
        case DC_SECTION:
            return true
        case OTHER_SECTION:
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
        if editingStyle == .delete && heroSections.contains(indexPath.section) {
            
            //The below 3 steps need to be executed in one single batch.
            //This is necessary when multiple changes occur at once to a table view or collection view
            tableView.performBatchUpdates({
                //Remove the hero from the current party
                self.currentParty[indexPath.section].remove(at: indexPath.row)
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
