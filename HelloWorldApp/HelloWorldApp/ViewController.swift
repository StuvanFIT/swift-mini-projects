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
    }
    
    @IBAction func sayHello(_ sender: Any) {
        sayHello()
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
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
        
        guard let ageText = ageField.text, let age = Int(ageText) else {
            // Age could not be established. Print an error and exit
            displayMessage(title: "Error", message: "Please enter a valid age")
            return
        }
        
        //Create an instance of Person with a name and age
        let person = Person(inputName:name, inputAge:age)
        
        //Call the greeting method and retrieve the message
        let message: String = person.greeting()
        let title: String = "Hello, if you are reading this, please buy some NVIDEA stock!"
        
        //Display the message to the end-user
        displayMessage(title: title, message: message)
        
        
    }
    

    

}

