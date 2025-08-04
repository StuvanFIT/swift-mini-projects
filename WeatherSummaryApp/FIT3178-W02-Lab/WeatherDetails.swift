//
//  WeatherDetails.swift
//  FIT3178-W02-Lab
//
//  Created by Steven Kaing on 4/8/2025.
//

import Foundation
import CoreGraphics

//Enumeration for weather type icons
enum WeatherIcon {
    case sun
    case clouds
    case rain
    case lightning
    case snow
}

//Structure WeatherDetails
struct WeatherDetails {
    var description: String
    var backgroundColour: CGColor?
    var icon: WeatherIcon
    
    //Returns string weather icon name
    func iconImageName() -> String {
        switch icon {
            case .clouds:
                return "cloud.fill"
            case .rain:
                return "cloud.rain.fill"
            case .lightning:
                return "cloud.bolt.fill"
            case .snow:
                return "cloud.snow.fill"
            default:
                return "sun.max.fill"
        }
    }
}


