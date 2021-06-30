//
//  City.swift
//  WeatherForecast
//
//  Created by Lorenzo Rodriguez on 6/26/21.
//

import Foundation

struct City: Codable {
    var id: String?
    var name: String
    var location: Location
}
