//
//  TableViewController.swift
//  simpleweather
//
//  Created by Lloyd Rochester on 2/26/17.
//  Copyright © 2017 Lloyd Rochester. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Darwin

class TableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locManager: CLLocationManager?

    let urlFront = "https://api.weather.gov/points/"
    let urlBackForecast  = "/forecast"
    let urlBackStations  = "/stations"
    
    let urlFrontStations = "https://api.weather.gov/stations/"
    let urlBackStationObservation  = "/observations/current"
    var urlForecast = ""
    var urlStations = ""
    var urlCurrentStationObservation = ""
    
    var periods:JSON = JSON.null
    
    var favRefreshControl = UIRefreshControl()
    
    var latitude:Double = 39.9508
    var longitude:Double = -105.0328
    var latStr = "39.9508"
    var lonStr = "-105.0328"
    var updatedLocation = false
    var stationIdentifier:String? = ""
    var currentTemperatureC:Double? = nil
    var currentTemperatureF:Double? = nil
    var elevationMeters:String = ""
    var distFromWeatherStationM:Double = -1.0
    var distFromWeatherStationF:Double = -1.0
    var distFromWeatherStationMStr:String = "-1.0"
    var distFromWeatherStationFStr:String = "-1.0"
    
    @IBOutlet weak var tableViewHeader: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locManager = self.appDelegate.locManager
        self.refreshControl = self.favRefreshControl
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.displayWeatherOnTableView), for: .valueChanged)
        displayWeatherOnTableView()
    }
    
    func displayWeatherOnTableView() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        self.refreshControl?.beginRefreshing()
        
        if let latestLat = locManager?.location?.coordinate.latitude {
            self.latitude = latestLat
            self.latStr = String(format: "%.4f",self.latitude)
        } else {
            self.updatedLocation = false
        }
        
        if let latestLong = locManager?.location?.coordinate.longitude {
            self.longitude = latestLong
            self.lonStr = String(format: "%.4f",self.longitude)
            self.updatedLocation = true
        } else {
            self.updatedLocation = false
        }
        
        self.urlForecast = "\(urlFront)\(self.latStr),\(self.lonStr)\(urlBackForecast)"
        Alamofire.request(self.urlForecast).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.periods = json["properties"]["periods"]
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.refreshControl?.endRefreshing()
        }
        self.urlStations = "\(urlFront)\(self.latStr),\(self.lonStr)\(urlBackStations)"
        print(self.urlStations)
        Alamofire.request(self.urlStations).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let station = json["observationStations"][0].string
                if(station != nil) {
                    Alamofire.request(station!).responseJSON { response2 in
                        switch response2.result {
                        case .success(let value):
                            let json2 = JSON(value)
                            
                            self.stationIdentifier = json2["properties"]["stationIdentifier"].string
                            self.urlCurrentStationObservation = "\(self.urlFrontStations)\(self.stationIdentifier!)\(self.urlBackStationObservation)"
                            print(self.urlCurrentStationObservation)
                            
                            // Get distance from gps location to station
                            let stationLat = json2["geometry"]["coordinates"][1].double!
                            let stationLon = json2["geometry"]["coordinates"][0].double!
                            self.distFromWeatherStationM = self.distFrom(lat1: self.latitude, lng1: self.longitude, lat2: stationLat, lng2: stationLon)
                            self.distFromWeatherStationF = self.distInMiles(meters: self.distFromWeatherStationM)
                            
                            if self.distFromWeatherStationM > 1000 {
                              self.distFromWeatherStationMStr = String(format: "%.2f",self.distFromWeatherStationM/1000.0)+"km"
                            } else {
                              self.distFromWeatherStationMStr = String(format: "%.0f",self.distFromWeatherStationM)+"m"
                            }
                            
                            if self.distFromWeatherStationF < 1 {
                               self.distFromWeatherStationFStr = String(format: "%.2f",self.distFromWeatherStationF)+"mi"
                            } else {
                                self.distFromWeatherStationFStr = String(format: "%.1f",self.distFromWeatherStationF)+"mi"
                            }
                            
                            // Set table header to station name and miles
                            self.tableViewHeader.title = "\(json2["properties"]["name"].string!) (\(self.distFromWeatherStationFStr))"
                            
                            Alamofire.request(self.urlCurrentStationObservation).responseJSON { response3 in
                                switch response3.result {
                                case .success(let value):
                                    let json3 = JSON(value)
                                    print(json3)
                                    
                                    if let elevM = json3["properties"]["elevation"]["value"].double {
                                        let elevF = elevM*3.28084
                                        let elevMStr = String(format: "%.0f",elevM)
                                        let elevFStr = String(format: "%.0f",elevF)
                                        self.elevationMeters = "\(elevMStr)m / \(elevFStr)ft"
                                    }
                                    
                                    // Current Observation is still "pending" indicated by qz:Z thus value is invalid
                                    let qc = json3["properties"]["temperature"]["qualityControl"].string
                                    guard qc != "qc:Z" else {
                                        return
                                    }
                                    self.currentTemperatureC = json3["properties"]["temperature"]["value"].double
                                    self.currentTemperatureF = 9*self.currentTemperatureC!/5 + 32
                                    
                                case .failure(let error3):
                                    print(error3)
                                }
                            }
                                
                        case .failure(let error2):
                            print(error2)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 9 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "periodTableCellIdentifier", for: indexPath) as! TableViewCell

        guard self.periods.count > 7 else {
            cell.name.text = "Pending"
            cell.detailedForecast.text = "Pending"
            cell.name.text = "Updated GPS: Pending"
            cell.temp.text = "Pending"
            cell.wind.text = "Pending"
            return cell
        }
        
        if (self.currentTemperatureC != nil && indexPath.row == 0) {
            let c = String(format: "%.0f",self.currentTemperatureC!)
            let f = String(format: "%.0f",self.currentTemperatureF!)
            cell.currentTemp.text = "Current: \(f)°F / \(c)°C"
        } else if indexPath.row == 0 {
            cell.currentTemp.text = "Current: Measuring"
        } else {
            cell.currentTemp.text = ""
        }
        
        // TODO The cell we will just have debug data
        if(indexPath.row == 8) {
            cell.name.text = ""
            cell.detailedForecast.text = "Lat/Lon: \(self.latStr),\(self.lonStr)\nElevation: \(self.elevationMeters)\nStation Distance: \(self.distFromWeatherStationMStr) / \(self.distFromWeatherStationFStr)"
            cell.name.text = "Updated GPS: \(self.updatedLocation)"
            cell.wind.text = self.stationIdentifier
            return cell
        }
        
        let period = self.periods[indexPath.row]
        if let name = period["name"].string {
            cell.name.text = name
        }
        if let detailedForcast = period["detailedForecast"].string {
            cell.detailedForecast.text = detailedForcast
        }
        if let temp = period["temperature"].int {
            let tempC = (temp-32)*5/9
            var high = "Low of";
            if(period["isDaytime"].bool!) {
                high = "High of"
            }
            cell.temp.text = "\(high) \(temp)°F / \(tempC)°C"
        }
        if let windDir = period["windDirection"].string {
            var windSpeed = period["windSpeed"].string!
            if windSpeed.hasPrefix(" ") == false { // Bug from API sometimes a space is added, sometimes not
                windSpeed = " \(windSpeed)"
            }
            cell.wind.text = "Wind \(windDir)\(windSpeed)"
        }

        return cell
    }
    
    func distFrom(lat1: Double, lng1:Double, lat2:Double, lng2:Double) -> Double {
        let earthRadius = 6371000.0; //meters
        let dLat = (lat2-lat1)*Double.pi/180.0
        let dLng = (lng2-lng1)*Double.pi/180.0
        let lat1Rad = lat1*Double.pi/180.0
        let lat2Rad = lat2*Double.pi/180.0
        let a = sin(dLat/2) * sin(dLat/2) +
            cos(lat1Rad) * cos(lat2Rad) *
            sin(dLng/2) * sin(dLng/2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let dist = (Double) (earthRadius * c);
    
        return dist;
    }
    

    func distInMiles(meters:Double) -> Double {
      return 0.000621371*meters;
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
