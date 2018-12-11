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

struct Message: MessageType {

    let reference: DatabaseReference?

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
            let snapshotDictionary = snapshot.value as? [String: Any]
            else { print("snapshot.value as? [String: Any] error")
                return nil
        }

        var messageIds: [String] = []

        for messageId in snapshotDictionary.keys {

            messageIds.append(messageId)
            print("messageId", messageId)

        }

        guard
            let messageId = snapshotDictionary["\(messageIds)"] as? [String: Any]
            else { print("value messageId as? [String: Any] error.")
                return nil
        }

        guard
            let senderDictionary = messageId["sender"] as? [String: Any]
            else { print("messageId sender as? [String: Any] error.")
                return nil
        }

        guard
            let senderID = senderDictionary["id"] as? String
            else { print("senderDictionary id as? String error")
                return nil
        }

        guard
            let displayName = senderDictionary["displayName"] as? String
            else { print("senderDictionary displayName as? String error.")
                return nil
        }

        guard
            let sentDate = snapshotDictionary["sentDate"] as? Date
            else { print("value sentDate as? Date error.")
                return nil
        }

        guard
            let content = snapshotDictionary["content"] as? String
            else { print("value content as? String error.")
                return nil
        }

        self.reference = snapshot.ref
        self.messageId = snapshot.key

        self.sender = Sender(id: senderID, displayName: displayName)
        self.sentDate = sentDate
        self.kind = MessageKind.text(content)

    }

    func saveAnyObjectToFirebase(inputString: String) -> Any {

        return [

            "senderID": sender.id,
            "displayName": sender.displayName,
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

struct Setting {

    var title: String
    var type: String
    var password: String?

}

struct LiveChat {

    let chatID: String
    let startTime: Date

    var isLive: Bool
    var userQuantity: Int

    var message: Message
    var video: Video
    var setting: Setting

}
