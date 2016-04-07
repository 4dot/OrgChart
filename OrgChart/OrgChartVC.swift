//
//  OrgChartVC.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit

class OrgChartVC: UIViewController, OrgChartCellDelegate {

    var orgChart = OrgChartData.loadOrgChartData("OrgChart")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // save root cell
        if let chartView = self.view as? OrgChartView {
            // create root view
            let cellFrame = CGRect(x: 0, y: 0, width: 150, height: 60)
            let root = createOrgChartCell(cellFrame, root: nil, childData: orgChart)
            root.delegate = self
            root.setCellColor(UIColor(red: 61/255, green: 123/255, blue: 99/255, alpha: 1.0), fontColor: UIColor.whiteColor())
            chartView.scrollView.addSubview(root)
            
            // create first stack view
            let rootStack = OrgChartView.createStackView(.Vertical)
            rootStack.addArrangedSubview(root)
            
            // attach stackview into the OrgChartViewController
            chartView.scrollView.addSubview(rootStack)
            root.myStack = rootStack
            
            // save root cell
            chartView.rootCell = root;
            
            // Position of OrgChart Root StackView
            rootStack.centerXAnchor.constraintEqualToAnchor(chartView.scrollView.centerXAnchor).active = true
            rootStack.topAnchor.constraintEqualToAnchor(chartView.scrollView.topAnchor, constant: 100).active = true
            
            // Add First Children
            addChildren(root, children: self.orgChart.children, frame: cellFrame)
            
            // opened
            root.bottomLink.setImage(UIImage(named: "minus"), forState: .Normal)
        }
    }
    
    // Add Children cell
    func addChildren(root: OrgChartCell?, children:[OrgChartData]?, frame: CGRect) ->Void {
        if children?.count > 0 {
            var willAppendCell = [OrgChartCell]()
            var lineLinkType: LinkType = .LeftBottom
            
            // Create Child Cells
            for child in children! {
                let newCell = createOrgChartCell(frame, root: root, childData: child)
                newCell.delegate = self
                newCell.parent = root
                willAppendCell.append(newCell)
                
                // check end of the tree
                if child.children?.count > 0 {
                    lineLinkType = .TopBottom
                    newCell.bottomLink.hidden = false
                }
                else {
                    newCell.bottomLink.hidden = true
                }
            }
            
            if lineLinkType == .LeftBottom && children?.count <= 1 {
                lineLinkType = .TopBottom
            }
            
            // set child link line type
            root?.childLinkType = lineLinkType
            
            // attach child cell into chartView
            if let chartView = self.view as? OrgChartView {
                chartView.insertChildren(root, children: willAppendCell)
            }
        }
    }
    // create orgchart cell view
    private func createOrgChartCell(frame: CGRect, root: OrgChartCell?, childData: OrgChartData) ->OrgChartCell {
        return OrgChartCell(frame: frame, udid: childData.udid, name: childData.name, position: childData.position, company: childData.company, parent: root)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OrgChartCellDelegate
    func cellExtend(parent:OrgChartCell, udid: String, bExtend: Bool) {
        if parent.childStack != nil {
            UIView.animateWithDuration(0.25, animations: {
                parent.childStack?.hidden = !bExtend
                
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

