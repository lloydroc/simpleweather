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

class TableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locManager: CLLocationManager?

    let urlFront = "https://api.weather.gov/points/"
    let urlBackForecast  = "/forecast"
    let urlBackStations  = "/stations"
    var urlForecast = ""
    var urlStations = ""
    
    var periods:JSON = JSON.null
    
    var favRefreshControl = UIRefreshControl()
    
    var latitude = 39.950859769264014
    var longitude = -105.03283499303978
    var updatedLocation = false
    
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
        } else {
            self.updatedLocation = false
        }
        
        if let latestLong = locManager?.location?.coordinate.longitude {
            self.longitude = latestLong
            self.updatedLocation = true
        } else {
            self.updatedLocation = false
        }
        
        self.urlForecast = "\(urlFront)\(latitude),\(longitude)\(urlBackForecast)"
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
        self.urlStations = "\(urlFront)\(latitude),\(longitude)\(urlBackStations)"
        Alamofire.request(self.urlStations).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let station = json["observationStations"][0].string
                Alamofire.request(station!).responseJSON { response2 in
                    switch response2.result {
                    case .success(let value):
                        let json2 = JSON(value)
                        let name = json2["properties"]["name"].string
                        self.tableViewHeader.title = name
                    case .failure(let error2):
                        print(error2)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "periodTableCellIdentifier", for: indexPath) as! TableViewCell

        // TODO The cell we will just have debug data
        if(indexPath.row == 5) {
            cell.name.text = ""
            cell.detailedForecast.text = "Lat/Lon: \(self.latitude),\(self.longitude)"
            cell.name.text = "Updated GPS: \(self.updatedLocation)"
            cell.temp.text = ""
            cell.wind.text = ""
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
