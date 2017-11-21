//
//  DrawerContentViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/18/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Pulley
import SDWebImage

protocol DrawerContentViewControllerDelegate {
    func showPlaceDetail(place: Place)
}

class DrawerContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var places = [Place]() {
        didSet {
            loaded = true
            tableView.reloadData()
        }
    }
    fileprivate var loaded = false
    
    var customDelegate: DrawerContentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension DrawerContentViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if drawer.drawerPosition == .open {
            self.tableView.isScrollEnabled = true
        }
        else {
            self.tableView.isScrollEnabled = false
        }
    }
}

extension DrawerContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count == 0 {
            return 1
        }
        else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if places.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as? NoPlaceDataTableViewCell {
                if loaded {
                    cell.label.text = "No Place in Current Map Area"
                }
                else {
                    cell.label.text = "Loading Data..."
                }
                
                cell.selectionStyle = .none
                return cell
            }
            else {
                NSLog("Generating cell for no data failed.")
                return UITableViewCell()
            }
        }
        else {
            let place = places[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as? PlaceTableViewCell {
                
                if let imageUrl = try? place.avatarUrl.asURL() {
                    cell.avatarImageView.sd_setImage(with: imageUrl, completed: nil)
                }
                
                cell.nameLabel.text = place.name!
                
                var pointLabelPluralText = ""
                if place.points! > 1 {
                    pointLabelPluralText = "s"
                }
                cell.pointLabel.text = "\(place.points!)pt\(pointLabelPluralText)"
                
                var descriptionLabelPluralText = ""
                if place.numVisits! > 1 {
                    descriptionLabelPluralText = "s"
                }
                cell.descriptionLabel.text = "Visited by \(place.numVisits!) user\(descriptionLabelPluralText)."
                
                cell.selectionStyle = .none
                return cell
            }
            else {
                NSLog("Generating cell for place \(place.id!) failed.")
                return UITableViewCell()
            }
        }
    }
    
}

extension DrawerContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if places.count == 0 {
            return self.tableView.frame.height
        }
        else {
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if places.count == 0 {
            return
        }
        if let delegate = customDelegate {
            delegate.showPlaceDetail(place: places[indexPath.row])
        }
    }
}
