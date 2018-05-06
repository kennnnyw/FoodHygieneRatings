//
//  DetailsViewController.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 25/01/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingDateLabel: UILabel!
    @IBOutlet weak var segController: UISegmentedControl!
    
    var business: Eatery!
    var selectedSeg: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMapView.delegate = self
        if (selectedSeg != nil) {
            // ruse the same map type as on the main screen
            segController.selectedSegmentIndex = selectedSeg
            mapToggleAction(segController)
        }
        segController.addTarget(self, action: #selector(mapToggleAction), for: .valueChanged)
        
        // populate labels with appropriate text
        nameLabel.text = business.BusinessName.uppercased()
        
        if business.AddressLine1 != "" {
            addressLabel.text = "\(business.AddressLine1), \(business.AddressLine2), \(business.AddressLine3), \(business.PostCode)"
        } else {
            addressLabel.text = "\(business.AddressLine2), \(business.AddressLine3), \(business.PostCode)"
        }
        
        ratingDateLabel.text = "Last Inspection: \(business.RatingDate)"
        
        // display appropriate rating image
        let rating = business.RatingValue
        
        switch rating {
        case "5":
            ratingImageView.image = UIImage(named: "rating_5")
        case "4":
            ratingImageView.image = UIImage(named: "rating_4")
        case "3":
            ratingImageView.image = UIImage(named: "rating_3")
        case "2":
            ratingImageView.image = UIImage(named: "rating_2")
        case "1":
            ratingImageView.image = UIImage(named: "rating_1")
        case "0":
            ratingImageView.image = UIImage(named: "rating_0")
        case "-1":
            ratingImageView.image = UIImage(named: "rating_exempt")
        default:
            ratingImageView.image = UIImage(named: "rating_exempt")
        }
        
        // display business location on the map
        let location = CLLocationCoordinate2D(latitude: Double(business.Latitude)!, longitude: Double(business.Longitude)!)
        let span = MKCoordinateSpanMake(0.003,0.003)
        let region = MKCoordinateRegion(center: location, span: span)
        locationMapView.setRegion(region, animated: true)
        
        // determine the type of map pin to be used (depends on whether the screen was accessed via
        // search or via the main screen)
        var pin: CustomMapPin
        if business.DistanceKM != nil {
            pin = CustomMapPin(distance: business.DistanceKM!, rating: business.RatingValue)
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(business.Latitude)!, longitude: Double(business.Longitude)!)
            pin.title = business.BusinessName
            self.locationMapView.addAnnotation(pin)
        }
        else {
            pin = CustomMapPin(rating: business.RatingValue)
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(business.Latitude)!, longitude: Double(business.Longitude)!)
            pin.title = business.BusinessName
            self.locationMapView.addAnnotation(pin)
        }
        
        locationMapView.addAnnotation(pin)
    }
    
    @IBAction func mapToggleAction(_ sender: UISegmentedControl) {
        // handles the style of map that is displayed
        switch sender.selectedSegmentIndex {
        case 0:
            self.locationMapView.mapType = .standard
        case 1:
            self.locationMapView.mapType = .satellite
        case 2:
            self.locationMapView.mapType = .hybrid
        default:
            self.locationMapView.mapType = .standard
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // handles displaying the custom map pins on the map
        guard !annotation.isKind(of:MKUserLocation.self) else {return nil}
        
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
