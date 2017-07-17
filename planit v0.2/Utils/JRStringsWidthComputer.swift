//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRStringsWidthComputer.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

class JRStringsWidthComputer: NSObject {
    var cache: NSCache?
    var stringAttributes = [AnyHashable: Any]()

    init(font: UIFont) {
        assert(font != nil, "Invalid parameter not satisfying: font != nil")
        super.init()

        cache = NSCache()
        stringAttributes = [NSFontAttributeName: font]
        if cache == nil || stringAttributes == nil {
            self = nil
        }
    
    }

    func width(with string: String) -> CGFloat {
        assert(string != nil, "Invalid parameter not satisfying: string != nil")
        let fromCache = cache?.object(forKey: string as? KeyType ?? KeyType())
        var result: CGFloat
        if fromCache != nil {
            result = CFloat(fromCache)
        }
        else {
            result = string.size(withAttributes: stringAttributes).width
            cache?.setObject((result), forKey: string as? KeyType ?? KeyType())
        }
        return result
    }
}