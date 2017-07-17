//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  HLHotelDetailsLayout.h
//  HotelLook
//
//  Created by Oleg on 18/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//
//
//  HLHotelDetailsLayout.m
//  HotelLook
//
//  Created by Oleg on 18/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

import UIKit

class HLFixedHeaderPositionLayout: UICollectionViewFlowLayout {
    //- (CGRect)headerFrame
    //{
    //    newHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    //}

    override func collectionViewContentSize() -> CGSize {
        var contentSize: CGSize = super.collectionViewContentSize
        if contentSize.height <= collectionView.bounds?.size?.height {
            contentSize = CGSize(width: contentSize.width, height: collectionView.bounds?.size?.height)
        }
        return contentSize
    }

    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [Any] {
        var result: [Any] = super.layoutAttributesForElements(in: rect)?
        let contentOffset: CGPoint = collectionView.contentOffset
        let attrKinds: [Any] = result.value(forKeyPath: "representedElementKind")
        let indexPath = IndexPath(item: 0, section: 0)
        let delegate: UICollectionViewDelegateFlowLayout? = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)
        let headerSize: CGSize? = delegate?.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: 0)
        let footerSize: CGSize? = delegate?.collectionView(collectionView, layout: self, referenceSizeForFooterInSection: 0)
        if contentOffset.y > 0.0 {
            let headerIndex: Int = (attrKinds as NSArray).index(of: .header)
            var newHeaderAttributes: UICollectionViewLayoutAttributes? = nil
            if headerIndex == NSNotFound {
                newHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: .header, with: indexPath)
                result.append(newHeaderAttributes)
            }
            else {
                newHeaderAttributes = result[headerIndex] as? UICollectionViewLayoutAttributes ?? UICollectionViewLayoutAttributes()
            }
            let frame = CGRect(x: 0.0, y: contentOffset.y, width: headerSize?.width, height: headerSize?.height)
            newHeaderAttributes?.frame = frame
            newHeaderAttributes?.zIndex = 1024.0
        }
        let yLimit: CGFloat? = (collectionViewContentSize().height - collectionView.bounds?.size?.height)
        if (collectionViewContentSize().height > collectionView.bounds?.size?.height) && (contentOffset.y < yLimit) {
            let footerIndex: Int = (attrKinds as NSArray).index(of: .footer)
            var yOffest: CGFloat? = (collectionView.bounds?.size?.height - footerSize?.height)
            if contentOffset.y > 0.0 {
                yOffest += contentOffset.y
            }
            var newFooterAttributes: UICollectionViewLayoutAttributes? = nil
            if footerIndex == NSNotFound {
                newFooterAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: .footer, with: indexPath)
                result.append(newFooterAttributes)
            }
            else {
                newFooterAttributes = result[footerIndex] as? UICollectionViewLayoutAttributes ?? UICollectionViewLayoutAttributes()
            }
            let frame = CGRect(x: 0.0, y: yOffest!, width: footerSize?.width, height: footerSize?.height)
            newFooterAttributes?.frame = frame
            newFooterAttributes?.zIndex = 1024.0
        }
        return result
    }
}