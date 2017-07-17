//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  HLCollectionViewFlowLayoutCenterItem.swift
//  HotelLook
//
//  Created by Evgeny Petrov on 10.12.15.
//  Copyright © 2015 Anton Chebotov. All rights reserved.
//

import UIKit

class HLCollectionViewFlowLayoutCenterItem: UICollectionViewFlowLayout {
    func collectionViewContentSize() -> CGSize {
            // Only support single section for now.
            // Only support Horizontal scroll
        let count: Int? = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0)
        let canvasSize: CGSize? = collectionView.frame?.size
        var contentSize: CGSize? = canvasSize
        if scrollDirection == .horizontal {
            let rowCount: Int? = (canvasSize?.height - itemSize.height) / (itemSize.height + minimumInteritemSpacing) + 1
            let columnCount: Int? = (canvasSize?.width - itemSize.width) / (itemSize.width + minimumLineSpacing) + 1
            let page: Int = ceilf(CGFloat(count) / (CGFloat)(rowCount * columnCount))
            contentSize?.width = page * canvasSize?.width
        }
        return contentSize!
    }

    func frameForItem(at indexPath: IndexPath) -> CGRect {
        let canvasSize: CGSize? = collectionView.frame?.size
        let rowCount: Int? = (canvasSize?.height - itemSize.height) / (itemSize.height + minimumInteritemSpacing) + 1
        let columnCount: Int? = (canvasSize?.width - itemSize.width) / (itemSize.width + minimumLineSpacing) + 1
        let pageMarginX: CGFloat? = (canvasSize?.width - columnCount * itemSize.width - (columnCount > 1 ? (columnCount - 1) * minimumLineSpacing : 0)) / 2.0
        let pageMarginY: CGFloat? = (canvasSize?.height - rowCount * itemSize.height - (rowCount > 1 ? (rowCount - 1) * minimumInteritemSpacing : 0)) / 2.0
        let page: Int = indexPath.row / (rowCount * columnCount)
        let remainder: Int = indexPath.row - page * (rowCount * columnCount)
        let row: Int = remainder / columnCount
        let column: Int = remainder - row * columnCount
        let cellFrame = CGRect.zero
        cellFrame.origin.x = pageMarginX + column * (itemSize.width + minimumLineSpacing)
        cellFrame.origin.y = pageMarginY + row * (itemSize.height + minimumInteritemSpacing)
        cellFrame.size.width = itemSize.width
        cellFrame.size.height = itemSize.height
        if scrollDirection == .horizontal {
            cellFrame.origin.x += page * canvasSize?.width
        }
        return cellFrame
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attr: UICollectionViewLayoutAttributes? = super.layoutAttributesForItem(at: indexPath)
        attr?.frame = frameForItem(at: indexPath)
        return attr!
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [Any] {
        let originAttrs: [Any]? = super.layoutAttributesForElements(in: rect)
        var attrs = [Any]()
        (originAttrs? as NSArray).enumerateObjects(usingBlock: {(_ attr: UICollectionViewLayoutAttributes, _ idx: Int, _ stop: Bool) -> Void in
            let idxPath: IndexPath? = attr?.indexPath
            let itemFrame: CGRect = self.frameForItem(at: idxPath)
            if itemFrame.intersects(rect) {
                attr = self.layoutAttributesForItem(at: idxPath!)
                attrs.append(attr)
            }
        })
        return attrs
    }
}