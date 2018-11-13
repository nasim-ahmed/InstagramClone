//
//  Post.swift
//  DuoSnap
//
//  Created by Nasim on 10/4/17.
//  Copyright © 2017 Nasim. All rights reserved.
//

import Foundation

struct Post {
    var id:String?
    
    let imageUrl:String
    let user: User
    let caption: String
    let creationDate: Date
    
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}


