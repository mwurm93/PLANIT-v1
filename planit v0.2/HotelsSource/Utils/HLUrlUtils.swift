//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation
import HotellookSDK

let HL_HOST_PARAMETER_KEY = "host"

enum HLUrlUtilsImageAlignment : Int {
    case center
    case right
    case left
}

let kHlsUrlParameterKey: String = "flags[utm]"
let kUtmUrlParameterKey: String = "flags[utmDetail]"
let kMarkerUrlParameterKey: String = "marker"

class HLUrlUtils: NSObject {
    class func cityPhotoBaseURLString() -> String {
        return "https://photo.hotellook.com/static/cities/"
    }

    class func baseGateURLString() -> String {
        return "https://pics.avs.io/hl_gates"
    }

    class func urlShortenerBaseURLString() -> String {
        return "http://htl.io/yourls-api.php?"
    }

    class func firstHotelPhotoURL(by hotel: HDKHotel) -> URL {
        let size: CGSize = HLPhotoManager.defaultHotelPhotoSize()
        return self.photoURL(forPhotoId: hotel.photosIds.first, size: size)
    }

    class func firstHotelPhotoURL(by hotel: HDKHotel, withSizeInPoints size: CGSize) -> URL {
        return self.photoURL(forPhotoId: hotel.photosIds.first, size: size)
    }

    class func photoUrls(by hotel: HDKHotel, withSizeInPoints size: CGSize) -> [Any] {
        var urls = [Any]()
        if size.height > 0 && size.width > 0 && hotel.photosIds.count {
            for photoId: String in hotel.photosIds {
                urls.append(HLUrlUtils.photoURL(for: photoId, size: size))
            }
        }
        return urls
    }

    class func photoURL(forPhotoId photoId: String, size: CGSize) -> URL {
        if photoId == nil {
            photoId = "NULL_PHOTO_ID"
        }
        let scale: CGFloat = self.screenScale
        let urlString: String = "\(HLUrlUtils.basePhotoURLString)/\(photoId)/%.0f/%.0f.jpg"
        return URL(string: urlString)!
    }

    class func photoURL(by hotel: HDKHotel, size: CGSize, index: Int) -> URL {
        if index < 0 || index >= hotel.photosIds.count {
            return self.photoURL(forPhotoId: "BAD_PHOTO_INDEX", size: size)
        }
        let photoId: String = hotel.photosIds[index]
        return self.photoURL(forPhotoId: photoId, size: size)
    }

    class func gateIconURL(_ gateId: Int, size: CGSize, alignment: HLUrlUtilsImageAlignment) -> URL {
        let scale: CGFloat = self.screenScale
        let width: CGFloat = size.width * scale
        let height: CGFloat = size.height * scale
        var alignString: String? = nil
        switch alignment {
            case .center:
                alignString = ""
            case .left:
                alignString = "--west"
            case .right:
                alignString = "--east"
        }

        let urlString = "\(HLUrlUtils.baseGateURLString())/%.0f/%.0f/\(width)\(height).png"
        return URL(string: urlString)!
    }

    class func handoffBookingUrlString(with variant: HLResultVariant) -> String {
        return self.bookingUrlString(with: variant, source: "handoff")
    }

    class func sharingBookingUrlString(with variant: HLResultVariant) -> String {
        return self.bookingUrlString(with: variant, source: "mobilesharing")
    }

    class func searchUrlString(with searchInfo: HLSearchInfo) -> String {
        var searchUrlString: String = "%@/?%@"
        let baseUrlString: String = HLUrlUtils.searchBaseURLString
        var destinationString: String? = nil
        if searchInfo.isSearchByLocation {
            let coordinate: CLLocationCoordinate2D = searchInfo.locationPoint.location.coordinate
            destinationString = String(format: "geo[lat]=%.6f&geo[lon]=%.6f&", coordinate.latitude, coordinate.longitude)
        }
        else if searchInfo.hotel {
            let hotelId: String = searchInfo.hotel.hotelId
            destinationString = "hotelId=\(hotelId)&"
        }
        else {
            let locationId: String = searchInfo.city.cityId
            destinationString = "locationId=\(locationId)&"
        }

        searchUrlString = String(format: searchUrlString, baseUrlString, destinationString)
        var result: String = searchUrlString
        let params = self.paramsString(with: searchInfo, source: "handoff")
        result += params
        return result
    }

    class func dateParam(toString date: Date) -> String {
        let formatter = HDKDateUtil.sharedServerDateFormatter()
        return formatter.string(from: date)
    }

    class func urlencodeString(_ string: String) -> String {
        var output = String()
        let source: [UInt8] = UInt8(string.utf8)
        let sourceLen: UInt = strlen(CChar(source))
        for i in 0..<sourceLen {
            let thisChar: UInt8 = source[i]
            if thisChar == " " {
                output += "+"
            }
            else if thisChar == "." || thisChar == "-" || thisChar == "_" || thisChar == "~" || (thisChar >= "a" && thisChar <= "z") || (thisChar >= "A" && thisChar <= "Z") || (thisChar >= "0" && thisChar <= "9") {
                output += "\(thisChar)"
            }
            else {
                output += String(format: "%%%02X", thisChar)
            }
        }
        return output
    }

    class func basePhotoURLString() -> String {
        return "https://photo.hotellook.com/image_v2/"
    }

    class func bookingBaseURLString() -> String {
        return "https://search.hotellook.com"
    }

    class func searchBaseURLString() -> String {
        return "https://search.hotellook.com"
    }

    class func screenScale() -> CGFloat {
        return Int(UIScreen.main.scale())
    }

    class func paramsString(with searchInfo: HLSearchInfo, source: String) -> String {
        let checkIn: String = HLUrlUtils.dateParam(toString: searchInfo.checkInDate)
        let checkOut: String = HLUrlUtils.dateParam(toString: searchInfo.checkOutDate)
        let currency: String = searchInfo.currency.code
        let language = HLLocaleInspector.sharedInspector.localeString()
        let utmMedium: String = platformName()
        let paramString: String = "mobileToken=%@&checkIn=%@&checkOut=%@&currency=%@&hls=%@&language=%@&adults=%i&utm_source=mobile&utm_medium=%@&utm_campaign=%@"
        var result = String(format: paramString, searchInfo.token, checkIn, checkOut, currency, source, language, searchInfo.adultsCount, utmMedium, source)
        if searchInfo.kidAgesArray.count > 0 {
            result += "&children="
            for i in 0..<searchInfo.kidAgesArray.count {
                result += "\(CInt(searchInfo.kidAgesArray[i]))"
                if i < searchInfo.kidAgesArray.count - 1 {
                    result += ","
                }
            }
        }
        return result
    }

    class func bookingUrlString(with variant: HLResultVariant, source: String) -> String {
        var searchUrlString: String = "%@/?hotelId=%@&"
        let baseUrlString = HLUrlUtils.bookingBaseURLString()
        let hotelId: String = variant.hotel.hotelId
        searchUrlString = String(format: searchUrlString, baseUrlString, hotelId)
        var result: String = searchUrlString
        let params = self.paramsString(with: variant.searchInfo, source: source)
        result += params
        return result
    }
}