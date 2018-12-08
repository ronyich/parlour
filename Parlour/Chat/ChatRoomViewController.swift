//
//  ChatRoomViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/3.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import XCDYouTubeKit
import AVKit

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var videoMainView: UIView!

    @IBOutlet weak var containerView: UIView!

    let playerViewController = AVPlayerViewController()

    private var messages: [Message] = []
    private let user = User(uid: "", email: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        playVideo(videoIdentifier: "rLMHGjoxJdQ")

        self.tabBarController?.tabBar.isHidden = true

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
            equalTo: videoMainView.leadingAnchor, constant: 0).isActive = true
        playerViewController.view.topAnchor.constraint(
            equalTo: videoMainView.topAnchor, constant: 0).isActive = true
        playerViewController.view.trailingAnchor.constraint(
            equalTo: videoMainView.trailingAnchor, constant: 0).isActive = true
        playerViewController.view.bottomAnchor.constraint(
            equalTo: videoMainView.bottomAnchor, constant: 0).isActive = true

    }

}

// MARK: MessagesDataSource
//extension ChatRoomViewController: MessagesDataSource {
//
//    func currentSender() -> Sender {
//
//        if let uid = Auth.auth().currentUser?.uid,
//            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(),
//            let displayName = changeRequest.displayName {
//
//            return Sender(id: uid, displayName: displayName)
//
//        } else {
//
//            print("uid or displayName is nil.")
//
//        }
//
//        return Sender(id: "default", displayName: "default")
//
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//        return messages[indexPath.section]
//
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//
//        return messages.count
//
//    }

//    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
//
//        return
//
//    }

//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        let name = message.sender.displayName
//
//        return NSAttributedString(string: name,
//                                  attributes: [
//                                    .font: UIFont.preferredFont(forTextStyle: .caption1),
//                                    .foregroundColor: UIColor(white: 0.3, alpha: 1)
//            ]
//
//        )
//
//    }

//}

// MARK: MessagesLayoutDelegate
//extension ChatRoomViewController: MessagesLayoutDelegate {

//    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//        return .zero
//
//    }
//
//    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//        return CGSize(width: 0, height: 8)
//
//    }
//
//    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//        return 0
//
//    }

//}

// MARK: MessagesDisplayDelegate
//extension ChatRoomViewController: MessagesDisplayDelegate {
//
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//
//        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
//
//    }
//
//    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
//                             in messagesCollectionView: MessagesCollectionView) -> Bool {
//
//        return false
//
//    }
//
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//
//        return .bubbleTail(corner, .curved)
//
//    }

//}
