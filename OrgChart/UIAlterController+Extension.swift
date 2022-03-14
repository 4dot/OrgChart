//
//  UIAlterController+Extension.swift
//  OrgChart
//
//  Created by OGiP on 3/14/22.
//  Copyright © 2022 Park, Chanick. All rights reserved.
//

import UIKit

// function for show alert in parent Controller
extension UIAlertController {
    static func notifyAlert(_ parent: UIViewController, title: String, message: String, showOk: Bool = true, handler: (()->Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        if showOk {
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                handler?()
            })
            alert.addAction(cancelAction)
        }
        
        parent.present(alert, animated: true, completion: nil)
    }
}
