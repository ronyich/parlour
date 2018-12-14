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

    private var messages: [Message] = []
    private var user = User(uid: "", email: "")

    var timer: Timer?

    var hostVideoCurrentTime = 0

    var videos: [Video] = []

    let hostID = "6uifs7BtpjfB8T4KhqW2Lc98whF2"

    let videosReference = Database.database().reference(withPath: "videos")

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let uid = Auth.auth().currentUser?.uid
            else { self.delegate?.manager(self, didFailWith: UserError.userIDNotFound)
                return
        }

        self.tabBarController?.tabBar.isHidden = true

        videosReference.child(hostID).queryOrdered(byChild: "currentTime").observeSingleEvent(of: .value) { (snapshot) in

            guard let videoDictionary = snapshot.value as? [String: Any]
                else { self.delegate?.manager(self, didFailWith: TypeAsError.snapshotValueAsDictionaryError)
                    return
            }

            guard let currentTime = videoDictionary["currentTime"] as? Int
                else { self.delegate?.manager(self, didFailWith: TypeAsError.currentTimeAsIntError)
                    return
            }

            print("currentTime", currentTime)

            if uid == self.hostID {

                // Test video id: gKwN39UwM9Y, streaming: rLMHGjoxJdQ
                self.playVideo(youtubeVideoIdentifier: "gKwN39UwM9Y", currentTime: currentTime)

                // Every 5 seconds upload video currentTime to Firebase database.
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.startStreamingVideo), userInfo: nil, repeats: true)

            } else {

                self.playVideo(youtubeVideoIdentifier: "gKwN39UwM9Y", currentTime: currentTime)

            }

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

                self.dismiss(animated: true, completion: nil)

                print("streamURLs is nil:\(String(describing: error?.localizedDescription))")

            }

        }

        playerViewControllerConstraint()

    }

    // MARK: editing...
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//
//        if keyPath == "seconds" {
//            print("seconds is change")
//        }
//    }

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

        guard
            let uid = Auth.auth().currentUser?.uid
            else { self.delegate?.manager(self, didFailWith: UserError.userIDNotFound)
                return
        }

        guard
            let videoCurrentTimeOfSeconds = playerViewController.player?.currentTime().seconds
            else { self.delegate?.manager(self, didFailWith: VideoError.currentTimeError)
                return
        }

        let currentTime: Int = Int(videoCurrentTimeOfSeconds)

        // MARK: editing...
        let videoItem = VideoControl(nextVideoID: "hostID: String", currentTime: currentTime, hostID: uid)

        videosReference.child(uid).setValue(videoItem.saveVideoControlObjectToFirebase())

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
