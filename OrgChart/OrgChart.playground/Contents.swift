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
    
    // Cell indent, Default 10 pixels
    var cellIndent:CGFloat = 10
    
    
    
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
        topLink.backgroundColor = .red
        baseView.addSubview(topLink)
        
        // bottom link button, expand button
        bottomLink = UIButton(frame: linkBtnRect)
        bottomLink.center = CGPoint(x: cellRect.width/2, y: baseView.frame.height)
        bottomLink.setImage(UIImage(named: "plus"), for: .normal)
        topLink.backgroundColor = .red
        baseView.addSubview(bottomLink)
        
        // left link
        leftLink = UIButton(frame: linkBtnRect)
        leftLink.center = CGPoint(x: 0, y: cellRect.height/2)
        leftLink.backgroundColor = .green
        baseView.addSubview(leftLink)
        
        // Set view size
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
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
