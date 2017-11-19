//
//  ExploreViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import Pulley

class ExploreViewController: PulleyViewController {
    
    weak var primaryVC: PrimaryContentViewController?
    weak var drawerVC: DrawerContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let primaryVC = primaryContentViewController as? PrimaryContentViewController {
            self.primaryVC = primaryVC
        }
        if let drawerVC = drawerContentViewController as? DrawerContentViewController {
            self.drawerVC = drawerVC
        }
        
        primaryVC?.customDelegate = self
        drawerVC?.customDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        shouldUpdatePlaceData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceDetailFromExplorePage", let place = sender as? Place {
            if let dvc = segue.destination as? PlaceDetailViewController {
                dvc.place = place
                dvc.source = "explore"
            }
        }
    }
    
    @IBAction func unwindToExploreView(segue: UIStoryboardSegue) {}

}

extension ExploreViewController: PrimaryContentViewControllerDelegate {
    func shouldUpdatePlaceData() {
        guard let visibleMapBounds = self.primaryVC?.mapView.visibleCoordinateBounds else {
            NSLog("Cannot load map bounds")
            return
        }
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
            
            self.primaryVC?.places = places
            self.drawerVC?.places = places
            
        }
    }
}

extension ExploreViewController: DrawerContentViewControllerDelegate {
    func showPlaceDetail(place: Place) {
        performSegue(withIdentifier: "showPlaceDetailFromExplorePage", sender: place)
    }
}

