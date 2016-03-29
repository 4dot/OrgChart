//
//  OrgChartData.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit



// MARK: - OrgChartData
class OrgChartData {
    
    class func loadOrgChartData(fileName: String) -> OrgChartData {
        
        var OrgChart:OrgChartData?
        
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            
            // Load Root
            let udid = json["udid"] as? String
            let name = json["name"] as? String
            let company = json["company"] as? String
            let position = json["position"] as? String
            let children = json["children"] as? [[String: AnyObject]]
            
            OrgChart = OrgChartData(udid: udid!, name: name!, position: position, company: company, children: children)
            
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        return OrgChart!
    }
    
    var udid: String
    var name: String
    var position: String?
    var company: String?
    var children: [OrgChartData]?
    
    
    init(udid: String, name: String, position: String?, company: String?, children: [AnyObject]?) {
        self.udid = udid
        self.name = name
        self.position = position ?? ""
        self.company = company ?? ""
        self.children = nil
        
        // Load Children
        if let children = children as? [[String: AnyObject]] {
            self.children = []
            for child in children {
                addChild(self, dictionary: child)
            }
        }
    }
    
    convenience init(dictionary: NSDictionary) {
        let udid = dictionary["udid"] as? String
        let name = dictionary["name"] as? String
        let position = dictionary["position"] as? String
        let company = dictionary["company"] as? String
        let children = dictionary["children"] as? [AnyObject]
        
        self.init(udid: udid!, name: name!, position: position, company: company, children: children)
    }
    
    func addChild(parent:OrgChartData, dictionary:NSDictionary) {
        let childData = OrgChartData(dictionary: dictionary)
        parent.children?.append(childData)
    }
    
    func getChildren(root:OrgChartData, udid:String) ->[OrgChartData]? {
        if root.udid == udid {
            return root.children
        }
        
        if let children = root.children {
            for child in children {
                let children:[OrgChartData]? = getChildren(child, udid: udid)
                if children != nil {
                    return children
                }
            }
        }
        
        return nil
    }
}


