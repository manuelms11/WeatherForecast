//
//  DetailViewController.swift
//  WeatherForecast
//
//  Created by user198829 on 6/28/21.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tempText: UILabel!
    @IBOutlet weak var feelsLikeText: UILabel!
    @IBOutlet weak var sunriseText: UILabel!
    @IBOutlet weak var sunsetText: UILabel!
    @IBOutlet weak var pressureText: UILabel!
    @IBOutlet weak var humidityText: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var cityText: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    
    let locationManager = CLLocationManager()
    var selectedCity : City?
    let apiKey = "API_KEY"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoStackView.applyShadowDesign()
        
        self.getForecast()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func getForecast() {
        var fullWeather: FullWeather!
        let baseURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall")!
        let urlRequest = URLRequest(url: baseURL)
        let fullWeatherParam  = ["lat": String((self.selectedCity?.location.latlon.latitude)!), "lon": String((self.selectedCity?.location.latlon.longitude)!) ,"exclude": "daily,minutely","units": "metric", "appid": "4ad5d0f1a33b949d560666d16f95a433"]
        let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: fullWeatherParam)
        
        AF.request(encodedURLRequest).responseData{ response in
            switch response.result {
            case let .success(data):
                do {
                    fullWeather = try JSONDecoder().decode( FullWeather.self, from: data)
                    self.cityText.text = self.selectedCity?.name
                    self.tempText.text = String(fullWeather.current.temp)+"°C"
                    self.feelsLikeText.text = String(fullWeather.current.feelsLike)+"°C"
                    self.sunriseText.text = String(self.unixTimeConverter(unixTime: Double(fullWeather.current.sunrise!), timaZone: "GMT", dateFormat: "MMM d, h:mm a"))
                    self.sunsetText.text = String(self.unixTimeConverter(unixTime: Double(fullWeather.current.sunset!), timaZone: "GMT", dateFormat: "MMM d, h:mm a"))
                    self.pressureText.text = String(fullWeather.current.pressure) + " mbar"
                    self.humidityText.text = String(fullWeather.current.humidity) + " %"
                    self.mainText.text = fullWeather.current.weather[0].main
                    self.descriptionText.text = fullWeather.current.weather[0].weatherDescription
                    
                    self.iconImage.loadImageFromURL(url: URL(string: "https://openweathermap.org/img/w/\(fullWeather.current.weather[0].icon).png")!)
                    
                    let initialLocation = CLLocation(latitude: (self.selectedCity?.location.latlon.latitude)!, longitude: (self.selectedCity?.location.latlon.longitude)!)
                    self.mapView.centerToLocation(initialLocation)
                } catch {
                    print("decoding error:\n\(error)")
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

//extension UIImageView {
//    func loadImageFromURL(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
