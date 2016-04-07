//
//  OrgChartView.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/17/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit

enum LinkType{
    case TopBottom
    case LeftBottom
}

let MAX_SCALE: CGFloat = 2.0
let MIN_SCALE: CGFloat = 1.0

class OrgChartView: UIView {
    
    // for update all children cells
    var orgChartCells: [OrgChartCell] = []
    
    // for pinch, pan
    var scale: CGFloat = 1.0
    var centerPos: CGPoint = CGPointZero
    
    // root cell
    var rootCell: OrgChartCell?
    
    var scrollView: UIScrollView!
    
    var scaleFactor: CGFloat = 1.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scrollView = UIScrollView()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)
        
        // same size with chartview
        let horizontalConstraint = self.scrollView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
        let verticalConstraint = self.scrollView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
        let widthConstraint = self.scrollView.widthAnchor.constraintEqualToAnchor(self.widthAnchor)
        let heightConstraint = self.scrollView.heightAnchor.constraintEqualToAnchor(self.heightAnchor)
        NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    // insert children cells
    func insertChildren(parent:OrgChartCell?, children:[OrgChartCell]) ->Void {
        
        // create default stackview
        let stackView = OrgChartView.createStackView((children.count > 1 && parent?.childLinkType == .TopBottom) ? .Horizontal : .Vertical)
        
        for (index, child) in children.enumerate() {
            // attach Subview
            self.scrollView.addSubview(child)
            self.orgChartCells.append(child)
            
            child.myStack = stackView
            
            stackView.addArrangedSubview(child)
            child.stackIndex = index
        }
        // Do not Attach stackView
        //self.scrollView.addSubview(stackView)

        var targetStack: UIStackView?
        // one more wrapping with vertical stackview when parent have over 2 child
        if let validParent = parent {
            if(validParent.myStack.axis == .Horizontal) {
                let vertStackView = OrgChartView.createStackView(.Vertical)
                self.scrollView.addSubview(vertStackView)
                
                validParent.myStack.insertArrangedSubview(vertStackView, atIndex: validParent.stackIndex)
                
                // remove parent from prev stackview and insert new stackview
                validParent.myStack.removeArrangedSubview(validParent)
                validParent.myStack = vertStackView
                
                vertStackView.addArrangedSubview(validParent)
                vertStackView.addArrangedSubview(stackView)
                
                // target stack for update
                targetStack = vertStackView
            }
            else {
                // insert stackview to end of parent's stackview
                validParent.myStack.insertArrangedSubview(stackView, atIndex: validParent.myStack.arrangedSubviews.count)
                
                // target stack for update
                targetStack = validParent.myStack
                
            }
            
            // Adding animation
            UIView.animateWithDuration(0.25, animations: {
                // stackview animation
                targetStack!.layoutIfNeeded()
                self.setNeedsDisplay()
                }, completion: { [unowned self] (finished: Bool) -> Void in
                    // change view size
                    self.updateScrollViewSize()
                })
            
            // save children's stackview
            validParent.childStack = stackView
        }
        // root cell
        else {
            
        }
    }
    
    func updateScrollViewSize() ->Void {
        // need scrollview update
        var bNeedScroll: Bool = false
        var contentSize = self.frame.size
        if let rootStackFrame = self.rootCell?.myStack.frame {
            if rootStackFrame.width > contentSize.width {
                contentSize.width = rootStackFrame.width
                bNeedScroll = true
            }
            if (rootStackFrame.height + rootStackFrame.origin.y) > contentSize.height {
                contentSize.height = rootStackFrame.height + 100    // 100 : default height position
                bNeedScroll = true
            }
            
            self.scrollView.scrollEnabled = bNeedScroll
            self.scrollView.contentSize = contentSize
            let leftInset = (contentSize.width - self.frame.size.width)/2
            let topInset = (self.scaleFactor != 1.0) ? abs(rootStackFrame.origin.y) : 0
            
            self.scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: -topInset, right: -leftInset)
        }
        
        
        
        //self.rootCell?.myStack.frame.origin.x = 0
        //self.scrollView.layoutIfNeeded()
        //self.scrollView.setNeedsLayout()
    }
    
    // MARK: - override func.
    override func drawRect(rect: CGRect) {
        // Loop All Cells
        let DEFCELL_INDENT: CGFloat = 5.0
        
        for case let childCell in self.orgChartCells {
            // curve
            let curveRange: CGFloat = 3.0
            
            // draw connection line
            if let parent = childCell.parent {
                if childCell.hidden == false {
                    childCell.setIndent((parent.childLinkType == .TopBottom) ? DEFCELL_INDENT : DEFCELL_INDENT * 3)
                    
                    // get lelative position in parent view
                    let parentPos = parent.baseView.convertPoint(parent.bottomLink.center, toView: childCell)
                    let startPos = (parent.childLinkType == .TopBottom) ? childCell.topLink.center : childCell.leftLink.center
                    let childPos = childCell.baseView.convertPoint(startPos, toView: childCell)
                    
                    // Draw BezierPath
                    // Link Child to Parent
                    let path = UIBezierPath()
                    path.moveToPoint(childPos)
                    
                    // Simple TopDown Line
                    if parentPos.x == childPos.x {
                        path.addLineToPoint(parentPos)
                    }
                    else {
                        // Draw Child's Left side to Parent's Bottom
                        if parent.childLinkType == .LeftBottom {
                            let nextPos1: CGPoint = CGPointMake(childPos.x - DEFCELL_INDENT, childPos.y)
                            let nextPos2: CGPoint = CGPointMake(nextPos1.x, parentPos.y + DEFCELL_INDENT)
                            let nextPos3: CGPoint = CGPointMake(parentPos.x, nextPos2.y)
                            
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
                            
                            path.addLineToPoint(curvePos1)
                            path.addQuadCurveToPoint(curvePos2, controlPoint: nextPos1)
                            path.addLineToPoint(curvePos3)
                            path.addQuadCurveToPoint(curvePos4, controlPoint: nextPos2)
                            path.addLineToPoint(curvePos5)
                            path.addQuadCurveToPoint(curvePos6, controlPoint: nextPos3)
                            path.addLineToPoint(parentPos)
                            
                        }
                        else {
                            // Draw Child's Top side to Parent's Bottom
                            let nextPos1: CGPoint = CGPointMake(childPos.x, parentPos.y + (childPos.y - parentPos.y)/2)
                            let nextPos2: CGPoint = CGPointMake(parentPos.x, nextPos1.y)
                            
                            var curvePos1: CGPoint = nextPos1
                            curvePos1.y = nextPos1.y + curveRange
                            var curvePos2: CGPoint = nextPos1
                            curvePos2.x = (nextPos1.x > nextPos2.x) ? (nextPos1.x - curveRange) : (nextPos1.x + curveRange)
                            var curvePos3: CGPoint = nextPos2
                            curvePos3.x = (nextPos1.x > nextPos2.x) ? (nextPos2.x + curveRange) : (nextPos2.x - curveRange)
                            var curvePos4: CGPoint = nextPos2
                            curvePos4.y = nextPos2.y - curveRange
                            
                            
                            path.addLineToPoint(curvePos1)
                            path.addQuadCurveToPoint(curvePos2, controlPoint: nextPos1)
                            path.addLineToPoint(curvePos3)
                            path.addQuadCurveToPoint(curvePos4, controlPoint: nextPos2)
                            path.addLineToPoint(parentPos)
                        }
                    }
                    
                    childCell.connectLine.path = path.CGPath
                    childCell.connectLine.lineWidth = 0.8
                    childCell.connectLine.fillColor = UIColor.clearColor().CGColor
                    childCell.connectLine.strokeColor = UIColor.darkGrayColor().CGColor
                }
            }
        }
    }
    
    // MARK: - Pinch Gesgure
    @IBAction func pinchDetected(sender: UIPinchGestureRecognizer) {
        // start
        if sender.state == UIGestureRecognizerState.Began {
            sender.scale = self.transform.a
        }
        
        var scale: CGFloat = MIN_SCALE
        
        if sender.scale < MAX_SCALE {
            scale = MIN_SCALE - (MIN_SCALE - sender.scale)
        }
        else if sender.scale > MAX_SCALE {
            scale = MAX_SCALE - (MAX_SCALE - sender.scale) / 4
        }
        else {
            scale = sender.scale
        }
        
        //self.transform = CGAffineTransformMakeScale(scale, scale)
        self.rootCell?.myStack.transform = CGAffineTransformMakeScale(scale, scale)
        
        // end
        if sender.state == UIGestureRecognizerState.Ended {
            if sender.scale < MIN_SCALE {
                scale = MIN_SCALE
            }
            if sender.scale > MAX_SCALE {
                scale = MAX_SCALE
            }
        }
        
        self.scaleFactor = scale
        
        UIView.animateWithDuration(0.25, animations: {
            // change view size
            //self.transform = CGAffineTransformMakeScale(scale, scale)
            self.rootCell?.myStack.transform = CGAffineTransformMakeScale(scale, scale)
            }, completion: { [unowned self] (finished: Bool) -> Void in
                // update scrollview size
                self.updateScrollViewSize()
            })
    }
    
    @IBAction func panDetected(sender: UIPanGestureRecognizer) {
        self.bringSubviewToFront(sender.view!)
        //let translation = sender.translationInView(self)
        //self.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
        //sender.setTranslation(CGPointZero, inView: self)
    }
    
    // MARK: - Class member func. create default stackview
    class func createStackView(axis: UILayoutConstraintAxis) ->UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.distribution = .Fill
        stackView.alignment = (axis == .Vertical) ? .Center : .Top
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.clipsToBounds = false
        
        return stackView
    }
}


