//
//  UserManager.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/11.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation

protocol UserManagerDelegate: AnyObject {

    func manager(_ manager: LoginViewController, didFetch user: User)

    func manager(_ manager: LoginViewController, didFailWith error: Error)

}
