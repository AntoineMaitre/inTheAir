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
    @IBOutlet weak var menuButton: UIButton!
    
    let locationManager = CLLocationManager()
    var endLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var startLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var redPolyline:GMSPolyline!
    var greenPolyline:NSMutableArray!
    var destinationMarker:GMSMarker!
    
    var startMarkerAdded:Bool = false
    var buttonsAdded:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 500
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Fake data (Hotel de Ville and Jean Macé)
        endLocation = CLLocationCoordinate2DMake(45.76733590000001, 4.835937000000058)
        startLocation = CLLocationCoordinate2DMake(45.7451765, 4.842331400000035)
        
        mapView.isTrafficEnabled = true
        
        mapView.camera = GMSCameraPosition(target: startLocation, zoom: 14.0, bearing: 0, viewingAngle: 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        currentLocation = (location?.coordinate)!
        
        if buttonsAdded == false {
            self.addButtons()
        }
        
        if startMarkerAdded == false {
            let startMarker = GMSMarker()
            startMarker.position = currentLocation
            startMarker.title = "Moi"
            startMarker.map = mapView
            
            startMarkerAdded = true
        }
        
        mapView.camera = GMSCameraPosition(target: currentLocation, zoom: 14.0, bearing: 0, viewingAngle: 0)
    }
    
    private func drawMarkers() {
        let destinationMarker = GMSMarker()
        destinationMarker.position = endLocation
        destinationMarker.title = "Hotel de Ville"
        destinationMarker.map = mapView
    }
    
    private func addButtons() {
        let itineraryButton = UIButton(frame: CGRect(x: view.frame.size.width - 10 - 52, y: view.frame.size.height - 10 - 52, width: 52, height: 52))
        itineraryButton.backgroundColor = UIColor.white
        itineraryButton.layer.cornerRadius = itineraryButton.frame.size.width/2
        itineraryButton.layer.shadowColor = UIColor.gray.cgColor
        itineraryButton.layer.shadowOpacity = 0.8
        itineraryButton.layer.shadowRadius = 5.0
        itineraryButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        itineraryButton.setImage(UIImage(named: "car"), for: .normal)
        itineraryButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        itineraryButton.addTarget(self, action: #selector(didTapItineraryButton), for: .touchUpInside)
        view.addSubview(itineraryButton)
        
        let greenButton = UIButton(frame: CGRect(x: view.frame.size.width - 10 - 52, y: view.frame.size.height - 20 - 104, width: 52, height: 52))
        greenButton.backgroundColor = UIColor.white
        greenButton.layer.cornerRadius = greenButton.frame.size.width/2
        greenButton.layer.shadowColor = UIColor.gray.cgColor
        greenButton.layer.shadowOpacity = 0.8
        greenButton.layer.shadowRadius = 5.0
        greenButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        greenButton.setImage(UIImage(named: "bike"), for: .normal)
        greenButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        greenButton.addTarget(self, action: #selector(didTapGreenButton), for: .touchUpInside)
        view.addSubview(greenButton)
        
        buttonsAdded = true
    }
    
    func didTapGreenButton() {
        self.drawPolylinesForFirstLocations(location: 2)
    }
    
    func didTapItineraryButton() {
        self.drawPolylinesForFirstLocations(location: 1)
    }
    
    private func drawPolylinesForFirstLocations(location: NSInteger) {
        if self.checkPolylinesAvailability(polyline: location) {
            var url:NSURL!
            let secondLocation = CLLocationCoordinate2DMake(45.76057300000001, 4.857304900000031)
            
            if (location == 1) {
                url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation.latitude),\(currentLocation.longitude)&destination=\(endLocation.latitude),\(endLocation.longitude)&key=AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU")
            } else if (location == 2) {
                url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation.latitude),\(currentLocation.longitude)&destination=\(secondLocation.latitude),\(secondLocation.longitude)&key=AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU")
            } else {
                url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(secondLocation.latitude),\(secondLocation.longitude)&destination=\(endLocation.latitude),\(endLocation.longitude)&key=AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU")
            }
            
            let request = NSURLRequest(url: url! as URL)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
                        let routes = jsonResult.value(forKey: "routes") as! NSArray
                        let routesDict = routes.object(at: 0) as! NSDictionary
                        let overViewPolylineDict = routesDict.object(forKey: "overview_polyline") as! NSDictionary
                        let overviewPolylinePoints = overViewPolylineDict.object(forKey: "points") as! String
                        
                        DispatchQueue.main.async {
                            self.addPolyLineWithEncodedStringInMap(encodedString: overviewPolylinePoints, color: location == 1 ? UIColor.red : UIColor.green)
                            self.mapView.camera = GMSCameraPosition(target: self.currentLocation, zoom: 13.5, bearing: 0, viewingAngle: 0)
                            if (location < 3 && location > 1) {
                                self.drawPolylinesForFirstLocations(location: location+1)
                            }
                            else {
                                return
                            }
                        }
                    }
                }
                catch{
                    print("Something wrong")
                }
            });
            
            task.resume()
        }
    }
    
    func checkPolylinesAvailability(polyline: NSInteger) -> Bool {
        var next = true
    
        self.drawMarkers()
        
        if polyline == 1 && redPolyline != nil {
            redPolyline.map = nil
            redPolyline = nil
            next = false
        }
            
        else if polyline > 1 && polyline < 3 && greenPolyline != nil {
            for i in 0..<greenPolyline.count {
                let polylineToRemove:GMSPolyline = greenPolyline.object(at: i) as! GMSPolyline
                polylineToRemove.map = nil
                next = false
            }
            greenPolyline = nil
        }
        
        return next
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String, color: UIColor) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        
        polyLine.strokeWidth = 5
        polyLine.strokeColor = color
        polyLine.map = self.mapView
        
        if (color == UIColor.red) {
            redPolyline = polyLine
        } else {
            if greenPolyline == nil {
                greenPolyline = NSMutableArray()
            }
            greenPolyline.add(polyLine)
        }
    }
}



