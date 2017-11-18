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

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var statsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsCollectionView.dataSource = self
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 34.0224, longitude: -118.2851), zoomLevel: 9, animated: false)
        
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
    
    private func updateMapAtCenter(coordinate: CLLocationCoordinate2D) {
        mapView.setCenter(coordinate, animated: true)
    }
    
    // MARK: - CL Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate {
            updateMapAtCenter(coordinate: locValue)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
