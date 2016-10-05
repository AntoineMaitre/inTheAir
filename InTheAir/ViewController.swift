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
        let path = GMSMutablePath()
        path.add(endLocation)
        path.add(startLocation)
        
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeWidth = 2
        rectangle.map = mapView
    }
}



