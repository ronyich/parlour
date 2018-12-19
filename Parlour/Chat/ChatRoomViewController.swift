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

protocol ChatRoomDelegate: AnyObject {

    func manager(_ manager: ChatRoomViewController, didFailWith error: Error)

}

class ChatRoomViewController: UIViewController {

    static let shared: ChatRoomViewController = ChatRoomViewController()

    weak var delegate: ChatRoomDelegate?

    @IBOutlet weak var videoMainView: UIView!

    @IBOutlet weak var containerView: UIView!

    let playerViewController = AVPlayerViewController()

    let userDefault = UserDefaults.standard

    private var messages: [Message] = []
    private var user = User(uid: "", email: "")

    var timer: Timer?

    var hostVideoCurrentTime = 0

    var videos: [Video] = []

    var channel: Channel?

    var youtubeID: String?

    var hostID: String?

    var chatRoomTitle: String?

    var chatRoomType: String?

    var chatRoomPassword = ""

    let videosReference = Database.database().reference(withPath: "videos")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        // Every 5 seconds upload video currentTime to Firebase database.
        //self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.startStreamingVideo), userInfo: nil, repeats: true)
        // Test video id: gKwN39UwM9Y, streaming: rLMHGjoxJdQ

        videosReference.child(channel.channelID).observe(.value) { (snapshot) in

            guard
                let videoDictionary = snapshot.value as? [String: Any]
                else { print(TypeAsError.snapshotValueAsDictionaryError)
                    return
            }

            guard
                let currentTime = videoDictionary["currentTime"] as? Int
                else { print(TypeAsError.currentTimeAsIntError)
                    return
            }

            guard
                let hostID = videoDictionary["hostID"] as? String
                else { print(VideoError.hotsIDError)
                    return
            }

            guard
                let uid = self.userDefault.string(forKey: "userID")
                else { print(UserError.userIDNotFound)
                    return
            }

            if hostID == uid {

                self.playVideo(youtubeVideoIdentifier: channel.youtubeID, currentTime: currentTime)

                print("hostID == uid")

            } else {

                self.playVideo(youtubeVideoIdentifier: channel.youtubeID, currentTime: currentTime)

                print("hostID != uid")

            }

        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Go_To_ChatViewController" {

            guard
                let chatViewController = segue.destination as? ChatViewController
                else { print("segue as ChatViewController error")
                    return
            }

            chatViewController.channel = channel

        } else {

            print("segue id error.")

        }

    }

    func playVideo(youtubeVideoIdentifier: String?, currentTime: Int) {

        XCDYouTubeClient.default().getVideoWithIdentifier(youtubeVideoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                streamURLs[YouTubeVideoQuality.medium360] ??
                streamURLs[YouTubeVideoQuality.small240]) {

                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()
                playerViewController?.player?.seek(to: CMTime(seconds: Double(currentTime), preferredTimescale: 1 ))

            } else {

                //self.dismiss(animated: true, completion: nil)

                print("streamURLs is nil:\(String(describing: error?.localizedDescription))")

            }

        }

        playerViewControllerConstraint()

    }

    func playerViewControllerConstraint() {

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

    @objc func startStreamingVideo() {

//        guard
//            let uid = Auth.auth().currentUser?.uid
//            else { self.delegate?.manager(self, didFailWith: UserError.userIDNotFound)
//                return
//        }
//
//        guard
//            let hostID = self.hostID
//            else { print("host id is nil.")
//                return
//        }
//
//        guard let youtubeID = self.youtubeID
//            else { print("YoutubeID is nil.")
//                return
//        }
//
//        guard
//            let title = chatRoomTitle
//            else { print("title is nil.")
//                return
//        }
//
//        guard
//            let type = chatRoomType
//            else { print("type is nil.")
//                return
//        }
//
//        let videoCurrentTimeOfSeconds = playerViewController.player?.currentTime().seconds ?? 0
//
//        let currentTime: Int = Int(videoCurrentTimeOfSeconds)
//
//        // MARK: editing...
//        let videoItem = VideoControl(videoID: youtubeID, nextVideoID: "nextVideoID", title: title, type: type, password: chatRoomPassword, isLive: "YES", currentTime: currentTime, hostID: uid)
//
//        videosReference.child(hostID).setValue(videoItem.saveVideoControlObjectToFirebase())

    }

    @IBAction func logOutToLoginView(_ sender: UIBarButtonItem) {

        do {

            try Auth.auth().signOut()
            self.dismiss(animated: true)

        } catch {

            let alert = UIAlertController(title: "Logout Error.",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel)

            alert.addAction(okAction)

        }

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
