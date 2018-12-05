//
//  LiveChat.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/29.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

struct LiveChat {

    let chatID: String
    let startTime: Date

    var isLive: Bool
    var userQuantity: Int

    var message: Message
    var video: Video
    var setting: Setting

}

struct Message: MessageType {

    let reference: DatabaseReference?
//    let key: String

    var sender: Sender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    init(sender: Sender, messageId: String, sentDate: Date, kind: MessageKind) {

        self.reference = nil

        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind

    }

    init?(snapshot: DataSnapshot) {

        guard
            let value = snapshot.value as? [String: AnyObject],
            let sender = value["sender"] as? Sender,
            let sentDate = value["sentDate"] as? Date,
            let kind = value["kind"] as? MessageKind
            else { print("Message init? property error.")
            return nil

        }

        self.reference = snapshot.ref
        self.messageId = snapshot.key

        self.sender = sender
        self.sentDate = sentDate
        self.kind = kind

    }

    func saveAnyObjectToFirebase(inputString: String) -> Any {

        return [

            "sender": [
                "senderID": sender.id,
                "senderName": sender.displayName
            ],

            "messageId": messageId,
            "sentDate": sentDate.description,
            "content": inputString

        ]

    }

}

extension Message: Comparable {

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }

}

struct Video {

    var videoID: String

}

struct Setting {

    var title: String
    var type: String
    var password: String?

}
