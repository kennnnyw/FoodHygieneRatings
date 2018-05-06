//
//  CustomMapPin.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 19/02/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import UIKit
import MapKit

class CustomMapPin: MKPointAnnotation {
    var image: UIImage!
    var distance: String?
    var rating: String?
    
    // map pin for the main screen and the business details screen (when accessed from the main screen)
    // annotation displays the distance to the business from the user location
    init(distance: String, rating: String){
        super.init()
        // format distance value (to 3 d.p.)
        let distanceAsDouble: Double = Double(distance)!
        let distanceRounded = Double(floor(1000*distanceAsDouble)/1000)
        self.distance = String(distanceRounded)
        
        self.subtitle = "\(distanceRounded) km"
        self.setImage(rating: rating)
    }
    
    // map pin for the business details screen (when accessed from a search result)
    // a search result does not provide a distance value,
    // so the business rating is shown in the annotation instead
    init(rating: String){
        super.init()
        self.setImage(rating: rating)
        self.subtitle = "Rating: \(rating)"
    }
    
    func setImage(rating: String){
        // select the appropriate pin image for the map pin
        switch rating {
        case "5":
            self.image = UIImage(named: "RatingPin5")
        case "4":
            self.image = UIImage(named: "RatingPin4")
        case "3":
            self.image = UIImage(named: "RatingPin3")
        case "2":
            self.image = UIImage(named: "RatingPin2")
        case "1":
            self.image = UIImage(named: "RatingPin1")
        case "0":
            self.image = UIImage(named: "RatingPin0")
        case "-1":
            self.image = UIImage(named: "RatingPinExempt")
        default:
            self.image = UIImage(named: "RatingPinExempt")
        }
    }
}
