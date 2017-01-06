//
//  OrgChartLayout.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/17/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit

protocol OrgChartLayoutDelegate {
    func sizeOfItemAtIndexPath(_ indexPath: IndexPath) -> CGSize
}

class OrgChartLayout: UICollectionViewLayout {
    
    var delegate: OrgChartLayoutDelegate?
    var sectionCount = 0
    var itemCounts: [Int] = []
    var contentSize = CGSize.zero
    var sizes: [[CGSize]] = []
    var rects: [[CGRect]] = []
    
    var rowHeights: [CGFloat] = []
    var columnWidths: [CGFloat] = []
    
    
    override func prepare() {
        super.prepare()
        
        sectionCount = collectionView!.numberOfSections
        itemCounts = []
        
        sizes = []
        rowHeights = []
        columnWidths = []
        for section in 0..<sectionCount {
            let numberOfItems = collectionView!.numberOfItems(inSection: section)
            itemCounts.append(numberOfItems)
            
            rowHeights.append(0)
            
            var sectionSizes: [CGSize] = []
            for item in 0..<numberOfItems {
                if item >= columnWidths.count {
                    columnWidths.append(0)
                }
                
                let size = delegate?.sizeOfItemAtIndexPath(IndexPath(item: item, section: section)) ?? CGSize.zero
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
                let rect = CGRect(x: width, y: height, width: columnWidths[item], height: rowHeights[section])
                sectionRects.append(rect)
                width += columnWidths[item]
            }
            rects.append(sectionRects)
            height += rowHeights[section]
        }
        contentSize = CGSize(width: width, height: height)
    }
    
    override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = rects[indexPath.section][indexPath.item]
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        
        for section in 0..<rects.count {
            for item in 0..<rects[section].count {
                if rect.intersects(rects[section][item]) {
                    attributes.append(layoutAttributesForItem(at: IndexPath(item: item, section: section))!)
                }
            }
        }
        return attributes
    }
    
}
