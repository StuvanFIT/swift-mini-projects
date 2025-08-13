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

class AllHeroesTableViewController: UITableViewController, UISearchResultsUpdating, AddSuperheroDelegate {
    
    var allHeroes: [Superhero] = []
    var filteredHeroes: [Superhero] = []
    
    weak var superHeroDelegate: AddSuperheroDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initialiseSuperheroes()
        filteredHeroes = allHeroes
        configureSearchBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createHeroSegue" {
            let destination = segue.destination as! CreateHeroViewController
            destination.superHeroDelegate = self
        }
    }
    
    func initialiseSuperheroes() {
        allHeroes.append(Superhero(name: "Superman", abilities: "Super Powered Alien", universe:
        .dc))
        allHeroes.append(Superhero(name: "Wonder Woman", abilities: "Goddess", universe: .dc))
        allHeroes.append(Superhero(name: "The Flash", abilities: "Speed", universe: .dc))
        allHeroes.append(Superhero(name: "Green Lantern", abilities: "Power Ring", universe:
        .dc))
        allHeroes.append(Superhero(name: "Cyborg", abilities: "Robot Beep Beep", universe: .dc))
        allHeroes.append(Superhero(name: "Aquaman", abilities: "Atlantian", universe: .dc))
        allHeroes.append(Superhero(name: "Ironman", abilities: "Maximum Pulse", universe: .marvel))
        allHeroes.append(Superhero(name: "Captain America", abilities: "Avengers Assemble", universe: .marvel))
        allHeroes.append(Superhero(name: "Hulk", abilities: "Hulk is angry", universe: .marvel))
        allHeroes.append(Superhero(name: "Black Panther", abilities: "Wakanda", universe: .marvel))
        allHeroes.append(Superhero(name: "Thor", abilities: "Might of Ragnorak", universe: .marvel))
        allHeroes.append(Superhero(name: "Spiderman", abilities: "Sticky web", universe: .marvel))
        allHeroes.append(Superhero(name: "Ben 10", abilities: "Ultimatrix", universe: .other))
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
        
        //Add the scope bar buttons
        searchController.searchBar.scopeButtonTitles = ["All", "Marvel", "DC", "Other"]
        searchController.searchBar.showsScopeBar = true
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
        
        //Scope bar: retrive the currently selected scope bar index
        let selectedScopeIndex = searchController.searchBar.selectedScopeButtonIndex
        let scopeButtonTiles = searchController.searchBar.scopeButtonTitles ?? []
        

        /*
         filter must return boolean
         For each element/hero, it returns true if the hero can stay in the new array
         else, the hero is removed from the array
         
         For a filtered hero to be valid, it must match the selected scope bar index and search text
         */
        filteredHeroes = allHeroes.filter { hero in 
            matchesScopeSegment(hero: hero, selectedScopeIndex: selectedScopeIndex, scopeButtonTiles: scopeButtonTiles)
            && matchesSearchText(hero: hero, searchText: searchText)
        }
        
        tableView.reloadData()
    }
    
    
    /*
     Checks to see if the hero's universe matches the scope bar filter titles (i.e. marvel, dc, other)
     */
    func matchesScopeSegment(hero: Superhero, selectedScopeIndex: Int, scopeButtonTiles: [String]) -> Bool {
        if selectedScopeIndex < scopeButtonTiles.count {
            let selectedScope = scopeButtonTiles[selectedScopeIndex]
            switch selectedScope {
            case "All":
                return true
            case "Marvel":
                return hero.universe == .marvel
            case "DC":
                return hero.universe == .dc
            case "Other":
                return hero.universe == .other
            default:
                return true
            }
        } else {
            //if an invalid scope bar index is selected, then we just pass the hero (show all heroes)
            return true
        }
    }
    
    func matchesSearchText(hero: Superhero, searchText: String) -> Bool {
        if !searchText.isEmpty {
            return hero.name?.lowercased().contains(searchText) ?? false
        } else {
            return true
        }
    }
    
    
    
    
    
    func addSuperhero(_ newHero: Superhero) -> Bool {
        //Validate the new superhero
        //Check if the superhero name already exists in the (case sensitive) all super hero list
        let result =  filteredHeroes.contains(where: {hero in hero.name?.lowercased() == newHero.name?.lowercased()})
        
        //If there is an already existing superhero with the same name as the new superhero, then do nto add the superhero
        if (result) {
            return false
        }
        
        tableView.performBatchUpdates({
    
            allHeroes.append(newHero)
            filteredHeroes.append(newHero)
            
            //Insert the new hero into the tableview
            tableView.insertRows(at: [IndexPath(row: filteredHeroes.count - 1, section: HERO_SECTION)], with: .automatic)
            
            tableView.reloadSections([SECTION_INFO], with: .automatic)
        }, completion: nil)
        
        return true
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
            
            //The below 3 steps need to be executed in one single batch.
            //This is necessary when multiple changes occur at once to a table view or collection view
            tableView.performBatchUpdates({
                //Remove the hero from the current party: from both the filtered and original list
                if let index = self.allHeroes.firstIndex(of: filteredHeroes[indexPath.row]) {
                    self.allHeroes.remove(at: index)
                }
                self.filteredHeroes.remove(at: indexPath.row)
                
                
                
                //Delete the row from the table view/
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                //Update the info section
                self.tableView.reloadSections([HERO_SECTION], with: .automatic)
            
            }, completion: nil)
            
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
        if let superHeroDelegate = superHeroDelegate {
            if superHeroDelegate.addSuperhero(filteredHeroes[indexPath.row]) {
                navigationController?.popViewController(animated: true)
                return
            }
            else {
                displayMessage(title: "Cannot Add Superhero to party", message: "Your party is full or this superhero already exists in your party!")
            }
        }
        
        //Deselect the recently pressed row
        tableView.deselectRow(at: indexPath, animated: true)
        
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
