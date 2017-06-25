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
    
    let baseUrl = "https://api.weather.gov/points"
    let latLon = "39.9508,-105.0328"
    var urlForecast = ""
    var urlStation = ""
    var urlPoint = ""
    var locManager = CLLocationManager()
    
    override func setUp() {
        super.setUp()
        urlForecast = "\(self.baseUrl)/\(self.latLon)/forecast"
        urlStation  = "\(self.baseUrl)/\(self.latLon)/stations"
        urlPoint    = "\(self.baseUrl)/\(self.latLon)"
        print(urlForecast)
        print(urlStation)
        print(urlPoint)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        waitForExpectations(timeout: 5) { error in }
    }
    
    func testGpsCoordinates() {
        let latitude = locManager.location?.coordinate.latitude
        let longitude = locManager.location?.coordinate.longitude
        XCTAssertNotNil(latitude)
        XCTAssertNotNil(longitude)
        let latitudeStr = String(format: "%.4f", latitude!)
        let longitudeStr = String(format: "%.4f", longitude!)
        XCTAssertNotNil(latitudeStr.range(of:"."))
        XCTAssertNotNil(longitudeStr.range(of:"."))
    }
    
    func testGetWeatherForecast() {
        let expectations = expectation(description: "Wait for exception")
        Alamofire.request(self.urlForecast).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let periods = json["properties"]["periods"]
                XCTAssertTrue(periods.count>0)
                for (_,period):(String,JSON) in periods {
                    XCTAssertNotNil(period["name"].string)
                    XCTAssertNotNil(period["shortForecast"].string)
                    XCTAssertNotNil(period["detailedForecast"].string)
                    XCTAssertNotNil(period["temperature"].int)
                    XCTAssertNotNil(period["windDirection"].string)
                    XCTAssertNotNil(period["windSpeed"].string)
                    XCTAssertNotNil(period["isDaytime"].string)
                }
            case .failure(let error):
                XCTAssertTrue(false, "Failure reading from URL \(error)")
            }
            expectations.fulfill()
        }
        
        //waitForExpectations(timeout: 5) { error in }
    }
    
    func testGetWeatherStationName() {
        let expectations = expectation(description: "Wait for exception")
        Alamofire.request(self.urlStation).responseJSON { response in
            //print(response.request!)  // original URL request
            //print(response.response!) // HTTP URL response
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                XCTAssertTrue(json["observationStations"].count>0)
                let station = json["observationStations"][0].string
                XCTAssertNotNil(station)
                XCTAssertTrue(station!.contains("https://api.weather.gov/stations"))
                
                Alamofire.request(station!).responseJSON { response2 in
                    switch response2.result {
                    case .success(let value):
                        let json2 = JSON(value)
                        XCTAssertNotNil(json2["properties"])
                        let name = json2["properties"]["name"].string
                        XCTAssertNotNil(name)
                        XCTAssertTrue(name!.contains("Erie Municipal Airport"))
                    case .failure(let error2):
                        XCTAssertTrue(false, "Failure reading from URL \(error2)")
                    }
                    expectations.fulfill()
                }
                
            case .failure(let error):
                XCTAssertTrue(false, "Failure reading from URL \(error)")
            }
            expectations.fulfill()
        }
        
        
    }
    
}


