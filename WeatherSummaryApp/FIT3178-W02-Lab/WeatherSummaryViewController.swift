//
//  WeatherSummaryViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 4/8/2025.
//

import UIKit

class WeatherSummaryViewController: UIViewController {
    //Variables
    var weatherDetails: WeatherDetails?
    
    //Outlets
    @IBOutlet weak var summaryButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Value is set from destination.weatherDetails =  weatherDetails
        guard let weatherDetails = weatherDetails else {
            return
        }
        
        //Use the weatherDetails description, icon and background colour fields
        
        //Set description
        summaryButton.setTitle(weatherDetails.description, for: .normal)
        
        //Retrieve and set the button image
        let buttonImage = UIImage(systemName: weatherDetails.iconImageName());
        summaryButton.setImage(buttonImage, for: .normal)
        
        //Set the colour only if valid
        if let colour = weatherDetails.backgroundColour {
            summaryButton.tintColor = UIColor(cgColor: colour)
        }
        
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
