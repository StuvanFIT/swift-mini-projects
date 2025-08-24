//
//  SearchBooksTableViewController.swift
//  WebServicesApp
//
//  Created by Steven Kaing on 24/8/2025.
//

import UIKit

let CELL_BOOK = "bookCell"
let REQUEST_STRING = "https://www.googleapis.com/books/v1/volumes?q="

let NUMBER_OF_SECTIONS = 1


class SearchBooksTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    var newBooks =  [BookData]()  //Array of BookData objects for displaying to the user:
    var indicator = UIActivityIndicatorView() //ui element that displays the spinning loading animation
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create a search controller and attach it to the navigation item
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for books"
        searchController.searchBar.showsCancelButton = true
        navigationItem.searchController = searchController
        
        //Make sure the search bar is always visible to the user for easier accessibility
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Setup the UI Loading indicator view
        //we set the style of the indicator, turn oﬀ automatic constraints, and programmatically use constraints to centre it in the safeArea of the view:
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
            
        ])
        
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return NUMBER_OF_SECTIONS
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newBooks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOOK, for: indexPath)
        
        let book = newBooks[indexPath.row]
        bookCell.textLabel?.text = book.title
        bookCell.detailTextLabel?.text = book.authors
        
        return bookCell
    }
    
    /*
     This is the method we would call to execute a get request to the API to request book data.
     The async tells us that this function should execute asynchronously and using await for synchronous structure
     
     The requestURL is a combination of the request string constant property plus the
     search text entered by the user (encoded to use characters safe for UR
     */
    func requestBooksName(_ bookName: String) async {
        
        guard let queryString = bookName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query string cannot be encoded!")
            return
        }
        
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else {
            print("INVALID URL")
            return
        }
        
        
        let urlrequest = URLRequest(url: requestURL)
        
        
        /*The URLSession is marked with the await keyword to say that code will stop executing
         at this point in the method and await a response from the data task. As this is
         communicating with an internet resource this is not immediate and can take an
         indeterminate amount of time. Further code within the function is not executed until this
         is completed. However, the rest of the application continues running as normal.*/
        do {
            
            let (data, response) = try await URLSession.shared.data(for: urlrequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data)
            
            //If the jSON data books has been sucessfully filtered/adjusted (decoded) to the bookData template
            //This adds the new books onto the existing array. Often used for:
            // Pagination (loading page 2, 3, etc. of search results).
            // Merging multiple queries without wiping what you already had.
            if let books = volumeData.books {
                newBooks.append(contentsOf: books)
                
                let selectedRows = tableView.indexPathsForSelectedRows
                tableView.reloadData()
                
                if let selectedRows = selectedRows {
                    for indexPath in selectedRows {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    }
                }
            }
            
        } catch let error {
            indicator.stopAnimating()
            print(error)
        }
        
        
        
        
        
    }
    
    /*
     This method is responsible for making a request to the API, receiving results and
     parsing them into a usable format.
     Before executing a query, we must first create the URL for the API request.
     */
    func requestsBooksNamed() {
        
        
    }
    
    
    /*
     earchBarTextDidEndEditing method
     from the UISearchBarDelegate protocol. This is called if the user hits enter or taps the
     search button after typing in the search field. It is also called when they tap cancel.
     
     When the method is called, we should empty the current list of newBooks and refresh
     the tableView, as a new search is about to begin:
     */
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        //if the search text is empty
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        //Reset old results
        newBooks.removeAll()
        tableView.reloadData()
        
        //Dismiss the keyboard
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        // Run the async API request in a new Task/
        Task {
            await requestBooksName(searchText)
            indicator.stopAnimating()
            tableView.reloadData()
        }
    }
}
