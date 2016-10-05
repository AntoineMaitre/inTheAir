//
//  ViewController.swift
//  InTheAir
//
//  Created by Alexandre VLADOVICH on 05/10/16.
//  Copyright © 2016 AlexandreVlado. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var startLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var endLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocation = CLLocationCoordinate2DMake(45.76733590000001, 4.835937000000058)
        endLocation = CLLocationCoordinate2DMake(45.7451765, 4.842331400000035)
        
        mapView.isTrafficEnabled = true
        
        mapView.camera = GMSCameraPosition(target: startLocation, zoom: 14.0, bearing: 0, viewingAngle: 0)

        self.drawMarkers()
        self.drawPolylines()
    }
    
    private func drawMarkers() {
        let startMarker = GMSMarker()
        startMarker.position = startLocation
        startMarker.title = "Hotel de Ville"
        startMarker.map = mapView
        
        let destinationMarker = GMSMarker()
        destinationMarker.position = endLocation
        destinationMarker.title = "Jean Macé"
        destinationMarker.map = mapView
    }
    
    private func drawPolylines() {
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(startLocation.latitude),\(startLocation.longitude)&destination=\(endLocation.latitude),\(endLocation.longitude)&key=AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU")
        let request = NSURLRequest(url: url! as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            // notice that I can omit the types of data, response and error
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    
                    let routes = jsonResult.value(forKey: "routes") as! NSArray
                    let routesDict = routes.object(at: 0) as! NSDictionary
                    let overViewPolylineDict = routesDict.object(forKey: "overview_polyline") as! NSDictionary
                    let overviewPolylinePoints = overViewPolylineDict.object(forKey: "points") as! String
                    
                    //Call on Main Thread
                    DispatchQueue.main.async {
                        self.addPolyLineWithEncodedStringInMap(encodedString: overviewPolylinePoints)
                    }
                }
            }
            catch{
                
                print("Somthing wrong")
            }
        });
        
        // do whatever you need with the task e.g. run
        task.resume()
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        
        polyLine.strokeWidth = 2
        polyLine.strokeColor = UIColor.blue
        polyLine.map = mapView
    }
}



