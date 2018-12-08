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

enum ErrorMessage: Error {

    case userIDNotFound, displayNameNotFound, snapshotValueAsDictionaryError, messageValueAsDictionaryError, messageContentAsStringError

}

class MyChatViewController: MessagesViewController, MessageInputBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

//        messageInputBar.delegate = self
    }

}

class ChatViewController: UIViewController {

    weak var delegate: ChatDelegate?

//    @IBOutlet weak var messagesCollectionView: MessagesCollectionView!

    let messagesViewController = MessagesViewController()

    var messages: [Message] = []

    var messageIds: [String] = []

    var sender = Sender(id: "", displayName: "")

    var user: User?

    @IBOutlet weak var inputMessageTextField: UITextField!

    @IBOutlet weak var sendMessage: UIButton!

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
//        contentView.addSubview(messagesViewController.messagesCollectionView)

        messagesCollectionViewInMessagesViewControllerConstraint()

        messagesViewController.didMove(toParent: self)

        messagesViewController.messagesCollectionView.backgroundColor = .lightGray

        messagesViewController.messagesCollectionView.messagesDataSource = self
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = self
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = self

        guard
            let uid = Auth.auth().currentUser?.uid
            else { self.delegate?.manager(self, didFailWith: ErrorMessage.userIDNotFound)
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { self.delegate?.manager(self, didFailWith: ErrorMessage.displayNameNotFound)
                return
        }

        self.sender = Sender(id: uid, displayName: displayName)

        //let channelReference = Database.database().reference(withPath: "channel")
        channelReference.queryOrdered(byChild: "message").observe(.value) { (snapshot) in

            var newMessages: [Message] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot {

                    guard
                        let dictionary = snapshot.value as? [String: Any]
                        else { self.delegate?.manager(self, didFailWith: ErrorMessage.snapshotValueAsDictionaryError)
                            return
                    }

                    for (messageID, messageValue) in dictionary {

                        print("messageID", messageID)

                        guard
                            let messageDictionary = messageValue as? [String: Any]
                            else { self.delegate?.manager(self, didFailWith: ErrorMessage.messageValueAsDictionaryError)
                                return
                        }

                        guard
                            let content = messageDictionary["content"] as? String
                            else { self.delegate?.manager(self, didFailWith: ErrorMessage.messageContentAsStringError)
                                return
                        }

                        print("content", content)

                        let message = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageID, sentDate: Date(), kind: .text(content))

                        newMessages.append(message)

                    }

                }

            }

            let sortMessages = newMessages.sorted { $0.sentDate.description < $1.sentDate.description }

            print("sortMessages", sortMessages)
            DispatchQueue.main.async {

//                print("sortMessages2", sortMessages)
                self.messages = newMessages

                print("self.messages.count", self.messages.count)

                self.messagesViewController.messagesCollectionView.reloadData()

            }

        }

    }

    func messagesCollectionViewInMessagesViewControllerConstraint() {

        messagesViewController.messagesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true

    }

//    func fetchMessage() {

//        guard
//            let channelID = channelReferenceAutoIdKey
//            else { print("channelReferenceAutoID is nil.")
//                return
//        }
//        channelReference.child(channelPassword).childByAutoId().observeSingleEvent(of: .value) { (snapshot) in
//
//            print("snapshot", snapshot.value)
//            if let dictionary = snapshot.value as? [ String: AnyObject ] {
//
//                guard
//                    let message = dictionary["message"]
//                    else { print("dictionary[message] is nil.")
//                        return
//                }
//
//                guard
//                    let key = self.messageReference.key
//                    else { print("messageReference.key is nil.")
//                        return
//                }
//
//                guard
//                    let messageId = message["\(key)"] as? Message
//                    else { print("messageId as Message error.")
//                        return
//                }
//
//                self.messages.append(messageId)
//
//                print("dictionary", dictionary)
//                print("snapshot", snapshot)
//                print("messageArray", message)
//                print("messageId", messageId)
//
//            } else {
//
//                print("snapshot.value as? [ String: AnyObject ] error.")
//
//            }
//
//        }
//    }

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

        print("messages[indexPath.section]", messages[indexPath.section])

        let sortMessages = messages.sorted(by: { $0.sentDate.description > $1.sentDate.description })

//        print("sortMessages", sortMessages)
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
