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
import YouTubePlayer
import NotificationBannerSwift
import Crashlytics

protocol ChatRoomDelegate: AnyObject {

    func manager(_ manager: ChatRoomViewController, didFailWith error: Error)

}

class ChatRoomViewController: UIViewController, YouTubePlayerDelegate {

    static let shared: ChatRoomViewController = ChatRoomViewController()

    weak var delegate: ChatRoomDelegate?

    @IBOutlet weak var videoMainView: UIView!

    @IBOutlet var youtubePlayerView: YouTubePlayerView!

    @IBOutlet weak var containerView: UIView!

    let playerViewController = AVPlayerViewController()

    let userDefault = UserDefaults.standard

    private var messages: [Message] = []

    var timer: Timer?

    var videos: [Video] = []

    var channel: Channel?

    var currentTime: Float = 0

    let videosReference = Database.database().reference(withPath: "videos")

    let channelsReference = Database.database().reference(withPath: "channels")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        playYouTube(videoID: channel.youtubeID)

    }

    // Container View segue
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

    func playYouTube(videoID: String) {

        guard
            let uid = self.userDefault.string(forKey: "userID")
            else { print(UserError.userIDNotFound)
                return
        }

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        youtubePlayerView.delegate = self

        if channel.hostID == uid {

            youtubePlayerView.playerVars = [

                "playsinline": "1",
                "controls": "1"

                ] as YouTubePlayerView.YouTubePlayerParameters

        } else {

            youtubePlayerView.playerVars = [

                "playsinline": "1",
                "controls": "0"

                ] as YouTubePlayerView.YouTubePlayerParameters

            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(guestTapVideoNotification))

            youtubePlayerView.addGestureRecognizer(tapGestureRecognizer)
            youtubePlayerView.isUserInteractionEnabled = true

            guestTapVideoNotification()

        }

        youtubePlayerView.loadVideoID(videoID)

    }

    func playerReady(_ videoPlayer: YouTubePlayerView) {

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        guard
            let uid = self.userDefault.string(forKey: "userID")
            else { print(UserError.userIDNotFound)
                return
        }

        guard
            let currentTime = Float(channel.currentTime)
            else { print("currentTime as Float error")
                return
        }

        print("currentTime", currentTime)

        videoPlayer.seekTo(currentTime, seekAhead: true)

        channelsReference.child(channel.channelID).observe(.value) { (snapshot) in

            guard
                let channelDictionary = snapshot.value as? [String: Any]
                else { print(TypeAsError.snapshotValueAsDictionaryError)
                    return
            }

            guard
                let playerState = channelDictionary["playerState"] as? String
                else { print("playerState as String error.")
                    return
            }

            if channel.hostID == uid {

                NotificationCenter.default.addObserver(self, selector: #selector(self.whenHostTapHomeButtonTwicePauseVideo), name: NSNotification.Name(rawValue: AppDelegate.applicationDidBecomeActive), object: nil)

            } else {

                if playerState == "Playing" {

                    videoPlayer.play()

                } else if playerState == "Paused" {

                    videoPlayer.pause()

                } else if playerState == "Unstarted" {

                    videoPlayer.pause()

                } else if playerState == "Buffering" {

                    videoPlayer.pause()

                } else if playerState == "Ended" {

                    videoPlayer.stop()

                } else if playerState == "Queued" {

                    // Queued

                } else {

                    // Other State

                }

            }

        }

    }

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {

        guard
            let uid = self.userDefault.string(forKey: "userID")
            else { print(UserError.userIDNotFound)
                return
        }

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        guard
            let currentTime = youtubePlayerView.getCurrentTime()
            else { print("currentTime is nil.")
                return
        }

        if channel.hostID == uid {

            if playerState.rawValue == "-1" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Unstarted"])

                self.timer?.invalidate()

                print("Unstarted")

            } else if playerState.rawValue == "0" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Ended"])

                channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

                self.timer?.invalidate()

                print("Ended")

            } else if playerState.rawValue == "1" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Playing"])

                channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

                // MARK: Start Timer - Every 5 seconds upload video currentTime to Firebase database.
                self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.uploadVideoCurrentTime), userInfo: nil, repeats: true)

                print("Playing currentTime:", currentTime)

                print("Playing")

            } else if playerState.rawValue == "2" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Paused"])

                channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

                self.timer?.invalidate()

                print("Paused")

            } else if playerState.rawValue == "3" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Buffering"])

                channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

                self.timer?.invalidate()

                print("Buffering")

            } else if playerState.rawValue == "4" {

                channelsReference.child(channel.channelID).updateChildValues(["playerState": "Queued"])

                channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

                self.timer?.invalidate()

                print("Queued")

            } else {

                self.timer?.invalidate()

                print("Nothing")

            }

        }

    }

    @objc func uploadVideoCurrentTime() {

        guard
            let channel = channel
            else { print("host id is nil.")
                return
        }

        guard
            let currentTime = youtubePlayerView.getCurrentTime()
            else { print("currentTime is nil.")
                return
        }

        channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])
        print("uploadVideoCurrentTime")
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

    @IBAction func refreshTime(_ sender: UIBarButtonItem) {

        youtubePlayerView.seekTo(currentTime, seekAhead: true)

    }

    @objc func guestTapVideoNotification() {

        let banner = NotificationBanner(title: NSLocalizedString("Notification", comment: ""), subtitle: NSLocalizedString("Current Video is control from chat room host.", comment: ""), style: .success)

        banner.show()

    }

    @objc func whenHostTapHomeButtonTwicePauseVideo() {

        guard
            let channel = channel
            else { print("channel is nil.")
                return
        }

        youtubePlayerView.pause()

        channelsReference.child(channel.channelID).updateChildValues(["playerState": "Paused"])

        channelsReference.child(channel.channelID).updateChildValues(["currentTime": currentTime])

        self.timer?.invalidate()

    }

}
