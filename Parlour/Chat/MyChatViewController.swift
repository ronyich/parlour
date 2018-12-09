//
//  MyChatViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/9.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import MessageInputBar
import AVKit
import XCDYouTubeKit

protocol MyChatDelegate: AnyObject {

    func manager(_ manager: MyChatViewController, didFailWith error: Error)
}

enum MyErrorMessage: Error {

    case userIDNotFound, displayNameNotFound, snapshotValueAsDictionaryError, messageValueAsDictionaryError, messageContentAsStringError, messageIdNotFound

}

class MyChatViewController: MessagesViewController {

    var messages: [Message] = []

    var sender = Sender(id: "", displayName: "")

    weak var delegate: MyChatDelegate?

    let channelReference = Database.database().reference(withPath: "channel")

    let messageReference = Database.database().reference(withPath: "channel/message")

    let playerViewController = AVPlayerViewController()

    @IBOutlet weak var videoPlayerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.backgroundColor = .lightGray
//        messagesCollectionView.addSubview(videoPlayerView)

        messageInputBar.delegate = self

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        messagesCollectionView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: 0).isActive = true
        messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        messagesCollectionView.heightAnchor.constraint(equalToConstant: 437).isActive = true
        messagesCollectionView.widthAnchor.constraint(equalToConstant: 375).isActive = true

        playVideo(videoIdentifier: "rLMHGjoxJdQ")

        channelReference.queryOrdered(byChild: "sentDate").observe(.value) { (snapshot) in

            var newMessages: [Message] = []

            guard
                let uid = Auth.auth().currentUser?.uid
                else { fatalError()
            }

            guard
                let displayName = Auth.auth().currentUser?.displayName
                else { fatalError()
            }

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot {

                    guard
                        let dictionary = snapshot.value as? [String: Any]
                        else { self.delegate?.manager(self, didFailWith: MyErrorMessage.snapshotValueAsDictionaryError)
                            return
                    }

                    print("dictionary", dictionary)

                    for (messageID, messageValue) in dictionary {

                        print("messageID", messageID)

                        guard
                            let messageDictionary = messageValue as? [String: Any]
                            else { self.delegate?.manager(self, didFailWith: MyErrorMessage.messageValueAsDictionaryError)
                                return
                        }

                        guard
                            let content = messageDictionary["content"] as? String
                            else { self.delegate?.manager(self, didFailWith: MyErrorMessage.messageContentAsStringError)
                                return
                        }

                        print("content", content)

                        let message = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageID, sentDate: Date(), kind: .text(content))

                        newMessages.append(message)

                    }

                }

            }

            DispatchQueue.main.async {

//                let sortMessages = newMessages.sorted { $0.sentDate < $1.sentDate }

                self.messages = newMessages

                print("sortMessages", newMessages)

                self.messagesCollectionView.reloadData()

                self.messagesCollectionView.scrollToBottom(animated: true)

            }

        }

    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        if action == NSSelectorFromString("delete:") {

            return true

        } else {

            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)

        }

    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        if action == NSSelectorFromString("delete:") {

            channelReference.child("message").child(messages[indexPath.section].messageId).removeValue()

            messages.remove(at: indexPath.section)

            collectionView.deleteSections([indexPath.section])

            collectionView.reloadData()

        } else {

            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)

        }

    }

    func playVideo(videoIdentifier: String?) {

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                streamURLs[YouTubeVideoQuality.medium360] ??
                streamURLs[YouTubeVideoQuality.small240]) {

                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()
                playerViewController?.player?.currentTime()
                playerViewController?.allowsPictureInPicturePlayback = true

            } else {

                self.dismiss(animated: true, completion: nil)

                print("streamURLs is nil:\(String(describing: error?.localizedDescription))")

            }

        }

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(playerViewController.view)

        playerViewController.view.leadingAnchor.constraint(
            equalTo: videoPlayerView.leadingAnchor, constant: 0).isActive = true
        playerViewController.view.topAnchor.constraint(
            equalTo: videoPlayerView.topAnchor, constant: 0).isActive = true
        playerViewController.view.trailingAnchor.constraint(
            equalTo: videoPlayerView.trailingAnchor, constant: 0).isActive = true
        playerViewController.view.bottomAnchor.constraint(
            equalTo: videoPlayerView.bottomAnchor, constant: 0).isActive = true

    }

    func messagesCollectionViewConstraint() {

        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        messagesCollectionView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor,
                                                    constant: 0).isActive = true

        messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                       constant: 0).isActive = true

        messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: 0).isActive = true

        messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: 0).isActive = true

        messagesCollectionView.heightAnchor.constraint(equalToConstant: 437).isActive = true
        messagesCollectionView.widthAnchor.constraint(equalToConstant: 375).isActive = true

    }

}

extension MyChatViewController: MessagesDataSource {

    func currentSender() -> Sender {

        guard
            let uid = Auth.auth().currentUser?.uid
            else { fatalError("\(MyErrorMessage.userIDNotFound)")
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { fatalError("\(MyErrorMessage.displayNameNotFound)")
        }

        let sender = Sender(id: uid, displayName: displayName)

        return sender

    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]

    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count

    }

}

extension MyChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {

        guard
            let uid = Auth.auth().currentUser?.uid
            else { self.delegate?.manager(self, didFailWith: MyErrorMessage.userIDNotFound)
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { self.delegate?.manager(self, didFailWith: MyErrorMessage.displayNameNotFound)
                return
        }

        let messageItemReference = messageReference.childByAutoId()

        guard
            let messageId = messageItemReference.key
            else { self.delegate?.manager(self, didFailWith: MyErrorMessage.messageIdNotFound)
                return
        }

        let messageItem = Message(sender: Sender(id: uid, displayName: displayName), messageId: messageId, sentDate: Date(), kind: .text(inputBar.inputTextView.text))

        messageItemReference.setValue(messageItem.saveAnyObjectToFirebase(inputString: inputBar.inputTextView.text))

        inputBar.inputTextView.text = ""

        messages.append(messageItem)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)

        print("messages", self.messages)
    }

}

extension MyChatViewController: MessagesDisplayDelegate {

}

extension MyChatViewController: MessagesLayoutDelegate {

}

extension MessageCollectionViewCell {

    override open func delete(_ sender: Any?) {

        guard
            let collectionView = self.superview as? UICollectionView
            else { print("self.subviews as? UICollectionView error.")
            return
        }

        guard
            let indexPath = collectionView.indexPath(for: self)
            else { print("collectionView.indexPath(for: self) error.")
                return
        }

        collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
    }

}
