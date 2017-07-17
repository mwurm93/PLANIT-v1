//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRFilterListSeparatorItem.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

class JRFilterListSeparatorItem: NSObject, JRFilterItemProtocol {
    private var title: String = ""

    init(title: String) {
        super.init()
        
        self.title = title
    
    }

    func tilte() -> String {
        return title
    }
}