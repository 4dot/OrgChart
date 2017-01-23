/**
 * OrgChartCell.swift
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

// Protocols

protocol OrgChartCellDelegate : class {
    func cellExtend(_ parent:OrgChartCell, udid:String, bExtend:Bool)
}


//
// OrgChartCell View Class
//
class OrgChartCell: UIView {
    
    // base view
    let baseView:UIView = UIView()
    
    // Organization Data
    var udid: String = String()
    var name: UILabel!
    var position: UILabel!
    var company: UILabel!
    
    // Link line
    var topLink: UIButton!
    var bottomLink: UIButton!
    var leftLink: UIButton!
    var connectLine: CAShapeLayer!
    
    weak var parent: OrgChartCell?
    
    // Show/Hide
    var myStack: UIStackView!
    var childStack: UIStackView?
    
    // My index of StackView
    var stackIndex: NSInteger!
    
    // Connection Line Type
    var childLinkType: LinkType = .topBottom
    
    // Cell indent, Default 10 pixels
    var cellIndent:CGFloat = 10
    
    // delegate
    weak var delegate:OrgChartCellDelegate?
    
    
    // MARK: - Initialize
    
    init(frame: CGRect, userUdid: String, userName: String, userPosition: String?, userCompany: String?, userParent:OrgChartCell?) {
        
        super.init(frame: frame)
        
        clipsToBounds = false
        backgroundColor = UIColor.clear
        
        // Set parent, set default my stack index
        connectLine = CAShapeLayer()
        layer.addSublayer(connectLine)
        
        parent = userParent
        stackIndex = 0
        
        let cellRect = CGRect(x: cellIndent, y: cellIndent, width: frame.width-cellIndent*2, height: frame.height-(cellIndent*2))
        
        // create base view
        baseView.frame = cellRect
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = 5.0
        baseView.layer.borderColor = UIColor.darkGray.cgColor
        baseView.layer.borderWidth = 1.5
        addSubview(baseView)
        
        // create controls
        // name, position, company label
        udid = userUdid
        name = UILabel(frame: CGRect(x: 5, y: 2, width: cellRect.width-10, height: cellRect.height * 10/26))
        name.font = UIFont(name:"HelveticaNeue", size: 10.0)
        name.text = userName
        name.textAlignment = .center
        baseView.addSubview(name)
        
        position = UILabel(frame: CGRect(x: 5, y: cellRect.height*(8/26), width: cellRect.width-10, height: cellRect.height * 8/26))
        position.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        position.text = userPosition ?? ""
        position.textAlignment = .center
        baseView.addSubview(position)
        
        company = UILabel(frame: CGRect(x: 5, y: cellRect.height*(14/26), width: cellRect.width-10, height: cellRect.height * 8/26))
        company.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        company.text = userCompany ?? ""
        company.textAlignment = .center
        baseView.addSubview(company)
        
        // Create Link Point
        let linkBtnRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        // top link button position
        topLink = UIButton(frame: linkBtnRect)
        topLink.center = CGPoint(x: cellRect.width/2, y: 0)
        topLink.backgroundColor = .clear//.redColor()
        //topLink.alpha = 0.5
        baseView.addSubview(topLink)
        
        // bottom link button, extend button
        bottomLink = UIButton(frame: linkBtnRect)
        bottomLink.center = CGPoint(x: cellRect.width/2, y: baseView.frame.height)
        bottomLink.addTarget(self, action: #selector(OrgChartCell.extend(_:)), for: .touchUpInside)
        bottomLink.setImage(UIImage(named: "plus"), for: UIControlState())
        baseView.addSubview(bottomLink)
        
        // left link
        leftLink = UIButton(frame: linkBtnRect)
        leftLink.center = CGPoint(x: 0, y: cellRect.height/2)
        leftLink.backgroundColor = .clear//.greenColor()
        //leftLink.alpha = 0.5
        baseView.addSubview(leftLink)
        
        // Set view size
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - override
    // Hit Test of outside extend button on the baseView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let translatedPoint = bottomLink.convert(point, from: self)
        
        if (bottomLink.bounds.contains(translatedPoint)) {
            return bottomLink.hitTest(translatedPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Public functions
    
    // set baseView's indent
    func setIndent(_ indent: CGFloat) ->Void {
        
        var baseViewRc = baseView.frame
        baseViewRc.origin.x = indent
        
        baseView.frame = baseViewRc
        cellIndent = indent
    }
    
    func setCellColor(_ bgColor: UIColor, fontColor: UIColor) ->Void {
        
        // change baseView's  bg color and Font color
        baseView.backgroundColor = bgColor
        name.textColor = fontColor
        position.textColor = fontColor
        company.textColor = fontColor
    }
    
    // MARK: - button event
    
    // when pressed show/hide button
    func extend(_ sender: UIButton!) {
        
        let hidden = childStack?.isHidden
        delegate?.cellExtend(self, udid:udid, bExtend: (hidden == nil) ? true : hidden!)
        
        bottomLink.setImage((hidden == false) ? UIImage(named: "plus") : UIImage(named: "minus"), for: .normal)
    }    
}
