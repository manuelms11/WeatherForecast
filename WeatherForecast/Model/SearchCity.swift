//
//  SearchCity.swift
//  WeatherForecast
//
//  Created by Lorenzo Rodriguez on 6/26/21.
//

import Foundation


struct SearchCity: Codable {
    var embedded: Embedded
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case count = "count"
    }
}
