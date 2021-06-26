//
//  Weather.swift
//  WeatherForecast
//
//  Created by Mauricio Fernandez Mora on 25/6/21.
//

import Foundation

struct Weather: Codable  {
    var id:Int
    var main:String
    var description:String
    var icon:String
}
