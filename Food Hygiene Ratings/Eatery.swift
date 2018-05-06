//
//  Eatery.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 24/01/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import Foundation

class Eatery: Codable {
    let id: String
    let BusinessName: String
    let AddressLine1: String
    let AddressLine2: String
    let AddressLine3: String
    let PostCode: String
    let RatingValue: String
    let RatingDate: String
    let Longitude: String
    let Latitude: String
    let DistanceKM: String?
}

