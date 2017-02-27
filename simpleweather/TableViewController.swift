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

class TableViewController: UITableViewController, CLLocationManagerDelegate {

    let urlFront = "https://api.weather.gov/points/"
    let urlBack  = "/forecast"
    var url = ""
    var locManager = CLLocationManager()
    var periods:JSON = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locManager.delegate = self;
        self.locManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locManager.startUpdatingLocation()
        
            var latitude = 39.950859769264014
            var longitude = -105.03283499303978
            
            if let latestLat = locManager.location?.coordinate.latitude {
                latitude = latestLat
            }
            
            
            if let latestLong = locManager.location?.coordinate.longitude {
                longitude = latestLong
            }
            
            self.url = "\(urlFront)\(latitude),\(longitude)\(urlBack)"
            
            print("Url is: \(url)")
            
            Alamofire.request(self.url).responseJSON { response in
                //print(response.request!)  // original URL request
                //print(response.response!) // HTTP URL response
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //print(json)
                    print(json["properties"]["periods"])
                    self.periods = json["properties"]["periods"]
                    print("Looping: \(self.periods[0])")
                    for (index,period):(String, JSON) in self.periods {
                        print(index)
                        print(period["name"].string!)
                        print(period["shortForecast"].string!)
                        print(period["detailedForecast"].string!)
                        print(period["temperature"].int!)
                        print("Wind \(period["windDirection"].string!)\(period["windSpeed"].string!)")
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "periodTableCellIdentifier", for: indexPath) as! TableViewCell

        if let name = self.periods[indexPath.row]["name"].string {
            cell.name.text = name
        }
        if let detailedForcast = self.periods[indexPath.row]["detailedForecast"].string {
            cell.detailedForecast.text = detailedForcast
        }
        if let temp = self.periods[indexPath.row]["temperature"].int {
            cell.temp.text = "\(temp)"
        }
        if let windDir = self.periods[indexPath.row]["windDirection"].string {
            cell.wind.text = "Wind \(windDir)\(self.periods[indexPath.row]["windSpeed"].string!)"
        }

        return cell
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .notDetermined:
            print(".NotDetermined")
            break
            
        case .authorizedAlways:
            print(".AuthorizedAlways")
            break
            
        case .authorizedWhenInUse:
            print(".AuthorizedWhenInUse")
            break
            
        case .denied:
            print(".Denied")
            break
            
        default:
            print("Unhandled authorization status")
            break
        }
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
