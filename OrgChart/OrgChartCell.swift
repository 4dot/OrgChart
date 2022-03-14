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

protocol OrgChartCellDelegate : AnyObject {
    func cellExpand(_ parent:OrgChartCell, udid:String, isExpand:Bool)
}


//
// OrgChartCell View Class
//
class OrgChartCell: UIView {
    
    var udid: String = ""
    
    // UIs
    var baseView: UIView!
    var name: UILabel!
    var position: UILabel!
    var company: UILabel!
    
    // Connection line & positoin mark buttons
    var connectLine: CAShapeLayer!
    var topLink: UIButton!
    var bottomLink: UIButton!
    var leftLink: UIButton!
    
    weak var parent: OrgChartCell?
    
    // Show/Hide
    weak var myStack: UIStackView!
    weak var childStack: UIStackView?
    
    // StackView index
    var stackIndex: Int = 0
    
    // Connection Line Type
    var childLinkType: LinkType = .topBottom
    
    // Cell indent, Default 10 pixels
    var cellIndent = AppConstants.cllIndent
    
    // delegate
    weak var delegate: OrgChartCellDelegate?
    
    
    // MARK: - Initialize
    
    init(frame: CGRect, userUdid: String, userName: String, userPosition: String?, userCompany: String?, userParent: OrgChartCell?) {
        super.init(frame: frame)
        
        baseView = UIView()
        
        clipsToBounds = false
        backgroundColor = UIColor.clear
        
        // Set parent, set default my stack index
        
        // Create connection line layer
        connectLine = CAShapeLayer()
        layer.addSublayer(connectLine)
        
        parent = userParent
        stackIndex = 0
        udid = userUdid
        
        let cellRect = CGRect(x: cellIndent, y: cellIndent, width: frame.width - cellIndent * 2, height: frame.height - (cellIndent * 2))
        
        // create base view
        baseView.frame = cellRect
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = 5.0
        baseView.layer.borderColor = UIColor.darkGray.cgColor
        baseView.layer.borderWidth = 1.5
        addSubview(baseView)
        
        // create display labels(name, position, company)
        name = UILabel(frame: CGRect(x: 5, y: 2, width: cellRect.width - 10, height: cellRect.height * 10 / 26))
        name.font = AppConstants.cellNameFont
        name.text = userName
        name.textAlignment = .center
        baseView.addSubview(name)
        
        position = UILabel(frame: CGRect(x: 5, y: cellRect.height*(8 / 26), width: cellRect.width - 10, height: cellRect.height * 8 / 26))
        position.font = AppConstants.cellSubFont
        position.text = userPosition ?? ""
        position.textAlignment = .center
        baseView.addSubview(position)
        
        company = UILabel(frame: CGRect(x: 5, y: cellRect.height*(14 / 26), width: cellRect.width - 10, height: cellRect.height * 8 / 26))
        company.font = AppConstants.cellSubFont
        company.text = userCompany ?? ""
        company.textAlignment = .center
        baseView.addSubview(company)
        
        // Create Link Point
        let linkBtnRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        // top link button position
        topLink = UIButton(frame: linkBtnRect)
        topLink.center = CGPoint(x: cellRect.width / 2, y: 0)
        topLink.backgroundColor = .clear
        baseView.addSubview(topLink)
        
        // bottom link button, expand button
        bottomLink = UIButton(frame: linkBtnRect)
        bottomLink.center = CGPoint(x: cellRect.width / 2, y: baseView.frame.height)
        bottomLink.addTarget(self, action: #selector(expand(_:)), for: .touchUpInside)
        bottomLink.setImage(UIImage(named: "plus"), for: .normal)
        baseView.addSubview(bottomLink)
        
        // left link
        leftLink = UIButton(frame: linkBtnRect)
        leftLink.center = CGPoint(x: 0, y: cellRect.height / 2)
        leftLink.backgroundColor = .clear
        baseView.addSubview(leftLink)
        
        // Set view size
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            widthAnchor.constraint(equalToConstant: frame.width)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - override
    // Hit Test of outside expand button on the baseView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let convertedPoint = bottomLink.convert(point, from: self)
        
        if (bottomLink.bounds.contains(convertedPoint)) {
            return bottomLink.hitTest(convertedPoint, with: event)
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Public
    
    // set baseView's indent
    func setIndent(_ indent: CGFloat) {
        var baseViewRc = baseView.frame
        baseViewRc.origin.x = indent
        
        baseView.frame = baseViewRc
        cellIndent = indent
    }
    
    func setCellColor(_ bgColor: UIColor, fontColor: UIColor) {
        // Update BaseView's bg color and Font color
        baseView.backgroundColor = bgColor
        name.textColor = fontColor
        position.textColor = fontColor
        company.textColor = fontColor
    }
    
    // MARK: - Expand Button event
    
    // When pressed show/hide button
    @objc func expand(_ sender: UIButton!) {
        let hidden = childStack?.isHidden ?? true
        
        delegate?.cellExpand(self, udid: udid, isExpand: hidden)
        bottomLink.setImage(hidden ? UIImage(named: "minus") : UIImage(named: "plus"), for: .normal)
    }    
}
