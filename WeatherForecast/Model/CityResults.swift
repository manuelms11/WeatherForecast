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
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case fullname = "matching_full_name"
    }
}

