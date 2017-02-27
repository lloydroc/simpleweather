//
//  simpleweatherTests.swift
//  simpleweatherTests
//
//  Created by Lloyd Rochester on 2/25/17.
//  Copyright © 2017 Lloyd Rochester. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON
import CoreLocation

@testable import simpleweather

class simpleweatherTests: XCTestCase {
    
    let url = "https://api.weather.gov/points/39.950859769264014,-105.03283499303978/forecast"
    var locManager = CLLocationManager()
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGpsCoordinates() {
        let latitude = locManager.location?.coordinate.latitude
        let longitude = locManager.location?.coordinate.longitude
        print(latitude!)
        print(longitude!)
        print("https://api.weather.gov/points/\(latitude!),\(longitude!)/forecast")
    }
    
    func testGetWeather() {
        let expectations = expectation(description: "Wait for exception")
        print("Testing Alamofire)")
        Alamofire.request(self.url).responseJSON { response in
            //print(response.request!)  // original URL request
            //print(response.response!) // HTTP URL response
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                print(json["properties"]["periods"])
                let periods = json["properties"]["periods"]
                print("Looping: \(periods[0])")
                for (index,period):(String, JSON) in periods {
                    print(index)
                    print(period["name"].string!)
                    print(period["shortForecast"].string!)
                    print(period["detailedForecast"].string!)
                    print(period["temperature"].int!)
                    print("Wind \(period["windDirection"].string!)\(period["windSpeed"].string!)")
                }
            case .failure(let error):
                print(error)
            }
            expectations.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in }
    }
    
}


