//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSDictionary {
    func tryParseNotEmptyString(forKeys keys: [String]) -> String {
        for key: String in keys {
            let result: String? = string(forKey: key)
            if (result?.characters.count ?? 0) > 0 {
                return result!
            }
        }
        return nil
    }

    func string(forKey key: Any) -> String {
        let obj: Any? = objectOrNil(forKey: key)
        return castNumberOrString(toString: obj)
    }

    func integer(forKey key: Any) -> Int {
        return integer(forKey: key, defaultValue: 0)
    }

    func integer(forKey key: Any, defaultValue: Int) -> Int {
        let obj: Any? = objectOrNil(forKey: key)
        return obj?.responds(to: #selector(self.integerValue)) ? CInt(obj) : defaultValue!
    }

    func bool(forKey key: Any) -> Bool {
        return bool(forKey: key, defaultValue: false)
    }

    func bool(forKey key: Any, defaultValue: Bool) -> Bool {
        let number = self.number(forKey: key)
        return number != nil ? number != 0 : defaultValue
    }

    func double(forKey key: Any) -> Double {
        return CDouble(number(forKey: key))
    }

    func float(forKey key: Any) -> Float {
        return CFloat(number(forKey: key))
    }

    func number(forKey key: Any) -> NSNumber {
        let obj: Any? = objectOrNil(forKey: key)
        return (obj? is NSNumber) ? obj : nil
    }

    func dict(forKey key: Any) -> [AnyHashable: Any] {
        let obj: Any? = objectOrNil(forKey: key)
        return (obj? is [AnyHashable: Any]) ? obj : nil
    }

    func array(forKey key: Any) -> [Any] {
        let obj: Any? = objectOrNil(forKey: key)
        return (obj? is [Any]) ? obj : nil
    }

    func array(forKey key: Any, withObjectsOf klass: AnyClass) -> [Any] {
        let obj: Any? = objectOrNil(forKey: key)
        let arr: [Any] = (obj? is [Any]) ? obj : nil
        return arr.filter({(_ obj: Any) -> Bool in
            return (obj? is klass)
        })
    }

    func stringArray(forKey key: Any) -> [Any] {
        let arr: [Any]? = array(forKey: key as? String ?? "")
        return arr?.map({(_ obj: Any) -> Any in
            return self.castNumberOrString(toString: obj)
        })!
    }

    func objectOrNil(forKey key: Any) -> Any {
        let value: Any? = self[key]
        return (value? is NSNull) ? nil : value
    }

    func castNumberOrString(toString obj: Any) -> String {
        if (obj is String) {
            return obj
        }
        if (obj is NSNumber) {
            return String((obj as? NSNumber))!
        }
        return nil
    }
}

extension NSMutableDictionary {
    func setObjectSafe(_ anObject: Any, forKey aKey: NSCopying) {
        if !aKey {
            return
        }
        if anObject {
            self[aKey] = anObject
        }
        else {
            self[aKey] = ""
        }
    }
}