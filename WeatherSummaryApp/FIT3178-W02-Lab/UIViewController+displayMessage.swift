//
//  UIViewController+displayMessage.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 5/8/2025.
//
import UIKit

extension UIViewController {

    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
            preferredStyle: .alert)
                
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
            handler: nil))
                
        self.present(alertController, animated: true, completion: nil)
    }
}
