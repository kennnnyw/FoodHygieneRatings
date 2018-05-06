//
//  ViewController.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 23/01/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segController: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    var eateries = [Eatery]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        segController.addTarget(self, action: #selector(mapToggleAction), for: .valueChanged)
        
        // requesting location permissions, if the user denies permission then
        // their current position will not be shown on the map, and list of nearby places won't be retrieved
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // if user grants permission, display current location on the map view and get a list of nearby places
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
            tableView.delegate = self
            tableView.dataSource = self
            
        }
    }
    
    @IBAction func mapToggleAction(_ sender: UISegmentedControl) {
        // handles the style of map that is displayed
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
    }
    
    @IBAction func searchButtonClick(_ sender: Any) {
        print("Search Button Clicked")
        performSegue(withIdentifier: "showSearchScreen", sender: self)
    }
    
    // get current user location and display it on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation = locations.first!
        
        // specifying the position on the map
        // how zoomed in should the map be? (decrease values to zoom out)
        let span = MKCoordinateSpanMake(0.0025,0.0025)
        let region = MKCoordinateRegion(center: myLocation.coordinate, span: span)
       
        // display on map
        mapView.setRegion(region, animated: true)
        
        // pass position co-ordinates to the web service
        getNearbyPlaces(position: myLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error retrieving location")
    }
    
    // retrieve JSON data from web service
    func getNearbyPlaces(position: CLLocationCoordinate2D){
        // these values are used as parameter values for the s_loc operation
        let urlLat = position.latitude
        let urlLong = position.longitude
        
        let baseURL = "http://radikaldesign.co.uk/sandbox/hygiene.php"
        let query = "?op=s_loc&lat=\(urlLat)8&long=\(urlLong)"
        let url = URL(string: baseURL + query)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {print("error with data"); return}
            do {
                self.eateries = try JSONDecoder().decode([Eatery].self, from: data)
                print("\nParsing Successful!")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    // clear map of any pins
                    self.mapView.removeAnnotations(self.mapView.annotations)

                    // creating map pins for each eatery that was retrieved
                    for place in self.eateries {
                        let pin = CustomMapPin(distance: place.DistanceKM!, rating: place.RatingValue)
                        pin.coordinate = CLLocationCoordinate2D(latitude: Double(place.Latitude)!, longitude: Double(place.Longitude)!)
                        pin.title = place.BusinessName
                        self.mapView.addAnnotation(pin)
                    }
                }
            } catch let err {
                print("Error: ", err)
            }
        }
        task.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // handles displaying the custom map pins on the map
        if annotation.isKind(of: MKUserLocation.self) {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "LocationPin")
            return annotationView
        } else {
            let annotationIdentifier = "AnnotationIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }
            
            let customPointAnnotation = annotation as! CustomMapPin
            annotationView!.image = customPointAnnotation.image
            return annotationView
        }
    }
    
    // handles table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eateries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eateryCell") as! EateryTableViewCell
        
        // set business name
        cell.nameLabel.text = eateries[indexPath.row].BusinessName
        
        let rating = eateries[indexPath.row].RatingValue
        
        // set appropriate rating image
        switch rating {
        case "5":
            cell.ratingImage.image = UIImage(named: "rating_5")
        case "4":
            cell.ratingImage.image = UIImage(named: "rating_4")
        case "3":
            cell.ratingImage.image = UIImage(named: "rating_3")
        case "2":
            cell.ratingImage.image = UIImage(named: "rating_2")
        case "1":
            cell.ratingImage.image = UIImage(named: "rating_1")
        case "0":
            cell.ratingImage.image = UIImage(named: "rating_0")
        case "-1":
            cell.ratingImage.image = UIImage(named: "rating_exempt")
        default:
            cell.ratingImage.image = UIImage(named: "rating_exempt")
        }
        return cell
    }
    
    // clicking on an item in the table view opens the details screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showBusinessDetails", sender: self)
    }
    
    // handles segue to details screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusinessDetails" {
            let destination = segue.destination as! DetailsViewController
            destination.business = eateries[(tableView.indexPathForSelectedRow?.row)!]
            destination.selectedSeg = segController.selectedSegmentIndex
            // once the data has been set for the segue, unselect the row so that it won't be highlighted
            // when the user returns to this screen.
            self.tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
}


// uni location
// lat = 53.470975
// long = -2.238764
