//
//  PrimaryContentViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/18/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Mapbox
import Pulley

protocol PrimaryContentViewControllerDelegate {
    func shouldUpdatePlaceData()
}

class PrimaryContentViewController: UIViewController {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    fileprivate var annotations = [String: MarkerAnnotation]()
    
    var places = [Place]() {
        didSet {
            updateMapMarkers()
        }
    }
    
    var customDelegate: PrimaryContentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        if let styleUrl = try? "mapbox://styles/pvxyie/cj8r298c7b5ra2ts1yx9i7pzz".asURL() {
            mapView.styleURL = styleUrl
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateMapMarkers() {
        for place in places {
            if annotations[place.id!] != nil {
                continue
            }
            
            let marker = MarkerAnnotation(
                coordinate: place.getLocation(),
                data: place,
                title: place.name,
                subtitle: "Visit Count: \(place.numVisits!)"
            )
            self.mapView.addAnnotation(marker)
            self.annotations[place.id!] = marker
        }
    }

}

extension PrimaryContentViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let annotation = annotation as? MarkerAnnotation {
            mapView.setCenter(annotation.data.getLocation(), animated: true)
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        if let delegate = customDelegate {
            delegate.shouldUpdatePlaceData()
        }
    }
}
