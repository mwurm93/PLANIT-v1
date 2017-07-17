//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  TBClusterAnnotation.swift
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/8/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

import Foundation
import MapKit

class TBClusterAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title: String = ""
    var subtitle: String = ""
    var variants = [Any]()

    init(coordinate: CLLocationCoordinate2D, variants: [Any]) {
        super.init()
        
        self.coordinate = coordinate
        self.variants = variants
    
    }

    func hash() -> Int {
        let toHash = String(format: "%.5F%.5F", coordinate.latitude, coordinate.longitude)
        return toHash.hash
    }

    func isEqual(_ object: Any) -> Bool {
        return hash() == object.hash
    }
}