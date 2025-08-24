//
//  BookData.swift
//  WebServicesApp
//
//  Created by Steven Kaing on 24/8/2025.
//

import UIKit




class BookData: NSObject, Decodable {
    
    var title: String
    var isbn13: String?
    var authors: String?
    var publisher: String?
    var publicationDate: String?
    var bookDescription: String?
    var imageURL: String?

    
    /*
     
     When you make a CodingKeys enum inside your type, you’re telling Swift:
     “Here are the keys you should look for in the JSON (or write out when encoding).”
     
     
     The only thing we need to access within the root is the "volumeInfo" nested
     JSON object.
     
     Where the case matches our property names, we do not need to specify it with a value.
     Only in instances where they diﬀer—such as publicationDate and bookDescription
     (named so because NSObject has a builtin description method)—are we required. All
     properties that we wish to obtain from the JSON data MUST be specified.
     
     For example:
     if the JSON key is description, but your model has bookDescription, there would be a mismatch
     if the JSON jey is title, and your model has title, it mathces automatically, you do not need to do anything
     */
    private enum RootKeys: String, CodingKey {
         case volumeInfo
    }
    private enum BookKeys: String, CodingKey {
        case title
        case publisher
        case publicationdDate = "publicationDate"
        case bookDescription = "description"
        case authors
        case industryIdentifiers
        case imageLinks
    }
    
    private enum ImageKeys: String, CodingKey {
        case smallThumbnail
    }
    
    /*
     Struct vs Enum
     "industryIdentifiers": [
       { "type": "ISBN_10", "identifier": "013461061X" },
       { "type": "ISBN_13", "identifier": "9780134610610" }
     ]
     An enum is great when you have one choice among many fixed options (e.g. .hardcover, .paperback, .ebook).
     But here, each record has two fields together → that naturally fits a struct.
     
     If you made type a struct, then we would have to harcode all possibel types like ISBN_10,13,1,41,5,16.....
     */
    private struct ISBNCode: Decodable {
        var type: String
        var identifier: String
    }
    
    /*
    How decoding works with your code
     
     The VolumeData looks at the "items" key and says:
     “That’s my [BookData] array.”
     Then each item goes through your custom required init(from:) in BookData:
     
     title → "Swift Programming"
     authors → ["John Appleseed", "Jane Doe"] → "John Appleseed, Jane Doe"
     publisher → "Apple Press"
     publicationDate → "2020-06-15"
     bookDescription → "Learn to build iOS apps with Swift."
     isbn13 → "9780134610610"
     imageURL → "http://books.google.com/swift_thumb.jpg"
     
     */
    required init(from decoder: Decoder) throws {
        
        //Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        //Get the book container for most info
        let bookContainer = try rootContainer.nestedContainer(keyedBy: BookKeys.self, forKey: .volumeInfo)
        
        //Get the image links container for the thumbnail
        let imageContainer = try? bookContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageLinks)
        
        
      
        /*
         We can retrieve the main data from the bookContainer
         
         A decode attempt can fail
         which is why the try keyword is used, though a do-catch statement is not present. That
         is because it is handled by whichever code attempts to decode a book! For optional
         properties that may or not be present, a “try?” statement is used, since if that decode
         fails it just results in a value of nil for the property.
         
         */
        title = try bookContainer.decode(String.self, forKey: .title)
        publisher = try? bookContainer.decode(String.self, forKey: .publisher)
        publicationDate = try? bookContainer.decode(String.self, forKey: .publicationdDate)
        bookDescription = try? bookContainer.decode(String.self, forKey: .bookDescription)
        
        // Get authors as an array then compact : "Author a, Author b.."
        if let authorArray = try? bookContainer.decode([String].self, forKey: .authors) {
            authors = authorArray.joined(separator: ", ")
        }
        
        if let isbnCodes = try? bookContainer.decode([ISBNCode].self, forKey: .industryIdentifiers) {
            for code in isbnCodes {
                if code.type == "ISBN_13" {
                    isbn13 = code.identifier
                }
            }
        }
        
        imageURL = try imageContainer?.decode(String.self, forKey: .smallThumbnail)
        
        
    }
    

}
