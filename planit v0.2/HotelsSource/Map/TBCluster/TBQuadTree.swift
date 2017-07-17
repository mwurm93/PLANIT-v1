//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  TBQuadTree.swift
//  TBQuadTree
//
//  Created by Theodore Calmes on 9/19/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

import Foundation
import MapKit

struct TBQuadTreeNodeData {
    var x: Double = 0.0
    var y: Double = 0.0
    var data: UnsafePointer<Void>
}
typealias TBQuadTreeNodeData = TBQuadTreeNodeData
struct TBBoundingBox {
    var x0: Double = 0.0
    var y0: Double = 0.0
    var xf: Double = 0.0
    var yf: Double = 0.0
}
typealias TBBoundingBox = TBBoundingBox
struct quadTreeNode {
    var northWest: quadTreeNode?
    var northEast: quadTreeNode?
    var southWest: quadTreeNode?
    var southEast: quadTreeNode?
    var boundingBox: TBBoundingBox = TBBoundingBox()
    var bucketCapacity: Int = 0
    var points: TBQuadTreeNodeData?
    var count: Int = 0
}
typealias TBQuadTreeNode = quadTreeNode
typealias TBQuadTreeTraverseBlock = (_ currentNode: TBQuadTreeNode) -> Void
typealias TBDataReturnBlock = (_ data: TBQuadTreeNodeData) -> Void

func TBQuadTreeNodeDataMake(x: Double, y: Double, data: Void) -> TBQuadTreeNodeData {
    var d: TBQuadTreeNodeData
    d.x = x
    d.y = y
    d.data = data
    return d
}

func TBBoundingBoxMake(x0: Double, y0: Double, xf: Double, yf: Double) -> TBBoundingBox {
    let bb: TBBoundingBox
    bb.x0 = x0
    bb.y0 = y0
    bb.xf = xf
    bb.yf = yf
    return bb
}

func TBQuadTreeNodeMake(boundary: TBBoundingBox, bucketCapacity: Int) -> TBQuadTreeNode {
    let node: TBQuadTreeNode? = malloc(MemoryLayout<TBQuadTreeNode>.size)
    node?.northWest = nil
    node?.northEast = nil
    node?.southWest = nil
    node?.southEast = nil
    node?.boundingBox = boundary
    node?.bucketCapacity = bucketCapacity
    node?.count = 0
    node?.points = malloc(MemoryLayout<TBQuadTreeNodeData>.size * bucketCapacity)
    return node!
}

func TBFreeQuadTreeNode(node: TBQuadTreeNode) {
    if node.northWest != nil {
        TBFreeQuadTreeNode(node.northWest)
    }
    if node.northEast != nil {
        TBFreeQuadTreeNode(node.northEast)
    }
    if node.southWest != nil {
        TBFreeQuadTreeNode(node.southWest)
    }
    if node.southEast != nil {
        TBFreeQuadTreeNode(node.southEast)
    }
    for i in 0..<node.count {
        free(node.points()[i].data)
    }
    free(node.points())
    free(node)
}

func TBBoundingBoxContainsData(box: TBBoundingBox, data: TBQuadTreeNodeData) -> Bool {
    let containsX: Bool = box.x0 <= data.x && data.x <= box.xf
    let containsY: Bool = box.y0 <= data.y && data.y <= box.yf
    return containsX && containsY
}

func TBBoundingBoxIntersectsBoundingBox(b1: TBBoundingBox, b2: TBBoundingBox) -> Bool {
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0)
}

func TBQuadTreeTraverse(node: TBQuadTreeNode, block: TBQuadTreeTraverseBlock) {
    block(node)
    if node.northWest == nil {
        return
    }
    TBQuadTreeTraverse(node.northWest, block)
    TBQuadTreeTraverse(node.northEast, block)
    TBQuadTreeTraverse(node.southWest, block)
    TBQuadTreeTraverse(node.southEast, block)
}

func TBQuadTreeGatherDataInRange(node: TBQuadTreeNode, range: TBBoundingBox, block: TBDataReturnBlock) {
    if !TBBoundingBoxIntersectsBoundingBox(node.boundingBox, range) {
        return
    }
    for i in 0..<node.count {
        if TBBoundingBoxContainsData(range, node.points()[i]) {
            block(node.points()[i])
        }
    }
    if node.northWest == nil {
        return
    }
    TBQuadTreeGatherDataInRange(node.northWest, range, block)
    TBQuadTreeGatherDataInRange(node.northEast, range, block)
    TBQuadTreeGatherDataInRange(node.southWest, range, block)
    TBQuadTreeGatherDataInRange(node.southEast, range, block)
}

func TBQuadTreeNodeInsertData(node: TBQuadTreeNode, data: TBQuadTreeNodeData) -> Bool {
    if !TBBoundingBoxContainsData(node.boundingBox, data) {
        return false
    }
    if node.count < node.bucketCapacity {
        node.points[node.count] = data
        node.count += 1
        return true
    }
    node.count += 1
    if node.northWest == nil {
        TBQuadTreeNodeSubdivide(node)
    }
    if TBQuadTreeNodeInsertData(node.northWest, data) {
        return true
    }
    if TBQuadTreeNodeInsertData(node.northEast, data) {
        return true
    }
    if TBQuadTreeNodeInsertData(node.southWest, data) {
        return true
    }
    if TBQuadTreeNodeInsertData(node.southEast, data) {
        return true
    }
    return false
}

func TBQuadTreeBuildWithData(data: TBQuadTreeNodeData, count: Int, boundingBox: TBBoundingBox, capacity: Int) -> TBQuadTreeNode {
    let root: TBQuadTreeNode? = TBQuadTreeNodeMake(boundingBox, capacity)
    for i in 0..<count {
        TBQuadTreeNodeInsertData(root, data[i])
    }
    return root!
}

// MARK: - Constructors

// MARK: - Bounding Box Functions

// MARK: - Quad Tree Functions
private func TBQuadTreeNodeSubdivide(node: TBQuadTreeNode) {
    let box: TBBoundingBox = node.boundingBox
    let xMid: Double = (box.xf + box.x0) / 2.0
    let yMid: Double = (box.yf + box.y0) / 2.0
    let northWest: TBBoundingBox = TBBoundingBoxMake(box.x0, box.y0, xMid, yMid)
    node.northWest = TBQuadTreeNodeMake(northWest, node.bucketCapacity)
    let northEast: TBBoundingBox = TBBoundingBoxMake(xMid, box.y0, box.xf, yMid)
    node.northEast = TBQuadTreeNodeMake(northEast, node.bucketCapacity)
    let southWest: TBBoundingBox = TBBoundingBoxMake(box.x0, yMid, xMid, box.yf)
    node.southWest = TBQuadTreeNodeMake(southWest, node.bucketCapacity)
    let southEast: TBBoundingBox = TBBoundingBoxMake(xMid, yMid, box.xf, box.yf)
    node.southEast = TBQuadTreeNodeMake(southEast, node.bucketCapacity)
}