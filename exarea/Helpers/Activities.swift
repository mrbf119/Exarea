//
//  Activities.swift
//  exarea
//
//  Created by Soroush on 11/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import MapKit

class MapActivity: UIActivity {
    
    private let title: String
    private let image: UIImage?
    private let action: ([Any]) -> Void
    private var activityItems = [Any]()
    
    private init(title: String, image: UIImage?, action: @escaping ([Any]) -> Void) {
        self.title = title
        self.image = image
        self.action = action
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.tamtom.exarea.\(self.title)")
    }
    
    override var activityTitle: String? {
        return self.title
    }
    
    override var activityImage: UIImage? {
        return self.image
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        
        guard let mapLocation = activityItems.first as? MKMapItem else { return false }
        let url: URL
        switch self {
        case MapActivity.google:
            url = URL(string: "comgooglemaps://?saddr=&daddr=\(mapLocation.placemark.coordinate.latitude),\(mapLocation.placemark.coordinate.longitude)")!
        case MapActivity.waze:
            url = URL(string: "waze://?ll=\(mapLocation.placemark.coordinate.latitude),\(mapLocation.placemark.coordinate.longitude)")!
        default:
            return true
        }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
       self.activityItems = activityItems
    }
    
    override func perform() {
        action(self.activityItems)
        activityDidFinish(true)
        
    }
}

extension MapActivity {
    
    static let google = MapActivity(title: "Google Maps", image: UIImage(named: "icon-googlemaps-small")) { items in
        
        if let mapLocation = items.first as? MKMapItem {
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(mapLocation.placemark.coordinate.latitude),\(mapLocation.placemark.coordinate.longitude)") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static let waze = MapActivity(title: "Waze", image: UIImage(named: "icon-waze-small")) { items in
        if let mapLocation = items.first as? MKMapItem {
            if let url = URL(string: "waze://?ll=\(mapLocation.placemark.coordinate.latitude),\(mapLocation.placemark.coordinate.longitude)") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static let maps = MapActivity(title: "Maps", image: UIImage(named: "icon-maps-small")!) { items in
        if let mapItem = items.first as? MKMapItem {
            mapItem.openInMaps(launchOptions: [:])
        }
    }
}



