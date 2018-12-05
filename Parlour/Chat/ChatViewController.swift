//
//  ViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/4.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class ChatViewController: MessagesViewController {

    var messages: [Message] = []
    var sender = Sender(id: "", displayName: "")

    var user: User?

    @IBOutlet weak var inputMessageTextField: UITextField!

    @IBOutlet weak var sendMessage: UIButton!

    @IBOutlet weak var contentView: UIView!

    let database = Database.database()

    let channelsReference = Database.database().reference(withPath: "channels")

    let messageReference = Database.database().reference(withPath: "message")

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.addSubview(messagesCollectionView)

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageReference.childByAutoId().queryOrdered(byChild: "content").observe(.value) { (snapshot) in

            var newItems: [Message] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot,
                    let messageItem = Message(snapshot: snapshot) {

                    newItems.append(messageItem)

                } else {

                    print("snapshot child can't as DataSnapshot.")

                }

            }

            self.messages = newItems
            self.messagesCollectionView.reloadData()

        }

    }

    @IBAction func addNewMessageDidTouch(_ sender: UIButton) {

        guard
            let uid = Auth.auth().currentUser?.uid
            else { print("currentUser uid is nil.")
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { print("displayName is nil.")
                return
        }

        guard
            let inputText = inputMessageTextField.text
            else { print("inputText is nil.")
                return
        }

        let messageItemReference = messageReference.childByAutoId()

        guard
            let messageId = messageItemReference.key
            else { print("messageId is nil.")
                return
        }

        let messageItem = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageId, sentDate: Date(), kind: .text(inputText))

        messageItemReference.setValue(messageItem.saveAnyObjectToFirebase(inputString: inputText))

        messages.append(messageItem)
        messagesCollectionView.reloadData()

        print("messages", self.messages)
    }

//        private func insertNewMessage(_ message: Message) {
//
//            guard !messages.contains(message)
//                else { print("message is nil.")
//                    return
//            }
//
//            print("in insertNewMessage")
//            messages.append(message)
//            messages.sort()
//
//            let isLatestMessage = messages.index(of: message) == (messages.count - 1)
//            let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
//
//            messagesCollectionView.reloadData()
//
//            if shouldScrollToBottom {
//
//                DispatchQueue.main.async {
//
//                    self.messagesCollectionView.scrollToBottom(animated: true)
//
//                }
//
//            }
//
//        }

}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> Sender {

        return sender

    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]

    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count

    }

}

extension ChatViewController: MessagesDisplayDelegate {

}

extension ChatViewController: MessagesLayoutDelegate {

}
