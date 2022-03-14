//
//  AppConstants.swift
//  OrgChart
//
//  Created by OGiP on 3/13/22.
//  Copyright © 2022 Park, Chanick. All rights reserved.
//

import UIKit

struct AppConstants {
    // Cell Frame
    static let cellFrame = CGRect(x: 0, y: 0, width: 170, height: 80)
    static let cllIndent: CGFloat = 10
    static let cellNameFont = UIFont(name:"HelveticaNeue", size: 10.0)
    static let cellSubFont = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
    
    // top offset
    static let topOffset: CGFloat = 100
    
    // Zoom Scale
    static let maxScale: CGFloat = 2.0
    static let minScale: CGFloat = 1.0
    
    // Cell Colors
    static let greenColor = UIColor(red: 61 / 255, green: 123 / 255, blue: 99 / 255, alpha: 1.0)
}

// Line connection type
enum LinkType {
    case topBottom
    case leftBottom
}
