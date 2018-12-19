//
//  VideoControl.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/12.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation

struct VideoControl {

    var videoID: String
    var nextVideoID: String
    var title: String
    var type: String
    var password: String

    var isLive: String
    var currentTime: Int
    var hostID: String

    init(videoID: String, nextVideoID: String, title: String, type: String, password: String, isLive: String, currentTime: Int, hostID: String) {

        self.videoID = videoID
        self.nextVideoID = nextVideoID
        self.title = title
        self.type = type
        self.password = password

        self.isLive = isLive
        self.currentTime = currentTime
        self.hostID = hostID

    }

    func saveVideoControlObjectToFirebase() -> Any {

        return [

            "videoID": videoID,
            "nextVideoID": nextVideoID,
            "title": title,
            "type": type,
            "password": password,

            "isLive": "YES",
            "currentTime": currentTime,
            "hostID": hostID

        ]

    }
}
