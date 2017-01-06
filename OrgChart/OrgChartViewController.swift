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

    // Load Local .Json file
    var orgChart = OrgChartData.loadOrgChartData("OrgChart")
    
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // save root cell
        if let chartView = self.view as? OrgChartView {
            
            // create root view
            
            // default cell size
            let cellFrame = CGRect(x: 0, y: 0, width: 170, height: 80)
            let root = createOrgChartCell(cellFrame, root: nil, childData: orgChart)
            root.delegate = self
            root.setCellColor(UIColor(red: 61/255, green: 123/255, blue: 99/255, alpha: 1.0), fontColor: UIColor.white)
            chartView.scrollView.addSubview(root)
            
            // create first root stack view
            let rootStack = OrgChartView.createStackView(.vertical)
            rootStack.addArrangedSubview(root)
            
            // attach stackview into the OrgChartViewController
            chartView.scrollView.addSubview(rootStack)
            root.myStack = rootStack
            
            // save root cell
            chartView.rootCell = root;
            
            // Position of OrgChart Root StackView
            rootStack.centerXAnchor.constraint(equalTo: chartView.scrollView.centerXAnchor).isActive = true
            rootStack.topAnchor.constraint(equalTo: chartView.scrollView.topAnchor, constant: 100).isActive = true
            
            // Add First Children
            addChildren(root, children: self.orgChart.children, frame: cellFrame)
            
            // set 'opened' button image
            root.bottomLink.setImage(UIImage(named: "minus"), for: UIControlState())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Public Functions
    
    // Add Children cell
    func addChildren(_ root: OrgChartCell?, children:[OrgChartData]?, frame: CGRect) ->Void {
        
        // check children, children's count
        guard let children = children else {
            return
        }
        
        if children.isEmpty {
            return
        }
        
        // append cell list
        var willAppendCell = [OrgChartCell]()
        var lineLinkType: LinkType = .leftBottom
        
        // Create Child Cells
        for child in children {
            
            let newCell = createOrgChartCell(frame, root: root, childData: child)
            newCell.delegate = self
            newCell.parent = root
            willAppendCell.append(newCell)
            
            // check end of the tree
            if child.children.count > 0 {
                lineLinkType = .topBottom
                newCell.bottomLink.isHidden = false
            }
            else {
                newCell.bottomLink.isHidden = true
            }
        }
        
        if lineLinkType == .leftBottom && children.count <= 1 {
            lineLinkType = .topBottom
        }
        
        // set link line type child cell to parent cell
        root?.childLinkType = lineLinkType
        
        // attach child cell into chartView
        if let chartView = self.view as? OrgChartView {
            chartView.insertChildren(root, children: willAppendCell)
        }
    }
    
    // create orgchart cell view
    fileprivate func createOrgChartCell(_ frame: CGRect, root: OrgChartCell?, childData: OrgChartData) ->OrgChartCell {
        return OrgChartCell(frame: frame, userUdid: childData.udid, userName: childData.name, userPosition: childData.position, userCompany: childData.company, userParent: root)
    }
    
    
    
    // MARK: - OrgChartCellDelegate
    
    func cellExtend(_ parent:OrgChartCell, udid: String, bExtend: Bool) {
        if parent.childStack != nil {
            UIView.animate(withDuration: 0.25, animations: {
                parent.childStack?.isHidden = !bExtend
                
                self.view.setNeedsDisplay()
                }, completion: { [unowned self] (finished: Bool) -> Void in
                    // change view size
                    if let chartView = self.view as? OrgChartView {
                        chartView.updateScrollViewSize()
                    }
                })
        }
        else {
            if bExtend == true {
                // find parent
                if let children = self.orgChart.getChildren(self.orgChart, udid: udid) {
                    // extend tree
                    addChildren(parent, children: children, frame: parent.frame)
                }
            }
        }
    }
}

