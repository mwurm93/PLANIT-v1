//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

class HLApiCoordinate: NSObject, NSCoding {
    var latitude: NSNumber?
    var longitude: NSNumber?

    convenience init(latitude: NSNumber, longitude: NSNumber) {
        return HLApiCoordinate(latitude: latitude, longitude: longitude)
    }

    init(latitude: NSNumber, longitude: NSNumber) {
        super.init()
        
        self.latitude = latitude
        self.longitude = longitude
    
    }

    func isEqual(_ object: Any) -> Bool {
        if (object is HLApiCoordinate) == false {
            return false
        }
        let otherCoordinate: HLApiCoordinate? = (object as? HLApiCoordinate)
        return (latitude == otherCoordinate?.latitude) && (longitude == otherCoordinate?.longitude)!
    }

    func copy() -> Any {
        let coord = HLApiCoordinate()
        coord.latitude = latitude
        coord.longitude = longitude
        return coord
    }

    func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }

    init(coder: NSCoder) {
        super.init()

        latitude = coder.decodeObject(forKey: "latitude") as? NSNumber ?? 0
        longitude = coder.decodeObject(forKey: "longitude") as? NSNumber ?? 0
    
    }
}