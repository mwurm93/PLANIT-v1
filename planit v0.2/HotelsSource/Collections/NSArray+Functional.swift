//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
import Foundation

extension NSArray {
    func map(_ block: @escaping (_ obj: Any) -> Any) -> [Any] {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        var result = [Any]() /* capacity: count */
        (self as NSArray).enumerateObjects(usingBlock: {(_ obj: Any, _ idx: Int, _ stop: Bool) -> Void in
            let value: Any? = block(obj)
            if value != nil {
                result.append(value)
            }
        })
        return result
    }

    func flattenMap(_ block: @escaping (_ obj: Any) -> Any) -> [Any] {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        var result = [Any]()
        (self as NSArray).enumerateObjects(usingBlock: {(_ obj: Any, _ idx: Int, _ stop: Bool) -> Void in
            let value: Any? = block(obj)
            if (value? is [Any]) {
                result += value
            }
        })
        return result
    }

    func filter(_ block: @escaping (_ obj: Any) -> Bool) -> [Any] {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        return objects(atIndexes: (self as NSArray).indexesOfObjects(passingTest: {(_ obj: Any, _ idx: Int, _ stop: Bool) -> Bool in
            return block(obj)
        }))
    }

    func arrayWithoutDuplicates() -> [Any] {
        let orderedSet = NSOrderedSet(array: self)
        return orderedSet.array()
    }

    func atLeastOneConfirms(_ pred: @escaping (_ obj: Any) -> Bool) -> Bool {
        for x: Any in self {
            if pred(x) {
                return true
            }
        }
        return false
    }

    func allObjectsConfirm(_ pred: @escaping (_ obj: Any) -> Bool) -> Bool {
        for x: Any in self {
            if !pred(x) {
                return false
            }
        }
        return true
    }

    func hl_firstMatch(_ block: @escaping (_ obj: Any) -> Bool) -> Any {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        let index: Int = (self as NSArray).indexOfObject(passingTest: {(_ obj: Any, _ idx: Int, _ stop: Bool) -> Bool in
                return block(obj)
            })
        if index == NSNotFound {
            return nil
        }
        return self[index]
    }

    func lastIndexOfObject(passingTest pred: @escaping (_ obj: Any, _ index: Int) -> Bool) -> Int {
        var currentIndex: Int = count - 1
        for x: Any in (self as NSArray).reverseObjectEnumerator() {
            if pred(x, currentIndex) {
                return currentIndex
            }
            currentIndex = currentIndex - 1
        }
        return NSNotFound
    }
}