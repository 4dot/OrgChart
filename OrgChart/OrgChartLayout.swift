//
//  OrgChartLayout.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/17/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit

protocol OrgChartLayoutDelegate {
    func sizeOfItemAtIndexPath(indexPath: NSIndexPath) -> CGSize
}

class OrgChartLayout: UICollectionViewLayout {
    
    var delegate: OrgChartLayoutDelegate?
    var sectionCount = 0
    var itemCounts: [Int] = []
    var contentSize = CGSizeZero
    var sizes: [[CGSize]] = []
    var rects: [[CGRect]] = []
    
    var rowHeights: [CGFloat] = []
    var columnWidths: [CGFloat] = []
    
    
    override func prepareLayout() {
        super.prepareLayout()
        
        sectionCount = collectionView!.numberOfSections()
        itemCounts = []
        
        sizes = []
        rowHeights = []
        columnWidths = []
        for section in 0..<sectionCount {
            let numberOfItems = collectionView!.numberOfItemsInSection(section)
            itemCounts.append(numberOfItems)
            
            rowHeights.append(0)
            
            var sectionSizes: [CGSize] = []
            for item in 0..<numberOfItems {
                if item >= columnWidths.count {
                    columnWidths.append(0)
                }
                
                let size = delegate?.sizeOfItemAtIndexPath(NSIndexPath(forItem: item, inSection: section)) ?? CGSizeZero
                sectionSizes.append(size)
                rowHeights[section] = max(rowHeights[section], size.height)
                columnWidths[item] = max(columnWidths[item], size.width)
            }
            sizes.append(sectionSizes)
        }
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        rects = []
        for section in 0..<sectionCount {
            let numberOfItems = itemCounts[section]
            
            width = 0
            var sectionRects : [CGRect] = []
            for item in 0..<numberOfItems {
                let rect = CGRectMake(width, height, columnWidths[item], rowHeights[section])
                sectionRects.append(rect)
                width += columnWidths[item]
            }
            rects.append(sectionRects)
            height += rowHeights[section]
        }
        contentSize = CGSizeMake(width, height)
    }
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return false
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = rects[indexPath.section][indexPath.item]
        
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        
        for section in 0..<rects.count {
            for item in 0..<rects[section].count {
                if CGRectIntersectsRect(rect, rects[section][item]) {
                    attributes.append(layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: section))!)
                }
            }
        }
        return attributes
    }
    
}