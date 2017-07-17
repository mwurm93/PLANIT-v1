//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRTableManagerUnion.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

/**
 * Works with one cell per section
 */
class JRTableManagerUnion: NSObject, JRTableManager {
    private var _secondManagerPositions: IndexSet?
    var secondManagerPositions: IndexSet? {
        get {
            return _secondManagerPositions
        }
        set(secondManagerPositions) {
            _secondManagerPositions = secondManagerPositions
            realSecondManagerPositions = nil
        }
    }

    weak var first: JRTableManager?
    weak var second: JRTableManager?
    private var _realSecondManagerPositions: IndexSet?
    var realSecondManagerPositions: IndexSet? {
        if _realSecondManagerPositions != nil {
                return _realSecondManagerPositions
            }
            let firstManagerTableSize: Int = firstTableSizeCache
            let secondManagerTableSize: Int = secondManagerPositions.count
            let tableSize: Int = firstManagerTableSize + secondManagerTableSize
            let allTableItemsIndexesRange = NSRange(location: 0, length: tableSize)
            let tableSizeForEnumeration: Int = firstManagerTableSize
            let elementsFromSecondTableToUseWithoutSpaces: IndexSet? = secondManagerPositions.indexes(in: allTableItemsIndexesRange, options: [], passingTest: {(_ idx: Int, _ stop: Bool) -> Bool in
                    tableSizeForEnumeration += 1
                    tableSizeForEnumeration
                    let result: Bool = idx < tableSizeForEnumeration
                    stop = !result
                    return result
                })
            let countOfElementsFromSecondTableToUseWithoutSpaces: Int? = elementsFromSecondTableToUseWithoutSpaces?.count
            if countOfElementsFromSecondTableToUseWithoutSpaces == secondManagerTableSize {
                _realSecondManagerPositions = secondManagerPositions
            }
            else {
                let mergedSet = IndexSet(indexSet: elementsFromSecondTableToUseWithoutSpaces)
                mergedSet.add(inRange: NSRange(location: firstManagerTableSize + countOfElementsFromSecondTableToUseWithoutSpaces, length: secondManagerTableSize - countOfElementsFromSecondTableToUseWithoutSpaces))
                _realSecondManagerPositions = mergedSet
            }
            return _realSecondManagerPositions
    }
    private var _firstTableSizeCache: Int = 0
    var firstTableSizeCache: Int {
        get {
            return _firstTableSizeCache
        }
        set(firstTableSizeCache) {
            _firstTableSizeCache = firstTableSizeCache
            realSecondManagerPositions = nil
        }
    }

    init(firstManager: JRTableManager, secondManager: JRTableManager, secondManagerPositions: IndexSet) {
        super.init()

        first = firstManager
        second = secondManager
        self.secondManagerPositions = secondManagerPositions
    
    }

// MARK: - Setters

// MARK: - Getters

// MARK: - <UITableViewDataSource>
    func numberOfSections(in tableView: UITableView) -> Int {
        return firstTableSize(withTable: tableView) + realSecondManagerPositions?.count!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index: Int = indexPath.section
        var result: UITableViewCell?
        if isSecondTableIndex(index) {
            let pathInSeconTable: IndexPath? = indexPathFromSecondTable(with: index)
            result = second?.tableView(tableView, cellForRowAt: pathInSeconTable!)
        }
        else {
            let pathInFirstTable: IndexPath? = indexPathFromFirstTable(with: index)
            result = first?.tableView(tableView, cellForRowAt: pathInFirstTable!)
        }
        return result!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var manager: JRTableManager
        var managerSection: Int
        if isSecondTableIndex(section) {
            manager = second
            managerSection = sectionFromSecondTable(withSection: section)
        }
        else {
            manager = first
            managerSection = sectionFromFirstTable(with: section)
        }
        if manager.responds(to: Selector("tableView:heightForHeaderInSection:")) {
            return manager.tableView(tableView, heightForHeaderInSection: managerSection)
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var manager: JRTableManager
        var managerSection: Int
        if isSecondTableIndex(section) {
            manager = second
            managerSection = sectionFromSecondTable(withSection: section)
        }
        else {
            manager = first
            managerSection = sectionFromFirstTable(with: section)
        }
        if manager.responds(to: Selector("tableView:heightForFooterInSection:")) {
            return manager.tableView(tableView, heightForFooterInSection: managerSection)
        }
        else {
            return 0
        }
    }

// MARK: - <UITableViewDelegate>
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let index: Int = indexPath.section
        if isSecondTableIndex(index) {
            return false
        }
        else {
            return true
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index: Int = indexPath.section
        if isSecondTableIndex(index) {
            if second?.responds(to: Selector("tableView:didSelectRowAtIndexPath:")) {
                let pathInSeconTable: IndexPath? = indexPathFromSecondTable(with: index)
                second?.tableView(tableView, didSelectRowAt: pathInSeconTable!)
            }
        }
        else {
            if first?.responds(to: Selector("tableView:didSelectRowAtIndexPath:")) {
                let pathInFirstTable: IndexPath? = indexPathFromFirstTable(with: index)
                first?.tableView(tableView, didSelectRowAt: pathInFirstTable!)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index: Int = indexPath.section
        var result: CGFloat = tableView.rowHeight
        if isSecondTableIndex(index) {
            if second?.responds(to: Selector("tableView:heightForRowAtIndexPath:")) {
                let pathInSeconTable: IndexPath? = indexPathFromSecondTable(with: index)
                result = second?.tableView(tableView, heightForRowAt: pathInSeconTable!)
            }
        }
        else {
            if first?.responds(to: Selector("tableView:heightForRowAtIndexPath:")) {
                let pathInFirstTable: IndexPath? = indexPathFromFirstTable(with: index)
                result = first?.tableView(tableView, heightForRowAt: pathInFirstTable!)
            }
        }
        return result
    }

// MARK: - Private
    func tableManager(at index: Int) -> JRTableManager {
        if isSecondTableIndex(index) {
            return second!
        }
        else {
            return first!
        }
    }

    func isSecondTableIndex(_ index: Int) -> Bool {
        return realSecondManagerPositions?.contains(index)!
    }

    func indexPathFromSecondTable(with index: Int) -> IndexPath {
        let newIndex: Int = sectionFromSecondTable(withSection: index)
        return IndexPath(row: 0, section: newIndex)
    }

    func sectionFromSecondTable(withSection index: Int) -> Int {
        return realSecondManagerPositions?.countOfIndexes(inRange: NSRange(location: 0, length: index))!
    }

    func indexPathFromFirstTable(with index: Int) -> IndexPath {
        let newIndex: Int = sectionFromFirstTable(with: index)
        return IndexPath(row: 0, section: newIndex)
    }

    func sectionFromFirstTable(with index: Int) -> Int {
        return index - realSecondManagerPositions?.countOfIndexes(inRange: NSRange(location: 0, length: index))!
    }

    func firstTableSize(withTable tableView: UITableView) -> Int {
        let firstTableSize: Int? = first?.numberOfSections(in: tableView)
        if firstTableSizeCache != firstTableSize {
            firstTableSizeCache = firstTableSize
        }
        return firstTableSize!
    }
}