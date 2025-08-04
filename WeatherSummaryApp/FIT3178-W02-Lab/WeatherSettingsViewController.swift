//
//  ViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 4/8/2025.
//

import UIKit

class WeatherSettingsViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var iconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colourSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colourPreviewView: UIView!
    
    //Actions
    @IBAction func colourSegmentedValueChange(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            
            // gets the selected segment (a colour name), appends “Colour” to it, and gets
            // corresponding colour from the Asset Catalog
            colourName = colourName.appending("Colour")
            colourPreviewView.backgroundColor = UIColor(named: colourName)
            
            
            let colour = colourPreviewView.backgroundColor?.cgColor
            
            //Create and store weather data inside weatherdetails struc
            var weatherDetails = WeatherDetails(description: description, backgroundColour: colour, icon: icon)
            
            let destination = segue.destination as! WeatherSummaryViewController
            destination.weatherDetails = weatherDetails
        }
    }
}

