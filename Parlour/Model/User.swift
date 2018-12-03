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

    init(authData: Firebase.User) {

        uid = authData.uid

        guard
            let email = authData.email
            else { fatalError("Email is nil.")
        }

        self.email = email

    }

    init(uid: String, email: String) {

        self.uid = uid
        self.email = email

    }

}
