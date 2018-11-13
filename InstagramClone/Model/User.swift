//
//  User.swift
//  DuoSnap
//
//  Created by Nasim on 10/7/17.
//  Copyright © 2017 Nasim. All rights reserved.
//

import Foundation

struct User{
    let uid: String
    let username:String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
 
