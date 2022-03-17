//: Playground - noun: a place where people can play

import UIKit


//
// OrgChart Cell UI Test
//

//
// OrgChartCell View Class
//
class OrgChartCell: UIView {
    
    // base view
    let baseView: UIView = UIView()
    
    // Organization Data
    var udid: String = String()
    
    var nameLbl: UILabel!
    var positionLbl: UILabel!
    var companyLbl: UILabel!
    
    // Link line
    var topLinkBtn: UIButton!
    var bottomLinkBtn: UIButton!
    var leftLinkBtn: UIButton!
    
    var connectLine: CAShapeLayer!
    
    weak var parent: OrgChartCell?
    
    // Show/Hide
    var myStack: UIStackView!
    var childStack: UIStackView?
    
    // My index of StackView
    var stackIndex: Int = 0
    
    // Cell indent, Default 10 pixels
    var cellIndent: CGFloat = 10
    
    
    
    // MARK: - Initialize
    
    init(frame: CGRect, userUdid: String, userName: String, userPosition: String?, userCompany: String?, userParent: OrgChartCell?) {
        
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
        nameLbl = UILabel(frame: CGRect(x: 5, y: 2, width: cellRect.width-10, height: cellRect.height * 10/26))
        nameLbl.font = UIFont(name:"HelveticaNeue", size: 10.0)
        nameLbl.text = userName
        nameLbl.textAlignment = .center
        baseView.addSubview(nameLbl)
        
        positionLbl = UILabel(frame: CGRect(x: 5, y: cellRect.height*(8/26), width: cellRect.width-10, height: cellRect.height * 8/26))
        positionLbl.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        positionLbl.text = userPosition ?? ""
        positionLbl.textAlignment = .center
        baseView.addSubview(positionLbl)
        
        companyLbl = UILabel(frame: CGRect(x: 5, y: cellRect.height*(14/26), width: cellRect.width-10, height: cellRect.height * 8/26))
        companyLbl.font = UIFont(name:"HelveticaNeue-Italic", size: 8.0)
        companyLbl.text = userCompany ?? ""
        companyLbl.textAlignment = .center
        baseView.addSubview(companyLbl)
        
        // Create Link Point
        let linkBtnRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        // top link button position
        topLinkBtn = UIButton(frame: linkBtnRect)
        topLinkBtn.center = CGPoint(x: cellRect.width/2, y: 0)
        topLinkBtn.backgroundColor = .red
        baseView.addSubview(topLinkBtn)
        
        // bottom link button, expand button
        bottomLinkBtn = UIButton(frame: linkBtnRect)
        bottomLinkBtn.center = CGPoint(x: cellRect.width/2, y: baseView.frame.height)
        bottomLinkBtn.setImage(UIImage(named: "plus"), for: .normal)
        bottomLinkBtn.backgroundColor = .red
        baseView.addSubview(bottomLinkBtn)
        
        // left link
        leftLinkBtn = UIButton(frame: linkBtnRect)
        leftLinkBtn.center = CGPoint(x: 0, y: cellRect.height/2)
        leftLinkBtn.backgroundColor = .green
        baseView.addSubview(leftLinkBtn)
        
        // Set view size
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            widthAnchor.constraint(equalToConstant: frame.width)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Preview for OrgChartCell
let chartCell = OrgChartCell(frame: CGRect(x: 0, y: 0, width: 170, height: 90),
                             userUdid: "udid",
                             userName: "Chanick Park",
                             userPosition: "Software Developer",
                             userCompany: "4dot",
                             userParent: nil)
