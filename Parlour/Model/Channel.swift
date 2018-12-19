//
//  Channel.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/19.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation

struct Channel {

    let hostID: String
    var title: String
    var type: String
    var isLive: String
    var password: String
    var youtubeID: String
    let channelID: String

    init(hostID: String, title: String, type: String, isLive: String, password: String, youtubeID: String, channelID: String) {

        self.hostID = hostID
        self.title = title
        self.type = type
        self.isLive = isLive
        self.password = password
        self.youtubeID = youtubeID
        self.channelID = channelID

    }

    func uploadChannelObjectToFirebase() -> Any {

        return [

            "hostID": hostID,
            "title": title,
            "type": type,
            "isLive": isLive,
            "password": password,
            "youtubeID": youtubeID,
            "channelID": channelID

        ]

    }

}
