//
//  CreateHeroViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 12/8/2025.
//

import UIKit

class CreateHeroViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var abilityTextField: UITextField!
    
    @IBOutlet weak var universeSegmentedControl: UISegmentedControl!
    
    
    @IBAction func createHero(_ sender: Any) {
        
        //Enum Universe: If the index matches one of the enum’s raw values, you get that enum case.
        //eg: if index = 0, then ennum result = .marvel
        guard let name = nameTextField.text, let abilities = abilityTextField.text, let universe = Universe(rawValue: Int32(universeSegmentedControl.selectedSegmentIndex))
        else {
            return
        }
    
    
        if name.isEmpty || abilities.isEmpty {
            
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if abilities.isEmpty {
                errorMsg += "- Must provide abilities"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        //Add the super bero via the databasecontroller method
        let _ = databaseController?.addSuperhero(name: name, abilities: abilities, universe: universe)
        
        databaseController?.cleanup()
        
        navigationController?.popViewController(animated: true)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Set up the databaseController value
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
