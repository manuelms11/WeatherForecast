//
//  ViewController.swift
//  WeatherForecast
//
//  Created by user198829 on 6/21/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import CoreLocation

class favoritesCell: UITableViewCell{
    @IBOutlet weak var cellLocationLabel: favoritesCell!
    @IBOutlet weak var cellIconImageView: UIImageView!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var dailyStackView: UIStackView!
    @IBOutlet weak var hourlyStackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var currentDescriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentMainLabel: UILabel!
    @IBOutlet weak var currentIconImageView: UIImageView!
    
    @IBOutlet weak var favoritesTableView: UITableView!
   /* @IBOutlet weak var cellLocationLabel: UILabel!
    @IBOutlet weak var cellIconImageView: UIImageView!
    @IBOutlet weak var cellDescriptionLabel: UILabel!*/
    
    
    
    
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    var cities:[City]?{
        didSet{
            self.favoritesTableView.reloadData()
        }
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let loginViewController = storyboard?.instantiateViewController(identifier: "login") as?
            LoginViewController
        
        if(!isUserLoggedIn()){
            loginViewController?.modalPresentationStyle = .overCurrentContext // Usando .fullscreen hace dismiss vuelva a llamar a viewWillAppear presentando la pantalla de login de nuevo
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
    }

    // MARK: - ViewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*Setting up UI*/
        dailyStackView.applyShadowDesign()
        hourlyStackView.applyShadowDesign()
        
        
        func isUserLoggedIn() -> Bool {
          return Auth.auth().currentUser != nil
        }
        
        /*Getting current location*/
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
        // MARK: - Getting current Location
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let location: Latlon = Latlon.init(latitude: locValue.latitude, longitude: locValue.longitude)
        self.getOpenWeatherRequest(location: location, requestType: "fullWeather", appID: "4ad5d0f1a33b949d560666d16f95a433")
        self.getOpenWeatherRequest(location: location, requestType: "ReverseGeocoding", appID: "4ad5d0f1a33b949d560666d16f95a433")
            
        // MARK: - Getting Favorites
        cities = [City]()
        let favoritesCities = db.collection("favorites")
        favoritesCities.whereField("active", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                       // var Location
                        //let city = City(name: , location: <#T##Location#>)
                        
                        /*for (name) in cityDictionary.values{
                            print("\(name[0])")
                        }*/
                        
                        let cityDictionary = document.data()
                        let cityName = cityDictionary.first{$0.key == "name"}?.value ?? ""
                        let lat = cityDictionary.first{$0.key == "lat"}?.value ?? ""
                        let lon = cityDictionary.first{$0.key == "lon"}?.value ?? ""
                        let city = City(name: cityName as! String, location: Location(latlon: Latlon(latitude: lat as! Double,longitude: lon as! Double)))
                        print(city)
                       
                        self.cities?.append(city)
                    }
                    print("CITIES \(self.cities)")
                }
            }
        
                favoritesTableView.reloadData()
        
      /*  let db = Firestore.firestore()
        db.collection("favorites").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }*/
        
	    }
    
    
    // MARK: - Functions
    func isUserLoggedIn() -> Bool {
      return Auth.auth().currentUser != nil
    }
    
    func setUIFullWeather(fullWeather: FullWeather){
        self.dateLabel.text = String(unixTimeConverter(unixTime: Double(fullWeather.current.dt), timaZone: "GMT", dateFormat: "EEEE, MMM d"))
        self.tempLabel.text = String(Int(fullWeather.current.temp))+"°C"
        self.currentDescriptionLabel.text = fullWeather.current.weather[0].weatherDescription
        //self.currentMainLabel.text = fullWeather.current.weather[0].main
        let iconURL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.current.weather[0].icon) + ".png"
        self.currentIconImageView.loadImageFromURL(url: URL(string: iconURL)!)
    }
    
    func setUIReverseGeocoding(reverseGeocoding: ReverseGeocoding){
        self.locationLabel.text = reverseGeocoding[0].name + ", " + reverseGeocoding[0].country
    }
    
    func getOpenWeatherRequest(location: Latlon, requestType: String, appID: String){
        var baseURL: URL
        if requestType == "fullWeather"{
            var fullWeather: FullWeather!
            baseURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall")!
            let urlRequest = URLRequest(url: baseURL)
            let fullWeatherParam  = ["lat": String(location.latitude), "lon": String(location.longitude) ,"exclude": "daily,minutely","units": "metric", "appid": appID]
            let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: fullWeatherParam)
    
            AF.request(encodedURLRequest).responseData{ response in
                switch response.result {
                    case let .success(data):
                        do {
                            fullWeather = try JSONDecoder().decode( FullWeather.self, from: data)
                            //print("fullWeather Response:  \n",fullWeather as Any)
                            self.setUIFullWeather(fullWeather: fullWeather )
                        } catch {
                            print("decoding error:\n\(error)")
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            }
        }
        if requestType == "ReverseGeocoding"{
            var reverseGeocoding: ReverseGeocoding!
            baseURL = URL(string: "https://api.openweathermap.org/geo/1.0/reverse")!
            let urlRequest = URLRequest(url: baseURL)
            let reverseGeocodingParam  = ["lat": String(location.latitude), "lon": String(location.longitude) ,"limit": "1", "appid": appID]
            let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: reverseGeocodingParam)
            
            AF.request(encodedURLRequest).responseData{ response in
                switch response.result {
                    case let .success(data):
                        do {
                            reverseGeocoding = try JSONDecoder().decode( ReverseGeocoding.self, from: data)
                            //print("ReverseGeocoding Response:  \n",reverseGeocoding as Any)
                            self.setUIReverseGeocoding(reverseGeocoding: reverseGeocoding )
                        } catch {
                            print("decoding error:\n\(error)")
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                }
            }
        }

    }

}
   
// MARK: - Extensions

extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cities = self.cities else {
           return 0
          }
          return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! favoritesCell
        
        if let cities = self.cities{
            cell.textLabel?.text = cities[indexPath.row].name
            cell.cellLocationLabel?.text = "Prueba"
        }
        
        return cell
    }
}



extension UIStackView {
    func applyShadowDesign(){
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

extension ViewController {
    func unixTimeConverter(unixTime: Double, timaZone: String, dateFormat: String) -> String{
        
        let unixTimestamp = unixTime
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        //Set timezone that you want
        dateFormatter.timeZone = TimeZone(abbreviation: timaZone)
        dateFormatter.locale = NSLocale.current
        //Specify your format that you want
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
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


