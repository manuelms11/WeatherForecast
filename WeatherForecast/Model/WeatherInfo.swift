//
//  WeatherInfo.swift
//  WeatherForecast
//
//  Created by Mauricio Fernandez Mora on 25/6/21.
//

import Foundation

struct WeatherInfo: Codable {
    var id: Int
    var name: String
    var coord: Coordinates
    var weather: [Weather]
    var main: Main
}
