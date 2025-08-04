//
//  ChooseColourViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 4/8/2025.
//

import UIKit

protocol ColourChangeDelegate: AnyObject {
    func changedToColour(_ colour: UIColor)
}

class ChooseColourViewController: UIViewController {
    
    //Delegate
    weak var delegate: ColourChangeDelegate?
    
    //Outlets
    @IBOutlet weak var colourView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let redValue = CGFloat(redSlider.value)
        let greenValue = CGFloat(greenSlider.value)
        let blueValue = CGFloat(blueSlider.value)
        
        let newColour = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        colourView.backgroundColor = newColour
        
        //Call the delegate to inform of new colour changes
        delegate?.changedToColour(newColour)
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
