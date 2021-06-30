//
//  SearchViewController.swift
//  WeatherForecast
//
//  Created by Mauricio Fernandez Mora on 24/6/21.
//

import UIKit
import FirebaseFirestore
import Alamofire

class SearchViewController: UIViewController {

    @IBOutlet weak var cityNameText: UITextField!
    @IBOutlet weak var table: UITableView!
    
    let db = Firestore.firestore()
    var cities:[CityResults] = [CityResults]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    @IBAction func addCity(_ sender: Any) {
        
        guard let cityName = cityNameText.text else { return }
        
        let urlEncoded = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = "https://api.teleport.org/api/cities/?search=\(urlEncoded!)"

        AF.request(url).responseData { response in
            switch response.result {
                case let .success(data):
                    do {
                        let results = try JSONDecoder().decode(SearchCity.self, from: data)
                        
                        self.cities = results.embedded.results
                        self.table.reloadData()
                        
                    } catch {
                        print("decoding error:\n\(error)")
                    }
                case let .failure(error):
                    print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = cities[indexPath.row].fullname

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: "Favorito") { (action, view, bool) in
            
            let city = self.cities[indexPath.row]
            self.addToFavorites(city: city)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeAction
    }
    
    func addToFavorites(city: CityResults) {
        var ref: DocumentReference? = nil
        
        AF.request(city.links.cityItem.href).responseData { response in
            switch response.result {
                case let .success(data):
                    do {
                        let result = try JSONDecoder().decode(City.self, from: data)
                        
                        ref = self.db.collection("favorites").addDocument(data: ["name": city.fullname, "lat": result.location.latlon.latitude, "lon": result.location.latlon.longitude,"active": true]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(ref!.documentID)")
                            }
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
