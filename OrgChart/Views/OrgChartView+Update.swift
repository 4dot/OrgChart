//
//  OrgChartView+Update.swift
//  OrgChart
//
//  Created by OGiP on 3/17/22.
//  Copyright © 2022 Park, Chanick. All rights reserved.
//

import UIKit


extension OrgChartView {
    
    // Create orgchart cell view
    func createOrgChartCell(_ frame: CGRect, parent: OrgChartCell?, chartData: OrgChartModel?) -> OrgChartCell? {
        guard let chartData = chartData else {
            UIAlertController.notifyAlert(nil, title: "Error", message: "Can't load json file.")
            return nil
        }
        return OrgChartCell(frame: frame,
                            udid: chartData.udid,
                            name: chartData.name,
                            position: chartData.position,
                            company: chartData.company,
                            parent: parent)
    }
    
    // Add Children cell
    func addChildren(_ parent: OrgChartCell?, children: [OrgChartModel], frame: CGRect) {
        // Check children, chartView type
        guard !children.isEmpty else {
            return
        }
        
        // Insert cells to chartView
        var willAppendCell = [OrgChartCell]()
        
        // default reporting line type
        var lineLinkType: LinkType = .leftBottom
        
        // Create Child Cells
        for child in children {
            guard let newCell = createOrgChartCell(frame, parent: parent, chartData: child) else {
                continue
            }
            
            newCell.delegate = self
            
            // Show/Hide Expand Button
            newCell.bottomLinkBtn.isHidden = child.children.isEmpty
            
            if !child.children.isEmpty {
                // line type
                lineLinkType = .topBottom
                newCell.bottomLinkBtn.isHidden = false
            }
            else {
                // Hide Botton Link Button if End of the tree
                newCell.bottomLinkBtn.isHidden = true
            }
            
            willAppendCell.append(newCell)
        }
        
        // Change Line type to [.topBottom] if appended cell has just one child
        if lineLinkType == .leftBottom && children.count <= 1 {
            lineLinkType = .topBottom
        }
        
        // Set link line type for connection line draw
        parent?.childLinkType = lineLinkType
        
        // Attach children cell into chartView
        insertChildren(parent, children: willAppendCell)
    }
    
    
    
    // insert children cells
    func insertChildren(_ parent: OrgChartCell?, children: [OrgChartCell]) {
        guard let parent = parent else {
            return
        }
        
        // create default stackview
        let axis: NSLayoutConstraint.Axis = (children.count > 1 && parent.childLinkType == .topBottom) ? .horizontal : .vertical
        let stackView = OrgChartView.createStackView(axis)
        
        // Insert Children Cells to ScrollView
        for (index, child) in children.enumerated() {
            
            // save reference
            orgChartCells.append(child)
            
            child.myStack = stackView
            
            // add child cell
            stackView.addArrangedSubview(child)
            child.stackIndex = index
        }
        
        var targetStack: UIStackView?
        
        // Child cell only insert to vertical stack
        if(parent.myStack.axis == .horizontal) {
            let vertStackView = OrgChartView.createStackView(.vertical)
            scrollView.addSubview(vertStackView)
            
            parent.myStack.insertArrangedSubview(vertStackView, at: parent.stackIndex)
            
            // remove parent from prev stackview and insert new stackview
            parent.myStack.removeArrangedSubview(parent)
            parent.myStack = vertStackView
            
            vertStackView.addArrangedSubview(parent)
            vertStackView.addArrangedSubview(stackView)
            
            // target stack for update
            targetStack = vertStackView
        }
        else {
            // Direct insert Child Cell to parent vertical stack view
            // insert stackview to parent's stackview
            parent.myStack.insertArrangedSubview(stackView, at: parent.myStack.arrangedSubviews.count)
            
            // target stack for update
            targetStack = parent.myStack
        }
        
        // save children's stackview
        parent.childStack = stackView
        
        // Adding animation
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            // update UI
            targetStack!.layoutIfNeeded()
            
            self.setNeedsDisplay()
        }, completion: { [unowned self] finished in
            // update view size
            self.updateScrollViewSize()
        })
    }
}

//
// MARK: - Utils
//
extension OrgChartView {
    // create default stackview
    class func createStackView(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.distribution = .fill
        stackView.alignment = (axis == .vertical) ? .center : .top
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.clipsToBounds = false
        
        return stackView
    }
}
