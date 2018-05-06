//
//  SearchViewController.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 28/01/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var eateries = [Eatery]()
    var isFirstSearch = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        noResultsView.isHidden = true;
    }
    
    // display a cancel button when the search bar is active
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.text = ""
    }
    
    // get the text from the search bar and send it to the web service
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isFirstSearch = false
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        let searchTerm = searchBar.text!
        // encode the search term to account for white spaces in the url
        let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var query = "?"
        if searchBar.selectedScopeButtonIndex == 0 {
            // name search selected
            query = "?op=s_name&name=\(encodedSearchTerm!)"
        } else if searchBar.selectedScopeButtonIndex == 1 {
            // postcode search selected
            query = "?op=s_postcode&postcode=\(encodedSearchTerm!)"
        }
        performSearch(query: query)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if the search returns an empty array then display a message that says "no results found"
        if eateries.count < 1 && isFirstSearch == false{
            noResultsView.isHidden = false
            self.noResultsView.transform = CGAffineTransform(scaleX:1.6, y: 1.6)
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.20),
                           initialSpringVelocity: CGFloat(3.0),
                           options: UIViewAnimationOptions.allowUserInteraction,
                           animations: {
                            self.noResultsView.transform = CGAffineTransform.identity
            }, completion: { Void in() })
        }
        
        return eateries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell")!
        let business = eateries[indexPath.row]
        
        cell.textLabel?.text = business.BusinessName
        cell.detailTextLabel?.text = "\(business.PostCode)"
        
        return cell
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        // closes the "no results found" message
        noResultsView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailsFromSearch", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromSearch" {
            let destination = segue.destination as! DetailsViewController
            destination.business = eateries[(tableView.indexPathForSelectedRow?.row)!]

            // once the data has been set for the segue, unselect the row so that it won't be highlighted
            // when the user returns to this screen.
            self.tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    // retrieve JSON data from web service
    func performSearch(query: String){
        let baseURL = "http://radikaldesign.co.uk/sandbox/hygiene.php"
        let url = URL(string: baseURL + query)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {print("error with data"); return}
            do {
                self.eateries = try JSONDecoder().decode([Eatery].self, from: data)
                print("\nParsing Successful!")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let err {
                print("Error: ", err)
            }
            
        }
        task.resume()
    }
}




