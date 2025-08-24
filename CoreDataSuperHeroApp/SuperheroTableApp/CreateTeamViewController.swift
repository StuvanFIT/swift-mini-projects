//
//  CreateTeamViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 24/8/2025.
//

import UIKit

class CreateTeamViewController: UIViewController {
    
    @IBOutlet weak var teamTextField: UITextField!
    
    //Coredatabase controller access
    weak var databaseController: DatabaseProtocol?
    
    @IBAction func createTeam(_ sender: Any) {
        
        //Validate inputs
        guard let teamName = teamTextField.text, !teamName.isEmpty else {
            displayMessage(title: "Error", message: "You did not enter a team name!")
            return
        }
        
        //If we have reached the maximum number of teams, then return
        let allTeams = databaseController?.fetchAllTeams()
        let numOfTeams = allTeams?.count ?? 0
        if numOfTeams >= MAX_TEAMS {
            displayMessage(title: "Error", message: "Max number of teams is reached!")
            return
        }
        
        //Check if this name has already been used
        let trimmedTeamText = teamName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let teamAlreadyExists = allTeams?.contains {
            team in team.name?.lowercased() == trimmedTeamText
        } ?? false
        
        
        /*Using alert*/
        if (teamAlreadyExists) {
            
            let alert = UIAlertController(
                title: "Duplicate Team Name",
                message: "Team name has already been used!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        //else, we add the new created team to persisted storage
        let _ = databaseController?.addTeam(teamName: teamName)
        
        //save changes
        databaseController?.cleanup()
   
        //navigate back to all teams page
        navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
