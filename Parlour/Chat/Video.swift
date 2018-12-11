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
    var videoID: String
    var nextVideoID: String
    let hostID: String
    var currentTime: Int

    init(title: String, videoID: String, nextVideoID: String, hostID: String, currentTime: Int) {

        self.title = title
        self.videoID = videoID
        self.nextVideoID = nextVideoID
        self.hostID = hostID
        self.currentTime = currentTime

    }

    init?(snapshot: DataSnapshot, title: String, videoID: String, nextVideoID: String, hostID: String, currentTime: Int) {

        self.title = title
        self.videoID = videoID
        self.nextVideoID = nextVideoID
        self.hostID = hostID
        self.currentTime = currentTime

    }

    func saveVideoObjectToFirebase() -> Any {

        return [

            "title": title,
            "videoID": videoID,
            "nextVideoID": nextVideoID,
            "hostID": hostID,
            "currentTime": currentTime

        ]

    }

}
