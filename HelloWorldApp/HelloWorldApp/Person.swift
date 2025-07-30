//
//  Person.swift
//  HelloWorldApp
//
//  Created by Steven Kaing on 29/7/2025.
//

import UIKit

class Person: NSObject {
    var name: String
    var birthDate: Date
    
    init(inputName: String, inputDate: Date) {
        name = inputName
        birthDate = inputDate //base: changed from age --> ext 1: dob
    }
    
    func greeting() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current //use the users device current locale regional settings
        formatter.dateStyle = .long //styles how the date looks: .long displays the date as i.e. July 29 2025, .short 29/07/2025
        formatter.timeStyle = .none //styles how the time looks:  no time is shown
        
        //This converts a Date object (like Date()) into a human-readable String, using the styles you specified.
        let formattedDate = formatter.string(from: birthDate)
        
        //Calculate the difference in years, months and days
        let timeAliveComponents = calculateDifferenceDate()
        
        let dayComponent = timeAliveComponents.day ?? 0
        let monthComponent = timeAliveComponents.month ?? 0
        let yearComponent = timeAliveComponents.year ?? 0
        
        let dayComponentText = dayComponent == 1 ? "1 day" : "\(dayComponent) days"
        let monthComponentText = monthComponent == 1 ? "1 month" : "\(monthComponent) months"
        let yearComponentText = yearComponent == 1 ? "1 year" : "\(yearComponent) years"
        
        let daysAlive = daysUserAlive();
        
        return "Hello \(name)! You were born on \(formattedDate)! You have been alive for \(yearComponentText), \(monthComponentText) and \(dayComponentText)! Or, we can say that you have been on this Earth for a total of \(daysAlive) days!"
    }
    
    func calculateDifferenceDate() -> DateComponents{
        //Calendar class has a method called: dateComponents -> returns the difference between 2 dates for each specified component
        let calendar = Calendar.current
        
        //Present date
        let currDate = Date()
        
        //Calculate the difference between the 2 dates: present - birth date.
        //We will do this for days, months and years
        let componentSet: Set<Calendar.Component> = [.year, .month, .day]
        
        //note that calendar.dataComponents returns an instance of the struc DataComponents, which has optional values like year, month, day, hour...
        let timeAliveComponents = calendar.dateComponents(componentSet, from: birthDate, to: currDate)
        print(timeAliveComponents)
        
        return timeAliveComponents
    }
    
    func daysUserAlive () -> Int {
        let calendar = Calendar.current
        let currDate = Date()
        let result = calendar.dateComponents([.day], from: birthDate, to: currDate)
        return result.day ?? 0
    }

}
