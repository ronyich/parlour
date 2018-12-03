//
//  ChatRoomViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/3.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVKit

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var videoMainView: UIView!

    let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        playVideo(videoIdentifier: "gKwN39UwM9Y")

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

        videoMainView.addSubview(playerViewController.view)

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
