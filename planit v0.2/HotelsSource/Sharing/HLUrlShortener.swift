//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  HLUrlShortener.swift
//  HotelLook
//
//  Created by Anton Chebotov on 19/08/15.
//  Copyright (c) 2015 Anton Chebotov. All rights reserved.
//

import Foundation

class HLUrlShortener: NSObject {
    private(set) var longUrlString: String = ""
    private(set) var shortenedUrlString: String = ""

    var shortenedUrlString: String = ""
    var longUrlString: String = ""

    func shortenUrl(for variant: HLResultVariant, completion: @escaping (_: Void) -> Void) {
        if shortenedUrlString != "" {
            completion()
        }
        else {
            let request: URLRequest? = self.request(with: variant)
            send(request, completion: completion)
        }
    }

    func shortenedUrl() -> String {
        return shortenedUrlString ?? longUrlString
    }

    func send(_ request: URLRequest, completion: @escaping (_: Void) -> Void) {
        weak var weakSelf: HLUrlShortener? = self
        let task: URLSessionDataTask? = URLSession.sharedSession.dataTask(with: request, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
                if weakSelf != nil {
                    let strongSelf: HLUrlShortener? = weakSelf
                    strongSelf?.parseResult(data, connectionError: error)
                    if completion {
                        completion()
                    }
                }
            })
        task?.resume()
    }

    func request(with variant: HLResultVariant) -> URLRequest {
        var request = NSMutableURLRequest()
        var longUrlString = HLUrlUtils.sharingBookingUrlString(with: variant)
        self.longUrlString = longUrlString
        longUrlString = HLUrlUtils.urlencodeString(longUrlString)
        var requestString: String = "\(HLUrlUtils.urlShortenerBaseURLString)=\(HL_URL_SHORTENER_USERNAME)&password=\(HL_URL_SHORTENER_PASSWORD)&action=shorturl&format=json&url=\(longUrlString)"
        requestString = requestString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowedCharacterSet)
        request.url = URL(string: requestString)
        request.timeoutInterval = 5.0
        return request
    }

    func parseResult(_ data: Data, connectionError: Error?) {
        if connectionError == nil {
            var error: Error? = nil
            let dict: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(with: data, options: NSJSONReadingAllowFragments)
            if error == nil {
                shortenedUrlString = dict["shorturl"]
            }
        }
    }
}