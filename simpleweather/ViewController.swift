//
//  ViewController.swift
//  simpleweather
//
//  Created by Lloyd Rochester on 2/25/17.
//  Copyright © 2017 Lloyd Rochester. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let url = "https://api.weather.gov/points/39.0693,-94.6716/forecast"

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(self.url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

