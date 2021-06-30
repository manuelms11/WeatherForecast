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
    
    
    @IBOutlet weak var dailyDate4: UILabel!
    @IBOutlet weak var dailyIcon4: UIImageView!
    @IBOutlet weak var dailyTemp4: UILabel!
    @IBOutlet weak var dailyDate3: UILabel!
    @IBOutlet weak var dailyIcon3: UIImageView!
    @IBOutlet weak var dailyTemp3: UILabel!
    @IBOutlet weak var dailyDate2: UILabel!
    @IBOutlet weak var dailyIcon2: UIImageView!
    @IBOutlet weak var dailyTemp2: UILabel!
    @IBOutlet weak var dailyDate1: UILabel!
    @IBOutlet weak var dailyIcon1: UIImageView!
    @IBOutlet weak var dailyTemp1: UILabel!
    
    @IBOutlet weak var VStackView1: UIStackView!
    @IBOutlet weak var VStackView2: UIStackView!
    @IBOutlet weak var VStackView3: UIStackView!
    @IBOutlet weak var VStackView4: UIStackView!
    
    
    
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
        
        self.loadFavorites()
        
        // MARK: - Getting current Location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let location: Latlon = Latlon.init(latitude: locValue.latitude, longitude: locValue.longitude)
        self.getOpenWeatherRequest(location: location, requestType: "fullWeather", appID: "4ad5d0f1a33b949d560666d16f95a433")
        self.getOpenWeatherRequest(location: location, requestType: "ReverseGeocoding", appID: "4ad5d0f1a33b949d560666d16f95a433")
        
    }

    // MARK: - ViewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*Setting up UI*/
        dailyStackView.applyShadowDesign()
        //hourlyStackView.applyShadowDesign()
        VStackView1.applyShadowDesign()
        VStackView2.applyShadowDesign()
        VStackView3.applyShadowDesign()
        VStackView4.applyShadowDesign()
            
        // MARK: - Getting Favorites
        cities = [City]()
        
        favoritesTableView.reloadData()
    
    }
    
    @IBAction func logOut(_ sender: Any) {
        try! Auth.auth().signOut()
        
        let loginViewController = storyboard?.instantiateViewController(identifier: "login") as?
            LoginViewController

        loginViewController?.modalPresentationStyle = .overCurrentContext
        self.present(loginViewController!, animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func isUserLoggedIn() -> Bool {
      return Auth.auth().currentUser != nil
    }
    
    func loadFavorites() {
        self.cities = []
        let favoritesCities = db.collection("favorites")
        favoritesCities.whereField("active", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {

                        let cityDictionary = document.data()
                        let cityName = cityDictionary.first{$0.key == "name"}?.value ?? ""
                        let lat = cityDictionary.first{$0.key == "lat"}?.value ?? ""
                        let lon = cityDictionary.first{$0.key == "lon"}?.value ?? ""
                        let city = City(id: document.documentID, name: cityName as! String, location: Location(latlon: Latlon(latitude: lat as! Double,longitude: lon as! Double)))
                     //   print(city)
                        self.cities?.append(city)
                    }
                   // print("CITIES \(self.cities)")
                }
            }
        
        self.favoritesTableView.reloadData()
    }
    
    func removeFavorite(city: City) {
        
        db.collection("favorites").document(city.id!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.loadFavorites()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "detailSegue" {
                if let index = self.favoritesTableView.indexPathForSelectedRow {
                    if let city = self.cities?[index.section] {
                        let destination = segue.destination as? DetailViewController
                        destination?.selectedCity = city
                    }
                }
          /*  } else if segue.identifier == "addSegue" {
                if let postsSize = self.cities?.count {
                    let destination = segue.destination as? SearchViewController
                    destination?.currentPostsSize = postsSize
                    destination?.delegate = self
                }
            }*/
        }
    }

    
    
    func setUIFullWeather(fullWeather: FullWeather){
        let iconURL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.current.weather[0].icon) + ".png"
        let iconDaily1URL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.daily?[1].weather[0].icon ?? "01d.png") + ".png"
        let iconDaily2URL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.daily?[2].weather[0].icon ?? "01d.png") + ".png"
        let iconDaily3URL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.daily?[3].weather[0].icon ?? "01d.png") + ".png"
        let iconDaily4URL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.daily?[4].weather[0].icon ?? "01d.png") + ".png"
        
        //Current Day Info
        self.dateLabel.text = String(unixTimeConverter(unixTime: Double(fullWeather.current.dt), timaZone: "GMT", dateFormat: "EEEE, MMM d"))
        self.tempLabel.text = String(Int(fullWeather.current.temp))+"°C"
        self.currentDescriptionLabel.text = fullWeather.current.weather[0].weatherDescription
        self.currentIconImageView.loadImageFromURL(url: URL(string: iconURL)!)
        
        //Daily 1
        self.dailyTemp1.text = String(Double((fullWeather.daily?[1].temp.day)!))+"°C"
        self.dailyIcon1.loadImageFromURL(url: URL(string: iconDaily1URL)!)
        self.dailyDate1.text = String(unixTimeConverter(unixTime: Double(fullWeather.daily?[1].dt ?? 0), timaZone: "GMT", dateFormat: "MMM d"))
        
        //Daily 2
        self.dailyTemp2.text = String(Double((fullWeather.daily?[2].temp.day)!))+"°C"
        self.dailyIcon2.loadImageFromURL(url: URL(string: iconDaily2URL)!)
        self.dailyDate2.text = String(unixTimeConverter(unixTime: Double(fullWeather.daily?[2].dt ?? 0), timaZone: "GMT", dateFormat: "MMM d"))
        
        //Daily 3
        self.dailyTemp3.text = String(Double((fullWeather.daily?[3].temp.day)!))+"°C"
        self.dailyIcon3.loadImageFromURL(url: URL(string: iconDaily3URL)!)
        self.dailyDate3.text = String(unixTimeConverter(unixTime: Double(fullWeather.daily?[3].dt ?? 0), timaZone: "GMT", dateFormat: "MMM d"))
        
        //Daily 4
        self.dailyTemp4.text = String(Double((fullWeather.daily?[4].temp.day)!))+"°C"
        self.dailyIcon4.loadImageFromURL(url: URL(string: iconDaily4URL)!)
        self.dailyDate4.text = String(unixTimeConverter(unixTime: Double(fullWeather.daily?[4].dt ?? 0), timaZone: "GMT", dateFormat: "MMM d"))
    
    }
    
    func setUIFullWeatherCell(fullWeather: FullWeather, cell: FavoritesCell){
        
        let iconURL: String = "https://openweathermap.org/img/wn/" + String(fullWeather.current.weather[0].icon) + ".png"
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        cell.cellDescriptionLabel.text = String(Int(fullWeather.current.temp))+"°C"
        cell.cellIconImageView.loadImageFromURL(url: URL(string: iconURL)!)
    }
    
    func setUIReverseGeocoding(reverseGeocoding: ReverseGeocoding){
        self.locationLabel.text = reverseGeocoding[0].name + ", " + reverseGeocoding[0].country
    }
    
    func getOpenWeatherRequest(location: Latlon, requestType: String, appID: String, cell: FavoritesCell? = nil){
        var baseURL: URL
        var encodedURLRequest: URLRequest!
        
        if requestType == "fullWeather" || requestType == "fullWeatherCell" {
            baseURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall")!
            let urlRequest = URLRequest(url: baseURL)
            let fullWeatherParam  = ["lat": String(location.latitude), "lon": String(location.longitude) ,"exclude": "hourly,minutely","units": "metric", "appid": appID]
            encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: fullWeatherParam)
        }
        if requestType == "ReverseGeocoding"{
            baseURL = URL(string: "https://api.openweathermap.org/geo/1.0/reverse")!
            let urlRequest = URLRequest(url: baseURL)
            let reverseGeocodingParam  = ["lat": String(location.latitude), "lon": String(location.longitude) ,"limit": "1", "appid": appID]
            encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: reverseGeocodingParam)
        }
        
        AF.request(encodedURLRequest).responseData{ response in
            switch response.result {
                case let .success(data):
                    do {
                        if requestType == "fullWeather"{
                            var fullWeather: FullWeather!
                            fullWeather = try JSONDecoder().decode( FullWeather.self, from: data)
                            self.setUIFullWeather(fullWeather: fullWeather )
                        }
                        else if requestType == "ReverseGeocoding"{
                            var reverseGeocoding: ReverseGeocoding!
                            reverseGeocoding = try JSONDecoder().decode( ReverseGeocoding.self, from: data)
                            self.setUIReverseGeocoding(reverseGeocoding: reverseGeocoding)
                        }
                        else if requestType == "fullWeatherCell"{
                            var fullWeather: FullWeather!
                            fullWeather = try JSONDecoder().decode( FullWeather.self, from: data)
                            self.setUIFullWeatherCell(fullWeather: fullWeather, cell: cell! )
                        }
                    } catch {
                        print("decoding error:\n\(error)")
                    }
                case let .failure(error):
                    print(error.localizedDescription)
            }
        }

    }

}
   
// MARK: - Extensions

extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let cities = self.cities else {
           return 0
          }
          return cities.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 0.001
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesCell
       
        
        if let cities = self.cities{
            getOpenWeatherRequest(location: cities[indexPath.section].location.latlon, requestType: "fullWeatherCell", appID: "4ad5d0f1a33b949d560666d16f95a433", cell: cell)
            cell.cellLocationLabel?.text = cities[indexPath.section].name
            /*cell.cellContentView.applyShadowDesignUIView()*/
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, bool) in
            let city = self.cities![indexPath.row]
            self.removeFavorite(city: city)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeAction
    }
}



extension UIStackView {
    func applyShadowDesign(){
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}

extension UIViewController {
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

