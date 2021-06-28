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
    @IBOutlet weak var favoritesTableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let loginViewController = storyboard?.instantiateViewController(identifier: "login") as?
            LoginViewController
        
        if(!isUserLoggedIn()){
            loginViewController?.modalPresentationStyle = .overCurrentContext // Usando .fullscreen hace dismiss vuelva a llamar a viewWillAppear presentando la pantalla de login de nuevo
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*Setting up UI*/
        dailyStackView.applyShadowDesign()
        hourlyStackView.applyShadowDesign()
        
        /*Getting current location*/
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let location: Latlon = Latlon.init(latitude: locValue.latitude, longitude: locValue.longitude)
        let weatherBaseURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall")!
        let urlRequest = URLRequest(url: weatherBaseURL)
        let appID = "4ad5d0f1a33b949d560666d16f95a433"
        let fullWeatherParam  = ["lat": String(location.latitude), "lon": String(location.longitude) ,"exclude": "daily,minutely","appid": appID]
        let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: fullWeatherParam)

        
        let db = Firestore.firestore()
        db.collection("favorites").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        
       // AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=9.933333333&lon=-9.933333333&lang=en&appid=e8f9ffc1d5f19e304fe9828c07c6632a").responseData { response in
        AF.request(encodedURLRequest).responseData{ response in
            switch response.result {
                case let .success(data):
                    do {
                        let results = try JSONDecoder().decode( FullWeather.self, from: data)
                        
                            print(results)
                    } catch {
                        print("decoding error:\n\(error)")
                    }
                case let .failure(error):
                    print(error.localizedDescription)
            }
        }
        
        /*AF.request(weatherBaseURL, method: .post, parameters: fullWeatherParam).responseJSON { response in
                switch response.result {
                case .success:
                    let result = response.result
                    //let json = result as Dictionary
                    print(result)
                case .failure(let error):
                    let responseString = String(data: response.data!, encoding:.utf8)
                }*/
        
        /*AF.request(weatherBaseURL, parameters: fullWeatherParam)
            .validate()
            .responseDecodable(of: FullWeather.self) { response in
                switch response.result {
                    case let .success(data):
                        do {
                           // let results = try JSONDecoder().decode( FullWeather.self, from: data)
                            
                                //print(results)
                        } catch {
                            print("decoding error:\n\(error)")
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                }
                
                // 4
                
                print(response)
             //
              /*self.items = starships.all
              self.tableView.reloadData()*/
             // print(response2)
          }*/
        
    }
    
    func isUserLoggedIn() -> Bool {
      return Auth.auth().currentUser != nil
    }
    
    /*Current location*/
    

}

extension UIStackView {
    func applyShadowDesign(){
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

