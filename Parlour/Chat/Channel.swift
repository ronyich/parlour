//
//  channel.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/6.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase

struct Channel {

    let reference: DatabaseReference?
    let channelID: String

    let host: String
    var name: String
    var password: String
    var type: String

    init(channelID: String, host: String, name: String, password: String, type: String) {

        self.reference = nil
        self.channelID = channelID

        self.host = host
        self.name = name
        self.password = password
        self.type = type

    }

    init?(snapshot: DataSnapshot) {

        guard
            let value = snapshot.value as? [ String: AnyObject ],
            let host = value["host"] as? String,
            let name = value["name"] as? String,
            let password = value["password"] as? String,
            let type = value["type"] as? String
            else { print("Channel init? property error.")
                return nil
        }

        self.reference = snapshot.ref
        self.channelID = snapshot.key

        self.host = host
        self.name = name
        self.password = password
        self.type = type

    }

}
