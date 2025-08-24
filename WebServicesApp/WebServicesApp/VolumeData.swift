//
//  VolumeData.swift
//  WebServicesApp
//
//  Created by Steven Kaing on 24/8/2025.
//

import UIKit

class VolumeData: NSObject, Decodable {
    
    //Array of books
    var books: [BookData]?
    
    /*
     CodingKeys defines the mapping between the object and the format being decoded
     from (i.e., the JSON data).
     
     From the JSON, under the "items" field, we extract the elements under "items" into the books array
     
     So since the VolumeData looks at the "items" key and says:
     “That’s my [BookData] array", each entry in "items" is decoded into a BookData object WITH ALL THE LISTED PROPERTIES IN BOOKDATA like title, authors, publication etc....
     
     SO essentially, BookData serves as the blueprint to filter out any unnecessary fields and only keep the ones we need
     */
    private enum CodingKeys: String, CodingKey {
        case books = "items"
    }

}
