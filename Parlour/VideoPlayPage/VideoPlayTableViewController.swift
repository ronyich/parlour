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

        tableView.register(UINib(nibName: "VideoOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoOptionTableViewCell")

    }

    // MARK: TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 0: return 1

        case 1: return 1

        default: fatalError("\(TableViewError.invalidSection)")

        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:

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

            } else {

                self.delegate?.manager(self, didFailWith: VideoError.videoIDNotFound)

            }

            cell.selectionStyle = .none

            return cell

        case 1:

            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoOptionTableViewCell", for: indexPath) as? VideoOptionTableViewCell
                else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: TableViewError.cellAsVideoOptionTableViewCellError)))
            }

            cell.liveChatSetting.addTarget(self, action: #selector(liveChatSetting), for: .touchUpInside)

            if let video = video {

                DispatchQueue.main.async {

                    cell.videoTitleLabel.text = video.title

                }

            } else {

                self.delegate?.manager(self, didFailWith: VideoError.videoNotFound)

            }

            cell.selectionStyle = .none

            return cell

        default: fatalError("\(TableViewError.invalidSection)")

        }

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

    @objc func liveChatSetting(button: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard
            let liveChatSettingTableViewController = storyboard.instantiateViewController(withIdentifier: "LiveChatSettingTableViewController") as? LiveChatSettingTableViewController
            else { print("As LiveChatSettingTableViewController error")
                return
        }

        liveChatSettingTableViewController.transitioningDelegate = self

        liveChatSettingTableViewController.modalPresentationStyle = .custom

        present(liveChatSettingTableViewController, animated: true, completion: nil)

    }

}

extension VideoPlayTableViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)

    }

}

class HalfSizePresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {

        get {

            guard let theView = containerView else {

                return CGRect.zero

            }

            return CGRect(x: 0, y: theView.bounds.height / 1.9,
                          width: theView.bounds.width,
                          height: theView.bounds.height / 1.9)

        }

    }

}
