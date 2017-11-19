//
//  SelectLocationViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/19/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import CoreLocation

class SelectLocationViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var locations = [Place]()
    
    private var selectedLocation: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        containerView.layer.cornerRadius = 5.0
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        
        selectedLocation = nil
        performSegue(withIdentifier: "unwindToAddPostView", sender: self)
        
    }
    
    private func loadData() {
        
        if let userLocation = Globals.location {
            
            let minLat = userLocation.latitude - 0.1
            let maxLat = userLocation.latitude + 0.1
            let minLon = userLocation.longitude - 0.1
            let maxLon = userLocation.longitude + 0.1
            
            let mapRequestUrl = "\(Globals.restDir)/map/inArea/latBetween/\(minLat)/and/\(maxLat)/lonBetween/\(minLon)/and/\(maxLon)"
            Alamofire.request(mapRequestUrl).responseArray { (response: DataResponse<[Place]>) in
                
                guard let places = response.result.value else {
                    NSLog("Cannot get places data")
                    return
                }
                
                for location in places {
                    
                    let distance = CLLocation.init(latitude: userLocation.latitude, longitude: userLocation.longitude).distance(from: CLLocation.init(latitude: location.lat, longitude: location.lon)) / 1000
                    let distanceKm = Double(round(100*distance)/100)

                    if distanceKm < 1.0 {
                        self.locations.append(location)
                    }
                    
                }
                
                self.tableView.reloadData()
                
            }
            
        }
        else {
            
            // TODO: user location not found
            
        }
        
    }
    
    // MARK - Navigation
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier == "unwindToAddPostView", let dvc = unwindSegue.destination as? AddPostViewController {
            
            dvc.location = selectedLocation
            
            if dvc.location == nil {
                dvc.dismiss(animated: true, completion: nil)
            }
            else {
                dvc.locationLabel.text = selectedLocation?.name!
            }
            
        }
    }
    
}

extension SelectLocationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "selectLocationCell", for: indexPath) as? SelectLocationTableViewCell {
            
            let location = locations[indexPath.row]
            
            if let imageUrl = try? location.avatarUrl.asURL() {
                cell.avatarImageView.sd_setImage(with: imageUrl, completed: nil)
            }
            
            cell.nameLabel.text = location.name!
            
            var plural = ""
            if location.points! > 1 {
                plural = "s"
            }
            cell.descriptionLabel.text = "\(location.points!)pt\(plural) · \(location.numVisits!) visits"
            
            return cell
            
        }
        else {
            NSLog("Get cell at row \(indexPath.row) failed.")
            return UITableViewCell()
        }
    }
    
}

extension SelectLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocation = locations[indexPath.row]
        performSegue(withIdentifier: "unwindToAddPostView", sender: self)
    }
    
}
