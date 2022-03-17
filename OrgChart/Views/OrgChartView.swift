/**
 * OrgChartView.swift
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
// OrgChartView
//
class OrgChartView : UIView {
    
    // for update all children cells
    var orgChartCells: [OrgChartCell] = []
    
    // Pinch, Pan
    private var scale: CGFloat = 1.0
    private var centerPos: CGPoint = CGPoint.zero
    private var scaleFactor: CGFloat = 1.0
    
    // root cell
    weak var rootCell: OrgChartCell?
    
    // Main ScrollView
    var scrollView: UIScrollView!
    
    var chartData: OrgChartModel?
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initUI()
    }
    
    fileprivate func initUI() {
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
        // Same size with chartview
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    // MARK: - Public
    func createChart(_ chartData: OrgChartModel?) {
        // Create Root Cell
        guard let chartData = chartData,
              let rootCell = createOrgChartCell(AppConstants.cellFrame, parent: nil, chartData: chartData) else {
            UIAlertController.notifyAlert(nil, title: "Error", message: "Can't load json file.")
            return
        }
        
        // Save Chart Data
        self.chartData = chartData
        
        // Create root cell & root stack view
        rootCell.delegate = self
        rootCell.setCellColor(AppConstants.greenColor, fontColor: UIColor.white)
        //scrollView.addSubview(rootCell)
        
        // Create root stack view
        let rootStack = OrgChartView.createStackView(.vertical)
        rootStack.addArrangedSubview(rootCell)
        
        // Attach stackview into the OrgChartViewController
        scrollView.addSubview(rootStack)
        rootCell.myStack = rootStack
        
        // Save reference to root cell
        self.rootCell = rootCell
        
        // Set position of OrgChart Root StackView
        NSLayoutConstraint.activate([
            rootStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            rootStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: AppConstants.topOffset)
        ])
        
        // Add Children
        addChildren(rootCell, children: chartData.children, frame: AppConstants.cellFrame)
        
        // Set default button image
        rootCell.bottomLinkBtn.setImage(UIImage(named: "minus"), for: .normal)
    }
    
    // Update scroll view size when zoom in/out
    func updateScrollViewSize() {
        guard let rootStackView = rootCell?.myStack else {
            return
        }
        
        // need scrollview update
        var bNeedScroll = false
        var contentSize = self.frame.size
        let rootStackFrame = rootStackView.frame
        
        if rootStackFrame.width > contentSize.width {
            contentSize.width = rootStackFrame.width
            bNeedScroll = true
        }
        
        if (rootStackFrame.height + rootStackFrame.origin.y) > contentSize.height {
            contentSize.height = rootStackFrame.height + AppConstants.topOffset
            bNeedScroll = true
        }
        
        scrollView.isScrollEnabled = bNeedScroll
        scrollView.contentSize = contentSize
        
        let leftInset = (contentSize.width - self.frame.size.width) / 2
        let topInset = (scaleFactor != 1.0) ? abs(rootStackFrame.origin.y) : 0
        
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: -topInset, right: -leftInset)
    }
    
    // MARK: - override func.
    
    // draw link Lines
    override func draw(_ rect: CGRect) {
        
        for childCell in orgChartCells {
            
            // Check parent cell, check cell isHidden
            guard let parent = childCell.parent,
                  childCell.isHidden == false else {
                continue
            }
            
            // curve range
            let curveRange: CGFloat = 3.0
            
            // Set Indent
            childCell.setIndent((parent.childLinkType == .topBottom) ? AppConstants.cllIndent : AppConstants.cllIndent * 3)
            
            // get lelative position in parent view
            let parentPos = parent.baseView.convert(parent.bottomLinkBtn.center, to: childCell)
            let startPos = (parent.childLinkType == .topBottom) ? childCell.topLinkBtn.center : childCell.leftLinkBtn.center
            let childPos = childCell.baseView.convert(startPos, to: childCell)
            
            // Draw BezierPath
            
            // Link Child to Parent
            let path = UIBezierPath()
            path.move(to: childPos)
            
            if parentPos.x == childPos.x {
                // Draw straight line(Top to Down)
                path.addLine(to: parentPos)
            }
            else {
                // Draw line Child's Left to Parent's Bottom
                if parent.childLinkType == .leftBottom {
                    let nextPos1: CGPoint = CGPoint(x: childPos.x - AppConstants.cllIndent, y: childPos.y)
                    let nextPos2: CGPoint = CGPoint(x: nextPos1.x, y: parentPos.y + AppConstants.cllIndent)
                    let nextPos3: CGPoint = CGPoint(x: parentPos.x, y: nextPos2.y)
                    
                    var curvePos1: CGPoint = nextPos1
                    curvePos1.x = nextPos1.x + curveRange
                    var curvePos2: CGPoint = nextPos1
                    curvePos2.y = nextPos1.y - curveRange
                    var curvePos3: CGPoint = nextPos2
                    curvePos3.y = nextPos2.y + curveRange
                    var curvePos4: CGPoint = nextPos2
                    curvePos4.x = nextPos2.x + curveRange
                    var curvePos5: CGPoint = nextPos3
                    curvePos5.x = nextPos3.x - curveRange
                    var curvePos6: CGPoint = nextPos3
                    curvePos6.y = nextPos3.y - curveRange
                    
                    path.addLine(to: curvePos1)
                    path.addQuadCurve(to: curvePos2, controlPoint: nextPos1)
                    path.addLine(to: curvePos3)
                    path.addQuadCurve(to: curvePos4, controlPoint: nextPos2)
                    path.addLine(to: curvePos5)
                    path.addQuadCurve(to: curvePos6, controlPoint: nextPos3)
                    path.addLine(to: parentPos)
                    
                }
                else {
                    // Draw line Child's Top to Parent's Bottom
                    let nextPos1: CGPoint = CGPoint(x: childPos.x, y: parentPos.y + (childPos.y - parentPos.y)/2)
                    let nextPos2: CGPoint = CGPoint(x: parentPos.x, y: nextPos1.y)
                    
                    var curvePos1: CGPoint = nextPos1
                    curvePos1.y = nextPos1.y + curveRange
                    var curvePos2: CGPoint = nextPos1
                    curvePos2.x = (nextPos1.x > nextPos2.x) ? (nextPos1.x - curveRange) : (nextPos1.x + curveRange)
                    var curvePos3: CGPoint = nextPos2
                    curvePos3.x = (nextPos1.x > nextPos2.x) ? (nextPos2.x + curveRange) : (nextPos2.x - curveRange)
                    var curvePos4: CGPoint = nextPos2
                    curvePos4.y = nextPos2.y - curveRange
                    
                    path.addLine(to: curvePos1)
                    path.addQuadCurve(to: curvePos2, controlPoint: nextPos1)
                    path.addLine(to: curvePos3)
                    path.addQuadCurve(to: curvePos4, controlPoint: nextPos2)
                    path.addLine(to: parentPos)
                }
            }
            
            childCell.connectLine.path = path.cgPath
            childCell.connectLine.lineWidth = 0.8
            childCell.connectLine.fillColor = UIColor.clear.cgColor
            childCell.connectLine.strokeColor = UIColor.darkGray.cgColor
        }
    }
    
    // MARK: - Pinch Gesture, for Zoom In/Out
    @IBAction func pinchDetected(_ sender: UIPinchGestureRecognizer) {
        // start
        if sender.state == .began {
            sender.scale = self.transform.a
        }
        
        var scale = AppConstants.minScale
        
        if sender.scale < AppConstants.maxScale {
            scale = AppConstants.minScale - (AppConstants.minScale - sender.scale)
        }
        else if sender.scale > AppConstants.maxScale {
            scale = AppConstants.maxScale - (AppConstants.maxScale - sender.scale) / 4
        }
        else {
            scale = sender.scale
        }
        
        rootCell?.myStack.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // gesture end
        if sender.state == .ended {
            if sender.scale < AppConstants.minScale {
                scale = AppConstants.minScale
            }
            if sender.scale > AppConstants.maxScale {
                scale = AppConstants.maxScale
            }
        }
        
        // Save current Scale factor
        scaleFactor = scale
        
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            // Change view size
            self.rootCell?.myStack.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: { [unowned self] finished in
                // Update scrollview size
                self.updateScrollViewSize()
            })
    }
    
    @IBAction func panDetected(_ sender: UIPanGestureRecognizer) {
        self.bringSubviewToFront(sender.view!)
    }
}

extension OrgChartView : OrgChartCellDelegate {
    
    func cellExpand(_ parent: OrgChartCell, udid: String, isExpand: Bool) {
        // Already Exist childStack View
        if let childStack = parent.childStack {
            // Expand OrgChart with Animation
            UIView.animate(withDuration: 0.25, animations: { [unowned self] in
                childStack.isHidden = !isExpand
                
                // Update UI
                self.setNeedsDisplay()
            }, completion: { [unowned self] finished in
                
                // Update scroll view size
                self.updateScrollViewSize()
            })
        } else {
            if isExpand {
                // Find parent
                if let children = chartData?.getChildren(udid: udid) { //getChildren(chartData, udid: udid) {
                    
                    // Expand tree, Add Child cells
                    addChildren(parent, children: children, frame: parent.frame)
                }
            }
        }
    }
}
