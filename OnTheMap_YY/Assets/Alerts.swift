//
//  Alerts.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/10.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class Alerts {
    
    class func showFailure(title: String, message: String) -> UIAlertController {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertVC
    }
}
