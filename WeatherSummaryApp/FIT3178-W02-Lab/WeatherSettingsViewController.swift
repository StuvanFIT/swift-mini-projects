//
//  ViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 4/8/2025.
//

import UIKit

class WeatherSettingsViewController: UIViewController, UITextFieldDelegate, ColourChangeDelegate {
    func changedToColour(_ colour: UIColor) {
        colourPreviewView.backgroundColor = colour
    }
    
    
    //Outlets
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var iconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colourSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colourPreviewView: UIView!
    
    //Actions
    
    //Manual Segue
    @IBAction func colourSegmentedValueChange(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let selectedTitle = sender.titleForSegment(at: selectedIndex)
        
        //If the selected segment index title is "Custom", then we navigate the user via the pickColourSegue
        if selectedTitle == "Custom" {
            performSegue(withIdentifier: "pickColourSegue", sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //This view controller will act as the delegate of the descriptionTextField (UITextField)
        //When the text field needs to know what to do, it calls the textFieldShouldReturn on its delegate
        descriptionTextField.delegate = self
    }
    
    /*
     The method takes in a segue object and the sender (the object that triggered the segue).
     The Any type signifies that it can be of any class.
     Called when ant segue is triggered within this view controller. We use this to pass data to the destination view controller.
     We can have multiple segues for each controller, so we only execute functionality relevant to a SPECIFIC transition, this can be checked
     if the segue identifier matches a specific string
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //When the user clicks on "Show weather summary"
        if segue.identifier == "showSummarySegue" {
            
            let description = descriptionTextField.text ?? ""
            var icon: WeatherIcon = .sun
            
            switch iconSegmentedControl.selectedSegmentIndex {
            case 1:
                icon = .clouds
            case 2:
                icon = .rain
            case 3:
                icon = .lightning
            case 4:
                icon = .snow
            default:
                icon = .sun
            }

            var colourName = colourSegmentedControl.titleForSegment(at: colourSegmentedControl.selectedSegmentIndex) ?? ""
            var selectedColour: UIColor?
            
            if colourName == "Custom" {
                selectedColour = colourPreviewView.backgroundColor
            } else {
                // gets the selected segment (a colour name), appends “Colour” to it, and gets
                // corresponding colour from the Asset Catalog
                let colourNameString = colourName + "Colour"
                selectedColour = UIColor(named: colourNameString)
                colourPreviewView.backgroundColor = selectedColour
            }
            
            //Create and store weather data inside weatherdetails struc
            let selectedColourCG = selectedColour?.cgColor
            let weatherDetails = WeatherDetails(description: description, backgroundColour: selectedColourCG, icon: icon)
            
            let destination = segue.destination as! WeatherSummaryViewController
            destination.weatherDetails = weatherDetails
            
        } else if segue.identifier == "pickColourSegue" {
            let destination = segue.destination as! ChooseColourViewController
            destination.delegate = self
            
        }
    }
    
    //UITextFieldDelegate  delegate method
    //we must assign a delegate to call this method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

