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

//
// OrgChartViewController Class
//
class OrgChartViewController: UIViewController {

    // Load Chat Data from local json
    var chartViewModel: OrgChartViewModel!
    
    // OrgChart View
    @IBOutlet var orgChartView: OrgChartView!
    
    
    
    
    
    
    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        
        // Error: view is not in the window hierarchy
        // initChartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initChartView()
    }
    
    // MARK: - Private
    
    private func config() {
        // Create ViewModel
        chartViewModel = OrgChartViewModel()
        
        // Bind Chart Updater
        chartViewModel.bindChartUpdater = { [unowned self] in
            self.updateChartView()
        }
    }
    
    private func initChartView() {
        // Fatch OrgChart Data
        chartViewModel.fatchOrgChart()
        
        
//        guard let rootCell = createOrgChartCell(AppConstants.cellFrame, parent: nil, childData: orgChart) else {
//            UIAlertController.notifyAlert(self, title: "Error", message: "Can't load json file.")
//            return
//        }
//
//        // Create root cell & root stack view
//        rootCell.delegate = self
//        rootCell.setCellColor(AppConstants.greenColor, fontColor: UIColor.white)
//        orgChartView.scrollView.addSubview(rootCell)
//
//        // Create root stack view
//        let rootStack = OrgChartView.createStackView(.vertical)
//        rootStack.addArrangedSubview(rootCell)
//
//        // Attach stackview into the OrgChartViewController
//        orgChartView.scrollView.addSubview(rootStack)
//        rootCell.myStack = rootStack
//
//        // Save reference to root cell
//        orgChartView.rootCell = rootCell
//
//        // Set position of OrgChart Root StackView
//        NSLayoutConstraint.activate([
//            rootStack.centerXAnchor.constraint(equalTo: orgChartView.scrollView.centerXAnchor),
//            rootStack.topAnchor.constraint(equalTo: orgChartView.scrollView.topAnchor, constant: AppConstants.topOffset)
//        ])
//
//        // Add First Children
//        addChildren(rootCell, children: orgChart.children, frame: AppConstants.cellFrame)
//
//        // Set button image
//        rootCell.bottomLink.setImage(UIImage(named: "minus"), for: .normal)
    }
    
    func updateChartView() {
        // Reset & Create
        orgChartView.createChart(chartViewModel.chartData)
    }
}

// MARK: - OrgChartCellDelegate
//extension OrgChartViewController : OrgChartCellDelegate {
//    func cellExpand(_ parent: OrgChartCell, udid: String, isExpand: Bool) {
//        if parent.childStack == nil {
//            if isExpand {
//                // Find parent
//                if let children = orgChart.getChildren(orgChart, udid: udid) {
//
//                    // Expand tree, Add Child cells
//                    addChildren(parent, children: children, frame: parent.frame)
//                }
//            }
//        } else {
//            // Expand OrgChart with Animation
//            UIView.animate(withDuration: 0.25, animations: { [unowned self] in
//                parent.childStack?.isHidden = !isExpand
//
//                // Update UI
//                self.view.setNeedsDisplay()
//            }, completion: { [unowned self] finished in
//
//                // Update view size
//                self.orgChartView.updateScrollViewSize()
//            })
//        }
//    }
//}

extension OrgChartViewController {
    // MARK: - Chart features
    
    // Add Children cell
//    fileprivate func addChildren(_ parent: OrgChartCell?, children: [OrgChartModel]?, frame: CGRect) {
//        // Check children, chartView type
//        guard let children = children, !children.isEmpty else {
//            return
//        }
//
//        // Insert cells to chartView
//        var willAppendCell = [OrgChartCell]()
//
//        // default reporting line type
//        var lineLinkType: LinkType = .leftBottom
//
//        // Create Child Cells
//        for child in children {
//            guard let newCell = createOrgChartCell(frame, parent: parent, childData: child) else {
//                continue
//            }
//
//            newCell.delegate = self
//
//            // Show/Hide Expand Button
//            newCell.bottomLink.isHidden = child.children.isEmpty
//
//            if !child.children.isEmpty {
//                // line type
//                lineLinkType = .topBottom
//                newCell.bottomLink.isHidden = false
//            }
//            else {
//                // Hide Botton Link Button if End of the tree
//                newCell.bottomLink.isHidden = true
//            }
//
//            willAppendCell.append(newCell)
//        }
//
//        // Change Line type to [.topBottom] if appended cell has just one child
//        if lineLinkType == .leftBottom && children.count <= 1 {
//            lineLinkType = .topBottom
//        }
//
//        // Set link line type for connection line draw
//        parent?.childLinkType = lineLinkType
//
//        // Attach children cell into chartView
//        orgChartView.insertChildren(parent, children: willAppendCell)
//    }
    
    // MARK: - Private functions
    
//    // Create orgchart cell view
//    private func createOrgChartCell(_ frame: CGRect, parent: OrgChartCell?, childData: OrgChartModel?) -> OrgChartCell? {
//        guard let childData = childData else {
//            UIAlertController.notifyAlert(self, title: "Error", message: "Can't load json file.")
//            return nil
//        }
//        return OrgChartCell(frame: frame,
//                            userUdid: childData.udid,
//                            userName: childData.name,
//                            userPosition: childData.position,
//                            userCompany: childData.company,
//                            userParent: parent)
//    }
}
