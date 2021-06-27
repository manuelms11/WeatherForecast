//
//  Embedded.swift
//  WeatherForecast
//
//  Created by Lorenzo Rodriguez on 6/26/21.
//

import Foundation

struct Embedded: Codable {
    var results: [CityResults]
    
    enum CodingKeys: String, CodingKey {
        case results = "city:search-results"
    }
}
