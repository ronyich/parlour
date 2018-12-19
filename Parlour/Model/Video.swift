//
//  Video.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/10.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase

struct Video {

    var title: String
    var youtubeID: String
    var thumbnail: String
    var currentTime: Int
    var duration: Int
    var hostID: String

    init(title: String, youtubeID: String, thumbnail: String, currentTime: Int, duration: Int, hostID: String) {

        self.title = title
        self.youtubeID = youtubeID
        self.thumbnail = thumbnail
        self.currentTime = currentTime
        self.duration = duration
        self.hostID = hostID

    }

    init?(snapshot: DataSnapshot, title: String, youtubeID: String, thumbnail: String, currentTime: Int, duration: Int, hostID: String) {

        self.title = title
        self.youtubeID = youtubeID
        self.thumbnail = thumbnail
        self.currentTime = currentTime
        self.duration = duration
        self.hostID = hostID

    }

    func saveVideoObjectToFirebase() -> Any {

        return [

            "title": title,
            "youtubeID": youtubeID,
            "thumbnail": thumbnail,
            "currentTime": currentTime,
            "duration": duration,
            "hostID": hostID

        ]

    }

}
