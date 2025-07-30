//
//  ViewController.swift
/*
 A view controller is a class that controls
 a view (usually a single screen) and its
 behaviour. One is included and linked by
 default in a single-screen project. We
 can also add our own view controllers.
 */
//  HelloWorldApp
//
//  Created by Steven Kaing on 29/7/2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpDateField()
    }
    
    @IBAction func sayHello(_ sender: Any) {
        sayHello()
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var birthDateField: UITextField!
    @IBOutlet weak var datePickerField: UIDatePicker!
    
    func displayMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
/*
 When we create the age variable, we use the prefix guard. Converting a String to an Int
 can fail and return a nil value. The guard-else block of code says that if the Int would
 be nil, it should instead display an error and return from the method (going no further).
 If the condition check passes, then age is a valid Int variable scoped (available to use)
 to the rest of the method.
 */
    func sayHello() {
        guard let name = nameField.text, name.isEmpty == false else {
            displayMessage(title: "ERROR:", message:"Please enter a name!")
            return
        }
        
        //Extension 1/2:

        guard let birthDateText = birthDateField.text, !birthDateText.isEmpty else {
            // dob could not be established. Print an error and exit
            displayMessage(title: "Error", message: "Please enter your date of birth in the format YYYY-MM-DD")
            return
        }
        
        //Parse the birth date text and convert to the birthDateText into a Date instance
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current

        guard let birthDate = formatter.date(from: birthDateText) else {
            displayMessage(title: "Error", message: "Date Format must be in YYYY-MM-DD")
            return
        }
        
        
        
//        //Extension 3:
//        //datePickerField may be null
//        guard let birthDate = datePickerField?.date else {
//            displayMessage(title: "ERROR:", message: "Date picked is not found. Please contact us for help!")
//            return
//        }
//       
        

        
        //Create an instance of Person with a name and dob
        let person = Person(inputName:name, inputDate: birthDate)
        
        //Call the greeting method and retrieve the message
        let message: String = person.greeting()
        let title: String = "Hello, if you are reading this, have a great day!"
        
        //Display the message to the end-user
        displayMessage(title: title, message: message)
    }
    
    func setUpDateField() {
        //Set the placeholder
        birthDateField.placeholder = "YYYY-MM-DD"
    }

    

}

