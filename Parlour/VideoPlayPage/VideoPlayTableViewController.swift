//
//  VideoPlayTableViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/14.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import AVKit
import XCDYouTubeKit

protocol VideoPlayDelegate: AnyObject {

    func manager(_ manager: VideoPlayTableViewController, didFailWith error: Error)

}

class VideoPlayTableViewController: UITableViewController {

    weak var delegate: VideoPlayDelegate?

    var video: Video?

    var videos: [Video] = []

    let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "VideoPlayTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPlayTableViewCell")

        print("videosInVideoPlayTableViewController", videos)

    }

    // MARK: TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayTableViewCell", for: indexPath) as? VideoPlayTableViewCell
            else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: TableViewError.cellAsVideoPlayTableViewCellError)))
        }

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        cell.videoMainView.addSubview(playerViewController.view)

        playerViewController.view.leadingAnchor.constraint(
            equalTo: cell.videoMainView.leadingAnchor,
            constant: 0).isActive = true
        playerViewController.view.topAnchor.constraint(
            equalTo: cell.videoMainView.topAnchor,
            constant: 0).isActive = true
        playerViewController.view.trailingAnchor.constraint(
            equalTo: cell.videoMainView.trailingAnchor,
            constant: 0).isActive = true
        playerViewController.view.bottomAnchor.constraint(
            equalTo: cell.videoMainView.bottomAnchor,
            constant: 0).isActive = true

        if let video = video {

            playVideo(youtubeVideoIdentifier: video.videoID)

            cell.videoTitleLabel.text = video.title

        } else {

            self.delegate?.manager(self, didFailWith: VideoError.videoIDNotFound)

        }

        return cell

    }

    func playVideo(youtubeVideoIdentifier: String?) {

        XCDYouTubeClient.default().getVideoWithIdentifier(youtubeVideoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                streamURLs[YouTubeVideoQuality.medium360] ??
                streamURLs[YouTubeVideoQuality.small240]) {

                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()

            } else {

                self.dismiss(animated: true, completion: nil)

                print("streamURLs is nil:\(String(describing: error?.localizedDescription))")

            }

        }

    }

}
