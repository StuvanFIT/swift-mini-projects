//
//  AllTeamsTableViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 24/8/202 5.
//

import UIKit

//We have a cell that when clicked on, it navigates to the currentparty viewer
let CELL_TEAM = "teamCell"
let CELL_TOTAL_TEAMS = "totalTeams"

//2 sections: the team section and the total number of teams.
let SECTION_TEAMS = 0
let SECTION_TOTAL = 1

let MAX_TEAMS = 10

class AllTeamsTableViewController: UITableViewController, DatabaseListener{
    var listenerType: ListenerType = .teams
    

    
    //To access the core data
    weak var databaseController: DatabaseProtocol?
    
    //All teams are stored in an array
    var allTeams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup and access our coreDataController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_TEAMS:
            return allTeams.count
        case SECTION_TOTAL:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //If the current section is the team section:
        if indexPath.section == SECTION_TEAMS{
            //create the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TEAM, for: indexPath)
            
            var cellContent = cell.defaultContentConfiguration()
            cellContent.text = allTeams[indexPath.row].name
            cell.contentConfiguration = cellContent
            
            return cell
        //If the current section is the total team section
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TOTAL_TEAMS, for: indexPath)
            
            var cellContent = cell.defaultContentConfiguration()
            cellContent.text = "Total Teams: \(allTeams.count)"
            cell.contentConfiguration = cellContent
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    // Allows us to specify whether a certain row can be edited by the user: updating or deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case SECTION_TEAMS:
            return true
        case SECTION_TOTAL:
            return false
        default:
            return false
        }
    }
    
    // Override to support editing the table view.
    // This method allows us to handle deletion or insertion of rows into our table view
    // we use the editing style to check if there is a deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_TEAMS {
            
            let team = allTeams[indexPath.row]
            databaseController?.deleteTeam(team: team)
            databaseController?.cleanup() //save to database
            

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }

    //Allows us to provide the behaviour for when the user selects a row within the table view
    //This method will only be called for cells that have selection enabled.
    //BY DEFAULT: ALL TABLE VIEW CELLS HAVE THIS ENABLED
    //However, we disabled selection for the Info section back when creating the UI in the Storyboard
    //So, we need to deal with the behaviour when a TEAM cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == SECTION_TEAMS {
            
            //current team selected
            let currTeam = allTeams[indexPath.row]
            
            //When the team row is selected, we want to segue to the current part of this team
            //so each team has a party of 6 heroes
            
            performSegue(withIdentifier: "teamSegue", sender: currTeam)
            
        }
        
        //Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "teamSegue" {
           
            //Segue is just the selected row
            //We use this to find the team contect object
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedTeam = allTeams[indexPath.row]
                databaseController?.setCurrentTeam(team: selectedTeam)
            }
        
        }
    }
        
        

    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        
    }
    
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {
        
    }
    
    func onTeamsChange(change: DatabaseChange, teams: [Team]) {
        allTeams = teams
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

   
}
