//
//  StudentLocation.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/11.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct StudentLocation :Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
