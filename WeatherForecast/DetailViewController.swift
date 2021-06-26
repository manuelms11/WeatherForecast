//
//  DetailViewController.swift
//  WeatherForecast
//
//  Created by Mauricio Fernandez Mora on 25/6/21.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tempText: UILabel!
    @IBOutlet weak var feelsLikeText: UILabel!
    @IBOutlet weak var tempMinText: UILabel!
    @IBOutlet weak var tempMaxText: UILabel!
    @IBOutlet weak var pressureText: UILabel!
    @IBOutlet weak var humidityText: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var selectedCity: Favorite = Favorite(id: 2643743, name: "London", lat: 51.5085, lon: -0.1257)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        AF.request("http://api.openweathermap.org/data/2.5/weather?id=\(selectedCity.id)&appid=baeb03b0e9ec31b6617dc6aa6aa6c170").responseDecodable(of: WeatherInfo.self) { result in
            
            if let error = result.error {
                print(error.localizedDescription)
            }
            guard let result = result.value else {
                return
            }
            
            print(result)
            
            self.tempText.text = String(result.main.temp)
            self.feelsLikeText.text = String(result.main.feels_like)
            self.tempMinText.text = String(result.main.temp_min)
            self.tempMaxText.text = String(result.main.temp_max)
            self.pressureText.text = String(result.main.pressure)
            self.humidityText.text = String(result.main.humidity)
            self.mainText.text = result.weather[0].main
            self.descriptionText.text = result.weather[0].description
            
            self.iconImage.loadImageFromURL(url: URL(string: "https://openweathermap.org/img/w/\(result.weather[0].icon).png")!)
            
            
            let initialLocation = CLLocation(latitude: result.coord.lat, longitude: result.coord.lon)
            self.mapView.centerToLocation(initialLocation)
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
    
extension UIImageView {
    func loadImageFromURL(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
