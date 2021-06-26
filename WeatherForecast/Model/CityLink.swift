//
//  CityLink.swift
//  WeatherForecast
//
//  Created by Lorenzo Rodriguez on 6/26/21.
//

import Foundation

struct CityLink: Codable {
    var cityItem: CityItemLink
    
    enum CodingKeys: String, CodingKey {
        case cityItem = "city:item"
    }
}
