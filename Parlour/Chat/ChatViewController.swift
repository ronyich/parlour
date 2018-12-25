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
import Crashlytics

class ChatViewController: UIViewController {

    let messagesViewController = MessagesViewController()

    var messages: [Message] = []

    var sender: Sender?

    var user: User?

    var channel: Channel?

    let userDefault = UserDefaults.standard

    @IBOutlet weak var inputMessageTextField: UITextField!

    @IBOutlet weak var contentView: UIView!

    let chatsReference = Database.database().reference(withPath: "chats")

//    override var inputAccessoryView: UIView? {
//        return messagesViewController.inputAccessoryView
//    }
//    override var canBecomeFirstResponder: Bool {
//        return messagesViewController.canBecomeFirstResponder
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(messagesViewController)

        messagesViewController.messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(messagesViewController.view)

        // ????????
        //contentView.addSubview(messagesViewController.messagesCollectionView)

        messagesCollectionViewInMessagesViewControllerConfigure()

        messagesViewController.didMove(toParent: self)

        messagesViewController.messagesCollectionView.backgroundColor = .lightGray

        messagesViewController.messagesCollectionView.messagesDataSource = self
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = self
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = self

        //messagesViewController.messageInputBar.delegate = self

        guard
            let hostID = userDefault.string(forKey: "userID")
            else { print("hostID is nil in ChatViewController")
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { print(UserError.displayNameNotFound)
                return
        }

        self.sender = Sender(id: hostID, displayName: displayName)

        guard
            let channel = channel
            else { print("channel is nil")
                return
        }

        // For get messageId, display firebase data ,not add child("message") folder
        chatsReference.child(channel.channelID).queryOrdered(byChild: "sentDate").observe(.value) { (snapshot) in

            var newMessages: [Message] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot {

                    guard
                        let dictionary = snapshot.value as? [String: Any]
                        else { print(TypeAsError.snapshotValueAsDictionaryError)
                            return
                    }

                    for (messageID, messageValue) in dictionary {

                        guard
                            let messageDictionary = messageValue as? [String: Any]
                            else { print(TypeAsError.messageValueAsDictionaryError)
                                return
                        }

                        guard
                            let content = messageDictionary["content"] as? String
                            else { print(TypeAsError.messageContentAsStringError)
                                return
                        }

                        guard
                            let sentDateString = messageDictionary["sentDate"] as? String
                            else { print(TypeAsError.messageSentDateAsStringError)
                                return
                        }

                        guard
                            let uid = messageDictionary["senderID"] as? String
                            else { print(TypeAsError.messageSenderIDAsStringError)
                                return
                        }

                        guard
                            let displayName = messageDictionary["displayName"] as? String
                            else { print(TypeAsError.messageDisplayNameAsStringError)
                                return
                        }

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss +zzzz"

                        guard
                            let sentDate: Date = dateFormatter.date(from: sentDateString)
                            else { print(TypeAsError.stringAsDateError)
                                return
                        }

                        self.sender = Sender(id: uid, displayName: displayName)

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

    func messagesCollectionViewInMessagesViewControllerConfigure() {

        messagesViewController.messagesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

        messagesViewController.messagesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMessagesCollectionViewToEndEditing))

        messagesViewController.messagesCollectionView.addGestureRecognizer(tapGesture)

    }

    @IBAction func addNewMessageDidTouch(_ sender: UIButton) {

        guard
            let uid = Auth.auth().currentUser?.uid
            else { print(UserError.userIDNotFound)
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { print(UserError.displayNameNotFound)
                return
        }

        guard
            let inputText = inputMessageTextField.text
            else { print(MessageError.messageInputTextError)
                return
        }

        guard
            let channel = channel
            else { print("channel is nil")
                return
        }

        // For get messageId, add child("message") folder.
        let messageItemReference = chatsReference.child(channel.channelID).child("message").childByAutoId()

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

        Analytics.logEvent("Add_New_Message_Did_Touch", parameters: nil)

    }

    @objc func tapMessagesCollectionViewToEndEditing() {

        inputMessageTextField.endEditing(true)

    }

}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {

    func currentSender() -> Sender {

        guard
            let currentSender = sender
            else { fatalError("currentSender is nil.")
        }

        return currentSender

    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]

    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count

    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        let displayName = self.messages[indexPath.section].sender.displayName

        return NSAttributedString(string: displayName, attributes: [.font: UIFont.systemFont(ofSize: 12)])

    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 12

    }

}

extension ChatViewController: MessagesDisplayDelegate {

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        avatarView.backgroundColor = .lightGray
    }

}

extension ChatViewController: MessagesLayoutDelegate {

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 0

    }

}
