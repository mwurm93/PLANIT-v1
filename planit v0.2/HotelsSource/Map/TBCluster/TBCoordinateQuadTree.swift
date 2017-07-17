//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  TBCoordinateQuadTree.swift
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

import Foundation

struct TBHotelInfo {
    var hotelId: [CChar] = [CChar]()
}
typealias TBHotelInfo = TBHotelInfo

class TBCoordinateQuadTree: NSObject {
    var root: TBQuadTreeNode?

    var variants = [Any]()
    var variantsDict = [AnyHashable: Any]()

    func build(withVariants variants: [Any]) {
        self.variants = variants
        autoreleasepool {
            let count: Int = variants.count
            variantsDict = [AnyHashable: Any]()
            let dataArray: TBQuadTreeNodeData? = malloc(MemoryLayout<TBQuadTreeNodeData>.size * count)
            for i in 0..<count {
                let variant: HLResultVariant? = variants[i]
                dataArray[i] = TBDataFromVariant(variant)
                variantsDict[variant?.hotel?.hotelId] = variant
            }
            let world: TBBoundingBox = TBBoundingBoxMake(-180, -180, 180, 180)
            root = TBQuadTreeBuildWithData(dataArray, count, world, 4)
        }
    }

    func clusteredAnnotations(within rect: MKMapRect, withZoomScale zoomScale: Double) -> [Any] {
        let TBCellSize: Double = TBCellSizeForZoomScale(zoomScale)
        let scaleFactor: Double = zoomScale / TBCellSize
        let minX: Int = floor(MKMapRectGetMinX(rect) * scaleFactor)
        let maxX: Int = floor(MKMapRectGetMaxX(rect) * scaleFactor)
        let minY: Int = floor(MKMapRectGetMinY(rect) * scaleFactor)
        let maxY: Int = floor(MKMapRectGetMaxY(rect) * scaleFactor)
        var clusteredAnnotations = [Any]()
        for x in minX...maxX {
            for y in minY...maxY {
                let mapRect: MKMapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor)
                var totalX: Double = 0
                var totalY: Double = 0
                let count: Int = 0
                var variants = [Any]()
                var names = [Any]()
                var phoneNumbers = [Any]()
                TBQuadTreeGatherDataInRange(root, TBBoundingBoxForMapRect(mapRect), {(_ data: TBQuadTreeNodeData) -> Void in
                    totalX += data.x
                    totalY += data.y
                    let hotelInfo: TBHotelInfo? = (data.data as? TBHotelInfo)
                    let hotelId: String? = "\(hotelInfo?.hotelId)"
                    let variant: HLResultVariant? = self.variant(withId: hotelId)
                    if variant != nil {
                        count
                        count += 1
                        variants.append(variant)
                    }
                    count += 1
                })
                count += 1
                if count == 1 {
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(totalX, totalY)
                    let annotation = TBClusterAnnotation(coordinate: coordinate, variants: variants)
                    annotation.title = names.last
                    annotation.subtitle = phoneNumbers.last
                    clusteredAnnotations.append(annotation)
                }
                if count > 1 {
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(totalX / count, totalY / count)
                    let annotation = TBClusterAnnotation(coordinate: coordinate, variants: variants)
                    clusteredAnnotations.append(annotation)
                }
            }
            count += 1
        }
        count += 1
        return [Any](arrayLiteral: clusteredAnnotations)
    }

    func variant(withId hotelId: String) -> HLResultVariant {
        return variantsDict[hotelId]
    }
}

private func TBDataFromVariant(variant: HLResultVariant) -> TBQuadTreeNodeData {
    let hotelInfo: TBHotelInfo? = malloc(MemoryLayout<TBHotelInfo>.size)
    let hotelId: String = variant.hotel.hotelId
    hotelInfo?.hotelId = malloc(MemoryLayout<CChar>.size * (hotelId.characters.count ?? 0) + 1)
    strncpy(hotelInfo?.hotelId, hotelId.utf8, (hotelId.characters.count ?? 0) + 1)
    return TBQuadTreeNodeDataMake(variant.hotel.latitude, variant.hotel.longitude, hotelInfo)!
}

private func TBBoundingBoxForMapRect(mapRect: MKMapRect) -> TBBoundingBox {
    let topLeft: CLLocationCoordinate2D = MKCoordinateForMapPoint(mapRect.origin)
    let botRight: CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
    let minLat: CLLocationDegrees? = botRight.latitude
    let maxLat: CLLocationDegrees? = topLeft.latitude
    let minLon: CLLocationDegrees? = topLeft.longitude
    let maxLon: CLLocationDegrees? = botRight.longitude
    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon)
}

private func TBCellSizeForZoomScale(zoomScale: MKZoomScale) -> Float {
    return 100
}