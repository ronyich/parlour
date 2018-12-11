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
import MessageInputBar

protocol ChatDelegate: AnyObject {

    func manager(_ manager: ChatViewController, didFailWith error: Error)
}

class ChatViewController: UIViewController {

    weak var delegate: ChatDelegate?

//    @IBOutlet weak var messagesCollectionView: MessagesCollectionView!

    let messagesViewController = MessagesViewController()

    var messageInputBar = MessageInputBar()

    var messages: [Message] = []

    var messageIds: [String] = []

    var sender = Sender(id: "", displayName: "")

    var user: User?

    @IBOutlet weak var inputMessageTextField: UITextField!

    @IBOutlet weak var contentView: UIView!

    let database = Database.database()

    let channelReference = Database.database().reference(withPath: "channel")

    let messageReference = Database.database().reference(withPath: "channel/message")

    let channelReferenceAutoIdKey = Database.database().reference(withPath: "channel").childByAutoId().key

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(messagesViewController)

        messagesViewController.messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(messagesViewController.view)

        // ????????
        //contentView.addSubview(messagesViewController.messagesCollectionView)

        messagesCollectionViewInMessagesViewControllerConstraint()

        messagesViewController.didMove(toParent: self)

        messagesViewController.messagesCollectionView.backgroundColor = .lightGray

        messagesViewController.messagesCollectionView.messagesDataSource = self
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = self
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = self

        //messageInputBar.delegate = self

        guard
            let uid = Auth.auth().currentUser?.uid
            else { self.delegate?.manager(self, didFailWith: UserError.userIDNotFound)
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { self.delegate?.manager(self, didFailWith: UserError.displayNameNotFound)
                return
        }

//        channelReference.child("message").queryOrdered(byChild: "sentDate").observeSingleEvent(of: .value) { (snapshot) in
//
//            print("snapshot.children", snapshot.children)
//            print("snapshot.value", snapshot.value)
//
//            guard
//                let dictionary = snapshot.value as? [String: Any]
//                else { self.delegate?.manager(self, didFailWith: ErrorMessage.snapshotValueAsDictionaryError)
//                    return
//            }
//
//            print("dictionary", dictionary)
//
//            var newMessages: [Message] = []
//
//            for (messageID, messageBody) in dictionary {
//
//                guard
//                    let messageDictionary = messageBody as? [String: Any]
//                    else { self.delegate?.manager(self, didFailWith: ErrorMessage.messageContentAsStringError)
//                        return
//                }
//
//                guard
//                    let content = messageDictionary["content"] as? String
//                    else { self.delegate?.manager(self, didFailWith: ErrorMessage)
//                        return
//                }
//
//                let message = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageID, sentDate: Date(), kind: .text(content))
//
//                newMessages.append(message)
//            }
//
//            self.messages = newMessages
//
//        }

        self.sender = Sender(id: uid, displayName: displayName)

        channelReference.queryOrdered(byChild: "sentDate").observe(.value) { (snapshot) in

            var newMessages: [Message] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot {

                    guard
                        let dictionary = snapshot.value as? [String: Any]
                        else { self.delegate?.manager(self, didFailWith: TypeAsError.snapshotValueAsDictionaryError)
                            return
                    }

                    for (messageID, messageValue) in dictionary {

                        guard
                            let messageDictionary = messageValue as? [String: Any]
                            else { self.delegate?.manager(self, didFailWith: TypeAsError.messageValueAsDictionaryError)
                                return
                        }

                        guard
                            let content = messageDictionary["content"] as? String
                            else { self.delegate?.manager(self, didFailWith: TypeAsError.messageContentAsStringError)
                                return
                        }

                        guard
                            let sentDateString = messageDictionary["sentDate"] as? String
                            else { self.delegate?.manager(self, didFailWith: TypeAsError.messageSentDateAsStringError)
                                return
                        }

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss +zzzz"

                        guard
                            let sentDate: Date = dateFormatter.date(from: sentDateString)
                            else { self.delegate?.manager(self, didFailWith: TypeAsError.stringAsDateError)
                                return
                        }

                        let message = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageID, sentDate: sentDate, kind: .text(content))

                        newMessages.append(message)

                    }

                }

            }

            DispatchQueue.main.async {

                let sortMessages = newMessages.sorted { $0.sentDate < $1.sentDate }

                self.messages = sortMessages

                self.messagesViewController.messagesCollectionView.reloadData()
                self.messagesViewController.messagesCollectionView.scrollToBottom()

            }

        }

    }

    func messagesCollectionViewInMessagesViewControllerConstraint() {

        messagesViewController.messagesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true

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

        inputMessageTextField.text = ""

        messages.append(messageItem)
        messagesViewController.messagesCollectionView.reloadData()
        messagesViewController.messagesCollectionView.scrollToBottom()

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

// MARK: - MessagesDataSource
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

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //...editing
    }
}
