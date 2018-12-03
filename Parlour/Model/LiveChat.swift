//
//  LiveChat.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/29.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase

struct LiveChat {

    let chatID: String
    let startTime: Date

    var isLive: Bool
    var userQuantity: Int

    var message: Message
    var video: Video
    var setting: Setting

}

struct Message {

    var sender: String
    var messageBody: String
    var sendTime: Date

}

struct Video {

    var videoID: String

}

struct Setting {

    var title: String
    var type: String
    var password: String?

}
