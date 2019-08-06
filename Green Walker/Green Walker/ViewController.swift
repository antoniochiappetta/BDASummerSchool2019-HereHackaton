//
//  ViewController.swift
//  Green Walker
//
//  Created by Antonio Chiappetta on 06/08/2019.
//  Copyright © 2019 Group 5 BDASummerSchool 2019. All rights reserved.
//

import UIKit
import NMAKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UISearchBarDelegate, NMARouteManagerDelegate, NMAResultListener {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Constants
    
    private struct Constants {
        static let InitLat: Double = 40.4151
        static let InitLon: Double = -3.7015
        static let AreaRadius: Double = 250.0
        static let SearchRadius: Int = 1000
        static let ZoomLevel: Float = 12.0
        static let Alpha: CGFloat = 0.6
        static let StartPoint: NMAGeoCoordinates = NMAGeoCoordinates(latitude: Constants.InitLat, longitude: Constants.InitLon)
        static var AreasPath: String = "https://xyz.api.here.com/hub/spaces/56PrTyPD/search?limit=5000&clientId=cli&access_token=AKbEHXlPhETS8rhpC4PcC9c"
    }
    
    // MARK: - Properties
    
    let routeManager: NMARouteManager = NMARouteManager.shared()
    var mapRoute: NMAMapRoute?
    var pollutedAreas: [(latitude: Double, longitude: Double)] = []
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        pollutedAreas.append((latitude: Constants.InitLat, longitude: Constants.InitLon))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Position on Madrid
        self.setupUI()
        self.setupData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
        self.mapView.addGestureRecognizer(tapGesture)
        
        searchBar.delegate = self
        routeManager.delegate = self
    }
    
    // MARK: - Map
    
    func drawPollutedAreas() {
        for area in self.pollutedAreas {
            self.drawCircle(latitude: area.latitude, longitude: area.longitude, radius: Constants.AreaRadius)
        }
    }
    
    func drawCircle(latitude: Double, longitude: Double, radius: Double) {
        let coordinates: NMAGeoCoordinates =
            NMAGeoCoordinates(latitude: latitude, longitude: longitude)
        let mapCircle = NMAMapCircle(coordinates: coordinates, radius: radius)
        mapCircle.fillColor = UIColor.red.withAlphaComponent(Constants.Alpha)
        mapView.add(mapCircle)
    }
    
    func showRoute(to searchString: String) {
        cancelRoute()
        let geocodeRequest = NMAGeocoder.shared().makeGeocodeRequest(query: searchString, searchRadius: Constants.SearchRadius, searchCenter: Constants.StartPoint)
        geocodeRequest.start(listener: self)
    }
    
    func setupUI() {
        mapView.useHighResolutionMap = true
        mapView.zoomLevel = Constants.ZoomLevel
        mapView.set(geoCenter: NMAGeoCoordinates(latitude: Constants.InitLat, longitude: Constants.InitLon),
                    animation: .linear)
        mapView.copyrightLogoPosition = NMALayoutPosition.bottomCenter
    }
    
    func setupData() {
        let areasUrl = URL(string: Constants.AreasPath)!
        Alamofire.request(areasUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if let data = response.data {
                let jsonData = try! JSON(data: data)
                let features = jsonData["features"].arrayValue
                for (index,feature) in features.enumerated() {
                    let point = feature["geometry"]["coordinates"].arrayValue
                    let longitude = point[0].doubleValue
                    let latitude = point[1].doubleValue
                    self.pollutedAreas.append((latitude: latitude, longitude: longitude))
                    if index == features.count-1 {
                        self.drawPollutedAreas()
                    }
                }
                
            }
        }
    }
    
    @IBAction func cancelRoute() {
        self.setupUI()
        view.endEditing(true)
        if let mapRoute = mapRoute {
            mapView.remove(mapRoute)
        }
    }
    
    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            showRoute(to: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelRoute()
    }
    
    @objc func dismissSearch() {
        view.endEditing(true)
    }
    
    // MARK: - RouteManager Delegate
    
    func routeManagerDidCalculate(_ routeManager: NMARouteManager, routes: [NMARoute]?, error: NMARouteManagerError, violatedOptions: [NSNumber]?) {
        if let routes = routes {
            if let firstRoute = routes.first {
                let mapRoute = NMAMapRoute(route: firstRoute)
                self.mapRoute = mapRoute
                mapView.add(mapRoute)
            }
        }
    }
    
    // MARK: - Result Listener
    
    func requestDidComplete(_ request: NMARequest, data: Any?, error: Error?) {
        let mode = NMARoutingMode(routingType: .fastest, transportMode: .pedestrian, routingOptions: 0)!
        // Avoid areas and start routing
        
        if let result = (data as? [NMAGeocodeResult])?.first, let stopPoint = result.location.position {
            self.routeManager.calculateRoute(stops: [Constants.StartPoint,stopPoint], mode: mode)
        }
    }

}

