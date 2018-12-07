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

        print("snapshot", snapshot)
        print("snapshot.value", snapshot.value)

        guard
            let value = snapshot.value as? [String: Any]
            else { print("snapshot.value as? [String: Any] error")
                return nil
        }

//        print("value", value)
        
//        for (messageID, value) in dictinary {
//            
//            print(messageID)
//            
//            print(value)
//            
//        }
        

        var messageIds: [String] = []

        for messageId in value.keys {

            messageIds.append(messageId)
            print("messageId", messageId)

        }

        guard
            let messageId = value["\(messageIds)"] as? [String: Any]
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
            else{ print("senderDictionary displayName as? String error.")
                return nil
        }

        guard
            let sentDate = value["sentDate"] as? Date
            else { print("value sentDate as? Date error.")
                return nil
        }

        guard
            let content = value["content"] as? String
            else { print("value content as? String error.")
                return nil
        }

        print("content", content)

        self.reference = snapshot.ref
        self.messageId = snapshot.key

        self.sender = Sender(id: senderID, displayName: displayName)
        self.sentDate = sentDate
        self.kind = MessageKind.text(content)

    }

    func saveAnyObjectToFirebase(inputString: String) -> Any {

        return [

            "sender": [
                "senderID": sender.id,
                "displayName": sender.displayName
            ],

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

struct LiveChat {
    
    let chatID: String
    let startTime: Date
    
    var isLive: Bool
    var userQuantity: Int
    
    var message: Message
    var video: Video
    var setting: Setting
    
}
