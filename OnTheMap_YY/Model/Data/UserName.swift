//
//  StudentData.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/9.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct UserName: Codable{
    let firstName: String
    let lastName: String
    
    enum CodingKeys : String,CodingKey{
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
