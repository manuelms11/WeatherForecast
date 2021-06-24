//
//  ViewController.swift
//  WeatherForecast
//
//  Created by user198829 on 6/21/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loginViewController = storyboard?.instantiateViewController(identifier: "login") as?
            LoginViewController
        
        loginViewController?.modalPresentationStyle = .overCurrentContext // Usando .fullscreen hace dismiss vuelva a llamar a viewWillAppear presentando la pantalla de login de nuevo
        self.present(loginViewController!, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }


}

