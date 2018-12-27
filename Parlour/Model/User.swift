//
//  User.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase

struct User {

    let uid: String
    let email: String
    //let displayName: String

    init(authData: Firebase.User) {

        guard
            let email = authData.email
            else { fatalError("Email is nil.")
        }

//        guard
//            let displayName = authData.displayName
//            else { fatalError("displayName is nil.") }

        self.uid = authData.uid
        self.email = email
        //self.displayName = displayName

    }

    init(uid: String, email: String) {

        self.uid = uid
        self.email = email
        //self.displayName = displayName

    }

}
