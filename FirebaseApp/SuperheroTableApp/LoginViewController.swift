//
//  LoginViewController.swift
//  SuperheroTableApp
//
//  Created by Steven Kaing on 8/9/2025.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, AuthListener {
    
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.authListener = self

    }
    
    
    func isSignedIn(user: FirebaseAuth.User) {
        //Since login is successful, perform segue to the current party screen
        //Fix error: call must be made onn the main thread
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    func isNotSignedIn(error: any Error) {
        DispatchQueue.main.async {
            self.displayMessage(
                title: "Login Attempt Failed",
                message: "Error: \(error.localizedDescription)"
            )
        }
    }
    
    
    
    
    @IBAction func login(_ sender: Any) {
        
        //Validate Fields
        guard let credentials = validateFields() else {
            return
        }
        
        Task {
            do {
                try await databaseController?.signInMethod((credentials.email, credentials.password))
            } catch {
                displayMessage(title: "Login Failed!", message: "Error: \(error.localizedDescription)")
            }
        }
        
        
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        //Validate Fields
        guard let credentials = validateFields() else {
            return
        }
        
        Task {
            do {
                try await databaseController?.createUserAccount((credentials.email, credentials.password))
            } catch {
                displayMessage(title: "Creating Account Failed!", message: "Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    func validateFields() -> (email: String, password: String)? {
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty,
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !password.isEmpty
        else {
            displayMessage(title: "Invalid Inputs", message: "Invalid Email or password!");
            return nil
        }
        
        //REGEX WAS SOURCED FROM STACK OVERFLOW
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if !emailPredicate.evaluate(with: email) {
            displayMessage(title: "Invalid Email", message: "Enter a valid email address!")
            return nil
        }
        
        
        if password.count < 6 {
            displayMessage(title: "Invalid Password", message: "Password is too short (less than 6 characters!")
            return nil
        }
        
        return (email, password)
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
