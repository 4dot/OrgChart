//
//  OrgChartCell.swift
//  OrgChart
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import UIKit

protocol OrgChartCellDelegate {
    func cellExtend(parent:OrgChartCell, udid:String, bExtend:Bool) ->Void
}

class OrgChartCell: UIView {
    // base view
    let baseView:UIView = UIView()
    
    // Org Data
    var udid: String = String()
    var name: UILabel!
    var position: UILabel!
    var company: UILabel!
    
    // Link line
    var topLink: UIButton!
    var bottomLink: UIButton!
    var leftLink: UIButton!
    var parent: OrgChartCell?
    var connectLine: CAShapeLayer!
    
    // Show/Hide
    var myStack: UIStackView!
    var childStack: UIStackView?
    
    // My index at StackView
    var stackIndex: NSInteger!
    
    // check for final children(end of the tree)
    var childLinkType: LinkType = .TopBottom
    
    // cell indent
    var cellIndent:CGFloat = 5
    
    // delegate
    var delegate:OrgChartCellDelegate!
    
    // Initialize
    init(frame: CGRect, udid: String, name: String, position: String?, company: String?, parent:OrgChartCell?) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clearColor()
        
        // set parent, set default my stack index
        self.connectLine = CAShapeLayer()
        self.layer.addSublayer(self.connectLine)
        
        self.parent = parent
        stackIndex = 0
        
        let cellRect = CGRectMake(self.cellIndent, self.cellIndent, frame.width-self.cellIndent*2, frame.height-(self.cellIndent*2))
        
        // create base view
        self.baseView.frame = cellRect
        self.baseView.backgroundColor = .whiteColor()
        self.baseView.layer.cornerRadius = 5.0
        self.baseView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.baseView.layer.borderWidth = 1.5
        self.addSubview(self.baseView)
        
        // create controls
        // name, position, company label
        self.udid = udid
        self.name = UILabel(frame: CGRectMake(5, 2, cellRect.width-10, cellRect.height * 10/26))
        self.name.font = UIFont(name:"HelveticaNeue", size: 10.0)
        self.name.text = name
        self.name.textAlignment = .Center
        baseView.addSubview(self.name)
        
        self.position = UILabel(frame: CGRectMake(5, cellRect.height*(8/26), cellRect.width-10, cellRect.height * 8/26))
        self.position.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        self.position.text = position ?? ""
        self.position.textAlignment = .Center
        baseView.addSubview(self.position)
        
        self.company = UILabel(frame: CGRectMake(5, cellRect.height*(14/26), cellRect.width-10, cellRect.height * 8/26))
        self.company.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        self.company.text = company ?? ""
        self.company.textAlignment = .Center
        baseView.addSubview(self.company)
        
        // Create Link Point
        let linkBtnRect = CGRectMake(0, 0, 20, 20)
        
        // top link position
        self.topLink = UIButton(frame: linkBtnRect)
        self.topLink.center = CGPointMake(cellRect.width/2, 0)
        self.topLink.backgroundColor = .clearColor()//.redColor()
        //self.topLink.alpha = 0.5
        self.baseView.addSubview(self.topLink)
        
        // bottom link, extend button
        self.bottomLink = UIButton(frame: linkBtnRect)
        self.bottomLink.center = CGPointMake(cellRect.width/2, self.baseView.frame.height)
        self.bottomLink.addTarget(self, action: #selector(OrgChartCell.extend(_:)), forControlEvents: .TouchUpInside)
        self.bottomLink.setImage(UIImage(named: "plus"), forState: .Normal)
        self.baseView.addSubview(self.bottomLink)
        
        // left link
        self.leftLink = UIButton(frame: linkBtnRect)
        self.leftLink.center = CGPointMake(0, cellRect.height/2)
        self.leftLink.backgroundColor = .clearColor()//.greenColor()
        //self.leftLink.alpha = 0.5
        self.baseView.addSubview(self.leftLink)
        
        // set view size
        self.heightAnchor.constraintEqualToConstant(frame.height).active = true
        self.widthAnchor.constraintEqualToConstant(frame.width).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // set baseview's indent
    func setIndent(indent: CGFloat) ->Void {
        var baseViewRc = self.baseView.frame
        self.cellIndent = indent
        baseViewRc.origin.x = indent
        
        self.baseView.frame = baseViewRc
    }
    
    func setCellColor(bgColor: UIColor, fontColor: UIColor) ->Void {
        // change baseView's  bg color and Font color
        self.baseView.backgroundColor = bgColor
        self.name.textColor = fontColor
        self.position.textColor = fontColor
        self.company.textColor = fontColor
    }
    
    // extend button hitTest on outside of baseView
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let translatedPoint = self.bottomLink.convertPoint(point, fromView: self)
        
        if (CGRectContainsPoint(self.bottomLink.bounds, translatedPoint)) {
            return self.bottomLink.hitTest(translatedPoint, withEvent: event)
        }
        return super.hitTest(point, withEvent: event)
    }
    
    // MARK: - button event
    // pressed show/hide button
    func extend(sender: UIButton!) {
        let hidden = self.childStack?.hidden
        self.delegate.cellExtend(self, udid:self.udid, bExtend: (hidden == nil) ? true : hidden!)
        
        self.bottomLink.setImage((hidden == false) ? UIImage(named: "plus") : UIImage(named: "minus"), forState: .Normal)
    }    
}
