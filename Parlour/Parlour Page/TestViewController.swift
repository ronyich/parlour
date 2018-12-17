//
//  TestViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/30.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var videoMainView: UIView!

    let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        videoMainView.addSubview(playerViewController.view)

        playerViewController.view.leadingAnchor.constraint(equalTo: videoMainView.leadingAnchor, constant: 0).isActive = true
        playerViewController.view.topAnchor.constraint(equalTo: videoMainView.topAnchor, constant: 0).isActive = true
        playerViewController.view.trailingAnchor.constraint(equalTo: videoMainView.trailingAnchor, constant: 0).isActive = true
        playerViewController.view.bottomAnchor.constraint(equalTo: videoMainView.bottomAnchor, constant: 0).isActive = true

        playVideo(videoIdentifier: "tCXGJQYZ9JA")

    }

    func playVideo(videoIdentifier: String?) {

        //self.present(playerViewController, animated: true, completion: nil)

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                 streamURLs[YouTubeVideoQuality.medium360] ??
                 streamURLs[YouTubeVideoQuality.small240]) {

                playerViewController?.player = AVPlayer(url: streamURL)
                //playerViewController?.player?.play()
                playerViewController?.player?.currentTime()
                playerViewController?.allowsPictureInPicturePlayback = true

                //playerViewController?.player = AVQueuePlayer(playerItem: AVPlayerItem(asset: AVAsset(url: streamURL), automaticallyLoadedAssetKeys: ["Q0AULj4UltI","gKwN39UwM9Y"]))

                print("video property",
                      video?.title,
                      video?.duration,
                      video?.thumbnailURL,
                      video?.captionURLs,
                      video?.identifier,
                      playerViewController?.player?.currentTime()
                      )

            } else {

                self.dismiss(animated: true, completion: nil)

                print("streamURLs is nil:\(String(describing: error?.localizedDescription))")

            }

        }

    }

}

extension HomePageViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }
}

extension HomePageViewController: AVPlayerViewControllerDelegate {

//    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
//
//        playerViewController.delegate = self
//        return false
//
//    }

}
