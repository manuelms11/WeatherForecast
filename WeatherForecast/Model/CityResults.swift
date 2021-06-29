//
//  CityResults.swift
//  WeatherForecast
//
//  Created by Lorenzo Rodriguez on 6/26/21.
//

import Foundation

struct CityResults: Codable {
    var fullname: String
    var links: CityLink
    var matchingAlternateNames: [MatchingAlternateName]
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case fullname = "matching_full_name"
        case matchingAlternateNames = "matching_alternate_names"
    }
}

struct MatchingAlternateName: Codable {
    let name: String
}
