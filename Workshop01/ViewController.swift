//
//  ViewController.swift
//  Workshop01
//
//  Created by Steven Kaing on 29/7/2025.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var redSlider: UISlider!
    
    @IBOutlet weak var colourPreviewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        if sender == redSlider {
            print("Red")
        }
        else if sender == greenSlider {
            print("Green")
        }
        else if sender == blueSlider {
            print("Blue")
        }
        
        //Create the colour
        let redValue = CGFloat(redSlider.value)
        let greenValue = CGFloat(greenSlider.value)
        let blueValue = CGFloat(blueSlider.value)
        
        //Change the colour background of the view
        colourPreviewView.backgroundColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
            
        
        
    }
    
}

