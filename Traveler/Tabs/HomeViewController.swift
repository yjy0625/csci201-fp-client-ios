//
//  HomeViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Mapbox
import Hero

class HomeViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var statsCollectionView: UICollectionView!
    
    fileprivate var icon = UIImage.init(named: "markerIcon")
    fileprivate var annotations = [String: MarkerAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.heroID = "map"
        statsCollectionView.heroModifiers = [.fade, .translate(y: -100)]
        
        statsCollectionView.dataSource = self
        
        mapView.delegate = self
        if let styleUrl = try? "mapbox://styles/pvxyie/cj8r298c7b5ra2ts1yx9i7pzz".asURL() {
            mapView.styleURL = styleUrl
        }
        mapView.setTargetCoordinate(CLLocationCoordinate2D.init(latitude: 34.0224, longitude: -118.2851), animated: false)
        mapView.setZoomLevel(13.0, animated: false)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateMapAtCenter(coordinate: CLLocationCoordinate2D) {
        mapView.setCenter(coordinate, animated: true)
        let visibleMapBounds = self.mapView.visibleCoordinateBounds
        let minLat = visibleMapBounds.sw.latitude
        let maxLat = visibleMapBounds.ne.latitude
        let minLon = visibleMapBounds.sw.longitude
        let maxLon = visibleMapBounds.ne.longitude
        
        let mapRequestUrl = "\(Globals.restDir)/map/inArea/latBetween/\(minLat)/and/\(maxLat)/lonBetween/\(minLon)/and/\(maxLon)"
        Alamofire.request(mapRequestUrl).responseArray { (response: DataResponse<[Place]>) in
            
            guard let places = response.result.value else {
                NSLog("Cannot get places data")
                return
            }
            
            for place in places {
                if self.annotations[place.id!] != nil {
                    continue
                }
                
                let marker = MarkerAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon),
                    data: place,
                    title: place.name,
                    subtitle: "Visit Count: \(place.numVisits!)"
                )
                self.mapView.addAnnotation(marker)
                self.annotations[place.id!] = marker
            }
            
        }
    }
    
    // MARK: - CL Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate {
            Globals.location = locValue
            updateMapAtCenter(coordinate: locValue)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceDetail", let annotation = sender as? MarkerAnnotation {
            if let dvc = segue.destination as? PlaceDetailViewController {
                dvc.place = annotation.data
                dvc.source = "home"
            }
        }
    }
    
    @IBAction func unwindToHomeView(segue: UIStoryboardSegue) {}

}

// MARK: - MGLMapViewDelegate methods
extension HomeViewController {
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        updateMapAtCenter(coordinate: mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MarkerAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            
            annotationView!.backgroundColor = Globals.ThemeColor
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let annotation = annotation as? MarkerAnnotation {
            performSegue(withIdentifier: "showPlaceDetail", sender: annotation)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.row
        if index < 0 || index > 2 {
            return UICollectionViewCell()
        }
        
        let identifiers = ["pointsCell", "levelCell", "rankingCell"]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifiers[index], for: indexPath) as? HomeViewStatsCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.titleLabel.font = UIFont(name: "Avenir", size: 14.0)
        cell.statsLabel.font = UIFont(name: "Avenir", size: 44.0)
        
        if indexPath.row == 0 {
            if let score = Globals.user?.score {
                cell.statsLabel.text = "\(score)"
            }
            else {
                cell.statsLabel.text = "--"
            }
            
            return cell
        }
        else if indexPath.row == 1 {
            if let score = Globals.user?.score {
                cell.statsLabel.text = "\(Int(floor(Double(score / 100))) + 1)"
            }
            else {
                cell.statsLabel.text = "--"
            }
            
            return cell
        }
        else {
            cell.statsLabel.text = "--"
                    
            guard let user = Globals.user?.id else {
                return UICollectionViewCell()
            }
            
            let rankRequestUrl: String = "\(Globals.restDir)/user/rank/id/\(user)"
            Alamofire.request(rankRequestUrl).responseString { response in
                if let rankString = response.value {
                    if let rank = Int(rankString) {
                        cell.statsLabel.text = rank.prettify()
                    }
                }
            }
            
            return cell
        }
        
    }
}
