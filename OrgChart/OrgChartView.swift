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

enum LinkType {
    case topBottom
    case leftBottom
}

// Zoom Scale
let ORGCHART_MAX_SCALE: CGFloat = 2.0
let ORGCHART_MIN_SCALE: CGFloat = 1.0

//
// OrgChartView Class
//
class OrgChartView: UIView {
    
    // for update all children cells
    var orgChartCells: [OrgChartCell] = []
    
    // for pinch, pan
    var _scale: CGFloat = 1.0
    var _centerPos: CGPoint = CGPoint.zero
    
    var _scaleFactor: CGFloat = 1.0
    
    // root cell
    weak var rootCell: OrgChartCell?
    
    // Main ScrollView
    var scrollView: UIScrollView!
    
    
    
    // MARK: - Initialize
    
    required init?(coder aDecoder: NSCoder) {
    
        super.init(coder: aDecoder)
        
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
        // Same size with chartview
        let horizontalConstraint = scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let verticalConstraint = scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let widthConstraint = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor)
        let heightConstraint = scrollView.heightAnchor.constraint(equalTo: self.heightAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    // insert children cells
    func insertChildren(_ parent:OrgChartCell?, children:[OrgChartCell]) ->Void {
        
        // Check Parent Cell Validation
        guard let validParent = parent else {
            return
        }
        
        // create default stackview
        let stackView = OrgChartView.createStackView((children.count > 1 && validParent.childLinkType == .topBottom) ? .horizontal : .vertical)
        
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
        
        // Child Cell can insert to Vertical stack view only
        // Create Vertical stackview when insert to Horizontal stack of parent cell
        if(validParent.myStack.axis == .horizontal) {
            
            let vertStackView = OrgChartView.createStackView(.vertical)
            scrollView.addSubview(vertStackView)
            
            validParent.myStack.insertArrangedSubview(vertStackView, at: validParent.stackIndex)
            
            // remove parent from prev stackview and insert new stackview
            validParent.myStack.removeArrangedSubview(validParent)
            validParent.myStack = vertStackView
            
            vertStackView.addArrangedSubview(validParent)
            vertStackView.addArrangedSubview(stackView)
            
            // target stack for update
            targetStack = vertStackView
        }
        else {
            // Direct insert Child Cell to parent vertical stack view
            // insert stackview to end of parent's stackview
            validParent.myStack.insertArrangedSubview(stackView, at: validParent.myStack.arrangedSubviews.count)
            
            // target stack for update
            targetStack = validParent.myStack
            
        }
        
        // save children's stackview
        validParent.childStack = stackView
        
        // Adding animation
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            // update UI
            targetStack!.layoutIfNeeded()
            
            self?.setNeedsDisplay()
        }, completion: { [weak self] (finished: Bool) -> Void in
            
            // update view size
            self?.updateScrollViewSize()
        })
    }
    
    // Update scroll view size when zoom in/out
    
    func updateScrollViewSize() ->Void {
        
        guard let rootStackView = rootCell?.myStack else {
            return
        }
        
        // need scrollview update
        var bNeedScroll: Bool = false
        var contentSize = self.frame.size
        
        let rootStackFrame = rootStackView.frame
        
        //
        if rootStackFrame.width > contentSize.width {
            contentSize.width = rootStackFrame.width
            bNeedScroll = true
        }
        if (rootStackFrame.height + rootStackFrame.origin.y) > contentSize.height {
            contentSize.height = rootStackFrame.height + 100    // 100 : default height position
            bNeedScroll = true
        }
        
        scrollView.isScrollEnabled = bNeedScroll
        scrollView.contentSize = contentSize
        
        let leftInset = (contentSize.width - self.frame.size.width)/2
        let topInset = (_scaleFactor != 1.0) ? abs(rootStackFrame.origin.y) : 0
        
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: -topInset, right: -leftInset)
    }
    
    // MARK: - override func.
    
    // draw link Lines
    override func draw(_ rect: CGRect) {
        
        // Loop all of Cells
        let DEFAULTCELL_INDENT: CGFloat = 10.0
        
        for childCell in orgChartCells {
            
            // Check existing of parent and is cell Hidden
            guard let parent = childCell.parent,
                  childCell.isHidden == false else {
                continue
            }
            
            // curve range
            let curveRange: CGFloat = 3.0
            
            // Set Indent
            
            childCell.setIndent((parent.childLinkType == .topBottom) ? DEFAULTCELL_INDENT : DEFAULTCELL_INDENT * 3)
            
            // get lelative position in parent view
            let parentPos = parent.baseView.convert(parent.bottomLink.center, to: childCell)
            let startPos = (parent.childLinkType == .topBottom) ? childCell.topLink.center : childCell.leftLink.center
            let childPos = childCell.baseView.convert(startPos, to: childCell)
            
            // Draw BezierPath
            
            // Link Child to Parent
            let path = UIBezierPath()
            path.move(to: childPos)
            
            if parentPos.x == childPos.x {
                // Simple TopDown Line
                path.addLine(to: parentPos)
            }
            else {
                // Draw line Child's Left to Parent's Bottom
                if parent.childLinkType == .leftBottom {
                    let nextPos1: CGPoint = CGPoint(x: childPos.x - DEFAULTCELL_INDENT, y: childPos.y)
                    let nextPos2: CGPoint = CGPoint(x: nextPos1.x, y: parentPos.y + DEFAULTCELL_INDENT)
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
        
        var scale: CGFloat = ORGCHART_MIN_SCALE
        
        if sender.scale < ORGCHART_MAX_SCALE {
            scale = ORGCHART_MIN_SCALE - (ORGCHART_MIN_SCALE - sender.scale)
        }
        else if sender.scale > ORGCHART_MAX_SCALE {
            scale = ORGCHART_MAX_SCALE - (ORGCHART_MAX_SCALE - sender.scale) / 4
        }
        else {
            scale = sender.scale
        }
        
        rootCell?.myStack.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        // gesture end
        if sender.state == .ended {
            if sender.scale < ORGCHART_MIN_SCALE {
                scale = ORGCHART_MIN_SCALE
            }
            if sender.scale > ORGCHART_MAX_SCALE {
                scale = ORGCHART_MAX_SCALE
            }
        }
        
        // Save current Scale factor
        _scaleFactor = scale
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            // Change view size
            
            strongSelf.rootCell?.myStack.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: { [weak self] (finished) -> Void in
                
                guard let strongSelf = self else {
                    return
                }

                // Update scrollview size
                strongSelf.updateScrollViewSize()
            })
    }
    
    @IBAction func panDetected(_ sender: UIPanGestureRecognizer) {
        self.bringSubviewToFront(sender.view!)
    }
}

//
// OrgChartView extenstion
//
extension OrgChartView {
    
    // MARK: - Class member func. 
    // create default stackview
    class func createStackView(_ axis: NSLayoutConstraint.Axis) ->UIStackView {
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


