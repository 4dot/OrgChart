/**
 * OrgChartViewController.swift
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



// Default cell size
// -----------------------------------------------------------
let CELLFRAME = CGRect(x: 0, y: 0, width: 170, height: 80)
//------------------------------------------------------------

//
// OrgChartViewController Class
//
class OrgChartViewController: UIViewController, OrgChartCellDelegate {

    // OrgChart Data, Load local json file
    lazy var orgChart: OrgChartData = {
        OrgChartData.loadOrgChartData("OrgChart")
    }()
    
    
    // OrgChart View
    @IBOutlet var orgChartView: OrgChartView!
    
    
    // MARK: - Override functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Create root cell & root stack view
        
        let rootCell = _createOrgChartCell(CELLFRAME, parent: nil, childData: orgChart)
        rootCell.delegate = self
        rootCell.setCellColor(UIColor(red: 61/255, green: 123/255, blue: 99/255, alpha: 1.0), fontColor: UIColor.white) // green color
        
        orgChartView.scrollView.addSubview(rootCell)
        
        // Create root stack view
        let rootStack = OrgChartView.createStackView(.vertical)
        rootStack.addArrangedSubview(rootCell)
        
        // Attach stackview into the OrgChartViewController
        orgChartView.scrollView.addSubview(rootStack)
        rootCell.myStack = rootStack
        
        // Save reference to root cell
        orgChartView.rootCell = rootCell;
        
        // Set position of OrgChart Root StackView
        rootStack.centerXAnchor.constraint(equalTo: orgChartView.scrollView.centerXAnchor).isActive = true
        rootStack.topAnchor.constraint(equalTo: orgChartView.scrollView.topAnchor, constant: 100).isActive = true
        
        // Add First Children
        addChildren(rootCell, children: orgChart.children, frame: CELLFRAME)
        
        // Set button image
        rootCell.bottomLink.setImage(UIImage(named: "minus"), for: .normal)
    }
    
    // MARK: - Public Functions
    
    // Add Children cell
    func addChildren(_ parent: OrgChartCell?, children:[OrgChartData]?, frame: CGRect) ->Void {
        
        // Check children, chartView type
        guard let children = children,
            children.isEmpty == false else {
            return
        }
        
        // Insert cells to chartView
        var willAppendCell: [OrgChartCell] = []
        
        // default line type
        var lineLinkType: LinkType = .leftBottom
        
        // Create Child Cells
        for child in children {
            
            let newCell = _createOrgChartCell(frame, parent: parent, childData: child)
            newCell.delegate = self
            willAppendCell.append(newCell)
            
            if child.children.isEmpty == false {
                // line type
                lineLinkType = .topBottom
                newCell.bottomLink.isHidden = false
            }
            else {
                // Hide Botton Link Button if End of the tree
                newCell.bottomLink.isHidden = true
            }
        }
        
        // Change Line type to [.topBottom] if appended cell has just one child
        if lineLinkType == .leftBottom && children.count <= 1 {
            lineLinkType = .topBottom
        }
        
        // Set link line type for connection line draw
        parent?.childLinkType = lineLinkType
        
        // Attach child cell into chartView
        orgChartView.insertChildren(parent, children: willAppendCell)
    }
    
    // MARK: - Private functions
    
    // Create orgchart cell view
    private func _createOrgChartCell(_ frame: CGRect, parent: OrgChartCell?, childData: OrgChartData) ->OrgChartCell {
        
        return OrgChartCell(frame: frame,
                            userUdid: childData.udid,
                            userName: childData.name,
                            userPosition: childData.position,
                            userCompany: childData.company,
                            userParent: parent)
    }
}

//
// OrgChartViewController extension for OrgChartCellDelegate Protocol
//
extension OrgChartViewController {
    
    // MARK: - OrgChartCellDelegate
    
    func cellExtend(_ parent:OrgChartCell, udid: String, bExtend: Bool) {
        
        if parent.childStack == nil {
            if bExtend == true {
                
                // Find parent
                if let children = orgChart.getChildren(orgChart, udid: udid) {
                    
                    // Extend tree, Add Child cells
                    addChildren(parent, children: children, frame: parent.frame)
                }
            }
        } else {
            
            // Extend OrgChart with Animation
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                parent.childStack?.isHidden = !bExtend
                
                // Update display
                strongSelf.view.setNeedsDisplay()
                
            }, completion: { [weak self] (finished: Bool) -> Void in
                
                // Update view size
                self?.orgChartView.updateScrollViewSize()
            })
        }
    }
}


