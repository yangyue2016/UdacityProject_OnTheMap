//
//  OTMConstants.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/9.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct OTMResponse: Codable {
    let account: Account
    let session: Session
}
