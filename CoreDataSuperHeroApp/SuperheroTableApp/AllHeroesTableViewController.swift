//
//  AllHeroesTableViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 12/8/2025.
//

import UIKit

let HERO_SECTION = 0
let INFO_SECTION = 1

let HERO_CELL = "heroCell"
let INFO_CELL = "totalCell"

class AllHeroesTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener{
    func onTeamsChange(change: DatabaseChange, teams: [Team]) {
        
    }
    
    
    var allHeroes: [Superhero] = []
    var filteredHeroes: [Superhero] = []
    
    weak var superHeroDelegate: AddSuperheroDelegate?
    
    var listenerType = ListenerType.heroes
    weak var databaseController: DatabaseProtocol?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        filteredHeroes = allHeroes
        configureSearchBar()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createHeroSegue" {
            let destination = segue.destination as! CreateHeroViewController

        }
    }
    
    
    func configureSearchBar() {
        //Assign the searchController delegate to this view controller
        let searchController = UISearchController( searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation =  false
        searchController.searchBar.placeholder = "Search All Heroes"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
    }

    
    //This method will be called every time a change is detected in the search bar
    func updateSearchResults(for searchController: UISearchController) {
        /*
         Before starting any filtering, we want to make sure that there is search text to be
         accessed. The search text is converted to lowercase so that we do not have to worry
         about case sensitivity.
         */
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        /*
         filter must return boolean
         For each element/hero, it returns true if the hero can stay in the new array
         else, the hero is removed from the array
         */
        if searchText.count > 0 {
            filteredHeroes = allHeroes.filter({ (hero: Superhero) -> Bool in
                return (hero.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredHeroes = allHeroes
        }
        tableView.reloadData()
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         INFO_SECTION -> ALWAYS 1 ROW (HERO INFO)
         HERO_SECTION -> Number of rows === Number of super heroes in the current party
         */
        switch section {
            case INFO_SECTION:
                return 1
            case HERO_SECTION:
                return filteredHeroes.count
            default:
                return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == HERO_SECTION {
            let heroCell = tableView.dequeueReusableCell(withIdentifier: HERO_CELL, for: indexPath)
            
            var content =  heroCell.defaultContentConfiguration()
            let hero = filteredHeroes[indexPath.row]
            content.text = hero.name
            content.secondaryText = hero.abilities
            
            heroCell.contentConfiguration = content
            
            return heroCell
        } else {
            
            //dequeue the cell and cast it to the custom cell type, this allows us to use the totalLabel in our custome Table View Cell
            //if forced casting fails, the app will crash. So only do it if you know 100% that the cell type you are casting is a particular type
            let infoCell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL, for: indexPath) as! HeroCountTableViewCell
            
            infoCell.totalLabel?.text = "\(filteredHeroes.count) Heroes in the database!"
            
            return infoCell

        }
    }


    // Override to support conditional editing of the table view.
    // Allows us to specify whether a certain row can be edited by the user: updating or deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case HERO_SECTION:
            return true
        case INFO_SECTION:
            return false
        default:
            return false
        }
    }

    // Override to support editing the table view.
    // This method allows us to handle deletion or insertion of rows into our table view
    // we use the editing style to check if there is a deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == HERO_SECTION {
            
            let hero = filteredHeroes[indexPath.row]
            databaseController?.deleteSuperhero(hero: hero)
            databaseController?.cleanup() //save to database
            

            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    //Allows us to provide the behaviour for when the user selects a row within the table view
    //This method will only be called for cells that have selection enabled.
    //BY DEFAULT: ALL TABLE VIEW CELLS HAVE THIS ENABLED
    //However, we disabled selection for the Info section back when creating the UI in the Storyboard
    //So, we need to deal with the behaviour when a Hero cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //We want this to call the addSuperhero method and passing it the superhero
        //Check if there is a delegate assigned first
        let hero = filteredHeroes[indexPath.row]
        let heroAdded = databaseController?.addHeroToTeam(hero: hero, team: databaseController!.currentTeam!) ?? false
        databaseController?.cleanup()
        
        if heroAdded {
            navigationController?.popViewController(animated: true)
            return
        }
        displayMessage(title: "Cannot Add Hero", message: "Your party is full OR the hero has already been added in your party!")
        //Deselect the recently pressed row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    /*
     
     With these two methods (viewWillAppear viewWillDisappear) the View Controller will automatically register itself to receive
     updates from the database when the view is about to appear on screen and deregister
     itself when it’s about to disappear
     */
    
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
    
    /*
     When onAllHeroesChange is called we need to update our full hero list then update
     our filtered list based on the search results.
     */
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {
        allHeroes = heroes
        
        updateSearchResults(for: navigationItem.searchController!)
    }

    /*
     We need to implement the method, but it
     will do nothing. This class does not care about team updates.
     */
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        // Do nothing
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
