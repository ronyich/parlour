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
    var thumbnail: String
    var duration: Int
    

    init(title: String, videoID: String, thumbnail: String, duration: Int) {

        self.title = title
        self.videoID = videoID
        self.thumbnail = thumbnail
        self.duration = duration

    }

    init?(snapshot: DataSnapshot, title: String, videoID: String, thumbnail: String, duration: Int) {

        self.title = title
        self.videoID = videoID
        self.thumbnail = thumbnail
        self.duration = duration

    }

    func saveVideoObjectToFirebase() -> Any {

        return [

            "title": title,
            "videoID": videoID,
            "thumbnail": thumbnail,
            "duration": duration

        ]

    }

}
