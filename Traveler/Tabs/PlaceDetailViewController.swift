//
//  PlaceDetailViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/18/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyButton
import CoreLocation
import Hero

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var backButton: FlatButton!
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var visitedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var addPostButton: FlatButton!
    
    var place: Place!
    var source: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        isHeroEnabled = true
        mapView.heroID = "map"
        
        backButton.heroModifiers = [.fade, .translate(x: -100)]
        self.view.heroModifiers = [.cascade]
        avatarImageView.heroModifiers = [.fade, .scale(1.0)]
        for view in [titleLabel, contentView, addPostButton] {
            view?.heroModifiers = [.fade, .translate(y: 20)]
        }
        
        let location = CLLocationCoordinate2D(latitude: place.lat!, longitude: place.lon!)
        mapView.setZoomLevel(14.0, animated: false)
        mapView.setCenter(location, animated: false)
        
        let  marker = MGLPointAnnotation()
        marker.coordinate = location
        mapView.addAnnotation(marker)
        
        if let url = try? place.avatarUrl.asURL() {
            avatarImageView.sd_setImage(with: url, completed: nil)
        }
        avatarImageView.layer.backgroundColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 3.0
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.shadowRadius = 2.0
        avatarImageView.layer.shadowColor = UIColor.black.cgColor
        avatarImageView.layer.shadowOffset = CGSize.zero
        avatarImageView.layer.shadowOpacity = 0.5
        avatarImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        avatarImageView.layer.shadowPath = UIBezierPath(rect: avatarImageView.bounds).cgPath
        
        titleLabel.text = place.name!
        pointLabel.text = "\(place.points!)"
        visitedLabel.text = "\(place.numVisits!)"
        
        var canPost = false
        if let userLocation = Globals.location {
            let distance = CLLocation.init(latitude: userLocation.latitude, longitude: userLocation.longitude).distance(from: CLLocation.init(latitude: location.latitude, longitude: location.longitude)) / 1000
            let distanceKm = Double(round(100*distance)/100)
            distanceLabel.text = "\(distanceKm) KM"
            if distanceKm < 1.0 {
                canPost = true
            }
        }
        else {
            distanceLabel.text = "Unknown"
        }
        
        if canPost {
            addPostButton.isEnabled = true
            addPostButton.titleLabel?.text = "Add Post"
        }
        else {
            addPostButton.isEnabled = false
            addPostButton.titleLabel?.text = "Approach the Site to Make Post"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPost(_ sender: UIButton) {
        performSegue(withIdentifier: "addPostFromPlaceDetailPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPostFromPlaceDetailPage", let dvc = segue.destination as? AddPostViewController {
            
            dvc.location = place
            
        }
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
        var segueName = ""
        if source == "home" {
            segueName = "unwindToHomeView"
        }
        else {
            segueName = "unwindToExploreView"
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.performSegue(withIdentifier: segueName, sender: self)
    }
}
