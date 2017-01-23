//
//  OrgChartData.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit


//
// OrgChart Data Model class
//

class OrgChartData : Equatable, Hashable {
    
    // MARK: - Member variables
    
    var udid: String
    var name: String
    var position: String?
    var company: String?
    var children: [OrgChartData] = []
    
    // for compare
    var hashValue: Int {
        get {
            return udid.hashValue
        }
    }
    
    // MARK: compare functions
    
    static func == (lhs: OrgChartData, rhs: OrgChartData) -> Bool {
        return lhs.udid == rhs.udid
    }
    
    // MARK: - Class (Static) function
    
    class func loadOrgChartData(_ fileName: String) -> OrgChartData! {
        
        // Load json data from local resource
        
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")
        let data = try? Data(contentsOf: url!)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            
            // Load Root Cell's data
            let udid = json["udid"] as? String
            let name = json["name"] as? String
            let company = json["company"] as? String
            let position = json["position"] as? String
            let children = json["children"] as? [[String: AnyObject]]
            
            // Create chart data
            return OrgChartData(udid: udid!, name: name!, position: position, company: company, children: children)
            
        } catch {
            print("Error serializing JSON: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Init
    
    init(udid: String, name: String, position: String?, company: String?, children: [[String: AnyObject]]?) {
        
        // Init
        self.udid = udid
        self.name = name
        self.position = position ?? ""
        self.company = company ?? ""
        self.children = []
        
        // Load Children
        if let children = children {
            for child in children {
                addChild(self, dictionary: child as NSDictionary)
            }
        }
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let udid = (dictionary["udid"] as? String) ?? ""
        let name = dictionary["name"] as? String ?? ""
        let position = dictionary["position"] as? String
        let company = dictionary["company"] as? String
        let children = dictionary["children"] as? [[String: AnyObject]]
        
        self.init(udid: udid, name: name, position: position, company: company, children: children)
    }
    
    // MARK: - Public functions
    
    func addChild(_ parent:OrgChartData, dictionary:NSDictionary) {
        
        // Create ChildData
        let childData = OrgChartData(dictionary: dictionary)
        parent.children.append(childData)
    }
    
    // Find target's children recursively
    func getChildren(_ root:OrgChartData, udid:String) ->[OrgChartData]? {
        
        if root.udid == udid {
            return root.children
        }
        
        for child in root.children {
            if let children:[OrgChartData] = getChildren(child, udid: udid) {
                return children
            }
        }
        
        return nil
    }
}


