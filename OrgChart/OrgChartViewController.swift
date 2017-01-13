//
//  OrgChartViewController.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit



//
// OrgChartViewController Class
//
class OrgChartViewController: UIViewController, OrgChartCellDelegate {

    // Load from Local .Json file
    private var _orgChart: OrgChartData!
        
    
    
    
    // MARK: - Override functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load .Json file
        do {
            let _orgChart = try OrgChartData.loadOrgChartData("OrgChart")
        } catch {
            print("Error loadOrgChartData JSON: \(error)")
        }
        
        
        // Create root cell & root stack view
        
        if let chartView = self.view as? OrgChartView {
            
            // Default cell size -----------------------------------------
            let cellFrame = CGRect(x: 0, y: 0, width: 170, height: 80)
            //------------------------------------------------------------
            
            let rootCell = createOrgChartCell(cellFrame, root: nil, childData: _orgChart)
            rootCell.delegate = self
            rootCell.setCellColor(UIColor(red: 61/255, green: 123/255, blue: 99/255, alpha: 1.0), fontColor: UIColor.white) // green color
            
            chartView._scrollView.addSubview(rootCell)
            
            // Create root stack view
            let rootStack = OrgChartView.createStackView(.vertical)
            rootStack.addArrangedSubview(rootCell)
            
            // Attach stackview into the OrgChartViewController
            chartView._scrollView.addSubview(rootStack)
            rootCell.myStack = rootStack
            
            // Save reference root cell
            chartView._rootCell = rootCell;
            
            // Set position of OrgChart Root StackView
            rootStack.centerXAnchor.constraint(equalTo: chartView._scrollView.centerXAnchor).isActive = true
            rootStack.topAnchor.constraint(equalTo: chartView._scrollView.topAnchor, constant: 100).isActive = true
            
            // Add First Children
            addChildren(rootCell, children: _orgChart.children, frame: cellFrame)
            
            // Set button image
            rootCell.bottomLink.setImage(UIImage(named: "minus"), for: .normal)
        }
    }
    
    // MARK: - Public Functions
    
    // Add Children cell
    func addChildren(_ root: OrgChartCell?, children:[OrgChartData]?, frame: CGRect) ->Void {
        
        // Check children, chartView type
        guard let children = children,
            let chartView = self.view as? OrgChartView,
            children.isEmpty else {
            return
        }
        
        // Insert cells to chartView
        var willAppendCell: [OrgChartCell] = []
        var lineLinkType: LinkType = .leftBottom
        
        // Create Children Cells
        for child in children {
            
            let newCell = createOrgChartCell(frame, root: root, childData: child)
            newCell.delegate = self
            newCell.parent = root
            willAppendCell.append(newCell)
            
            // Hide Botton Link Button if End of the tree
            if child.children.count > 0 {
                lineLinkType = .topBottom
                newCell.bottomLink.isHidden = false
            }
            else {
                newCell.bottomLink.isHidden = true
            }
        }
        
        // Line type is [.topBottom] if append cell has one child
        if lineLinkType == .leftBottom && children.count <= 1 {
            lineLinkType = .topBottom
        }
        
        // Set link line type for connection line draw
        root?.childLinkType = lineLinkType
        
        // Attach child cell into chartView
        chartView.insertChildren(root, children: willAppendCell)
    }
    
    // MARK: - Private functions
    
    // Create orgchart cell view
    private func createOrgChartCell(_ frame: CGRect, root: OrgChartCell?, childData: OrgChartData) ->OrgChartCell {
        return OrgChartCell(frame: frame, userUdid: childData.udid, userName: childData.name, userPosition: childData.position, userCompany: childData.company, userParent: root)
    }
}

//
// OrgChartViewController extension for OrgChartCellDelegate Protocol
//
extension OrgChartViewController {
    
    // MARK: - OrgChartCellDelegate
    
    func cellExtend(_ parent:OrgChartCell, udid: String, bExtend: Bool) {
        
        if parent.childStack != nil {
            
            // StackView Animation
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                parent.childStack?.isHidden = !bExtend
                
                // Update
                strongSelf.view.setNeedsDisplay()
                
            }, completion: { [weak self] (finished: Bool) -> Void in
                
                // Check viewType
                guard let strongSelf = self,
                      let chartView = strongSelf.view as? OrgChartView else {
                    return
                }
                
                // Update view size
                chartView.updateScrollViewSize()
            })
        }
        else {
            if bExtend == true {
                
                // Find parent
                if let children = _orgChart.getChildren(_orgChart, udid: udid) {
                    
                    // Extend tree
                    addChildren(parent, children: children, frame: parent.frame)
                }
            }
        }
    }
}


