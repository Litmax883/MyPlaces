//
//  ViewController.swift
//  MyPlaces
//
//  Created by MAC on 28.07.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    private var places: Results<Place>!
    private var ascendingSorting = true
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlaces: Results<Place>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedContorol: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
        }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
        tableView.reloadData()
    }
    
    @IBAction func reverseSorting(_ sender: Any) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage.init(systemName: "arrow.turn.right.down")
        } else {
            reversedSortingButton.image = UIImage.init(systemName: "arrow.turn.right.up")
        }
        sorting()
        tableView.reloadData()
    }
    
    private func sorting() {
        if segmentedContorol.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Покушать в Евпатории"
        
        places = realm.objects(Place.self)
        
        //set up search controller
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.cosmosView.rating = place.rating
        cell.imageInCell.image = UIImage(data: place.imageData!)

        return cell
    }
    
    // Table view delegate - DELETE ROWS
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    // Detail VC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}

