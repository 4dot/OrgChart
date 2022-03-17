/**
 * OrgChartModel.swift
 * OrgChart
 *
 * Created by Park, Chanick on 1/13/17.
 * Copyright © 2016 Park, Chanick. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit


//
// OrgChart Data Model class
//

struct OrgChartModel : Codable {
    
    // MARK: - Member variables
    
    var udid: String
    var name: String
    var position: String?
    var company: String?
    var children: [OrgChartModel] = []
    
    
    // MARK: - compare functions
    
    static func == (lhs: OrgChartModel, rhs: OrgChartModel) -> Bool {
        return lhs.udid == rhs.udid
    }
    
    // MARK: - Init
    
//    init(udid: String, name: String, position: String?, company: String?, children: [[String: AnyObject]]?) {
//
//        // Init
//        self.udid = udid
//        self.name = name
//        self.position = position ?? ""
//        self.company = company ?? ""
//        self.children = []
//
//        // Load Children
//        if let children = children {
//            for child in children {
//                addChild(self, dictionary: child)
//            }
//        }
//    }
    
//    convenience init(dictionary: [String: AnyObject]) {
//
//        let udid = (dictionary["udid"] as? String) ?? ""
//        let name = dictionary["name"] as? String ?? ""
//        let position = dictionary["position"] as? String
//        let company = dictionary["company"] as? String
//        let children = dictionary["children"] as? [[String: AnyObject]]
//
//        self.init(udid: udid, name: name, position: position, company: company, children: children)
//    }
    
    // MARK: - Public functions
    
//    private func addChild(_ parent: OrgChartModel, dictionary: [String: AnyObject]) {
//
//        // Create ChildData
//        let childData = OrgChartModel(dictionary: dictionary)
//        parent.children.append(childData)
//    }
    
    // Find target's children recursively
    func getChildren(_ parent: OrgChartModel, udid: String) -> [OrgChartModel]? {
        
        if parent.udid == udid {
            return parent.children
        }
        
        for child in parent.children {
            if let children = getChildren(child, udid: udid) {
                return children
            }
        }
        
        return nil
    }
    
    // Find target's children recursively
    func getChildren(udid: String) -> [OrgChartModel]? {
        if self.udid == udid {
            return self.children
        }
        
        var queue = [self]
        while !queue.isEmpty {
            let curr = queue.removeFirst()
            for child in curr.children {
                if child.udid == udid {
                    return child.children
                }
                queue.append(child)
            }
        }
        
        return nil
    }
}

//extension OrgChartModel : Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(udid)
//    }
//}

//extension OrgChartModel {
//
//    // MARK: - Class function
//
//    enum DataError : Error {
//        case FileError
//        case ConvertError
//    }
//
//    class func loadOrgChartData(_ fileName: String) -> OrgChartModel? {
//        // Load json data from local resource
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
//            print("Error: can't find file. \(fileName)")
//            return nil
//        }
//        do {
//            let data = try Data(contentsOf: url)
//            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
//
//            // Load Root cell data
//            let udid = json["udid"] as? String
//            let name = json["name"] as? String
//            let company = json["company"] as? String
//            let position = json["position"] as? String
//            let children = json["children"] as? [[String : AnyObject]]
//
//            // Create chart data
//            return OrgChartModel(udid: udid!, name: name!, position: position, company: company, children: children)
//
//        } catch DataError.FileError {
//            print("Error: fileData")
//            return nil
//        } catch DataError.ConvertError {
//            print("Error: serializing JSON")
//            return nil
//        } catch {
//            print("Error: \(error)")
//        }
//
//        return nil
//    }
//}