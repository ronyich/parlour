//
//  TestViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/30.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import XCDYouTubeKit
import AVKit
import MessageKit

class ParlourViewController: UIViewController {

    @IBOutlet weak var videoMainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoMainImageView: UIImageView!

    let playerViewController = AVPlayerViewController()
    let video = XCDYouTubeVideo()

    override func viewDidLoad() {
        super.viewDidLoad()

        getVideothumbnail(videoIdentifier: "gKwN39UwM9Y")

        playVideo(videoIdentifier: "gKwN39UwM9Y")

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(goToChatView))

        videoMainImageView.addGestureRecognizer(tapGestureRecognizer)
        videoMainImageView.isUserInteractionEnabled = true

    }

    func playVideo(videoIdentifier: String?) {

        //self.present(playerViewController, animated: true, completion: nil)

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                 streamURLs[YouTubeVideoQuality.medium360] ??
                 streamURLs[YouTubeVideoQuality.small240]) {

                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()
                playerViewController?.player?.currentTime()

                //playerViewController?.player = AVQueuePlayer(playerItem: AVPlayerItem(asset: AVAsset(url: streamURL), automaticallyLoadedAssetKeys: ["Q0AULj4UltI","gKwN39UwM9Y"]))

                print("video control:",
                      playerViewController?.player?.play(),
                      playerViewController?.player?.status,
                      playerViewController?.player?.pause())
                
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

    func getVideothumbnail(videoIdentifier: String?) {

        XCDYouTubeClient.default().getVideoWithIdentifier("gKwN39UwM9Y") { (video: XCDYouTubeVideo?, error) in

            guard
                let url = video?.thumbnailURL
                else { print("url is nil.")
                    return
            }
	
            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                guard
                    let data = data
                    else { print("data is nil.")
                        return
                }

                DispatchQueue.main.async {

                    self.videoMainImageView.image = UIImage(data: data)
                    self.videoMainImageView.contentMode = .scaleAspectFit

                }

            }).resume()

        }

    }

    @objc func goToChatView() {

        performSegue(withIdentifier: "Go_To_ChatRoomViewController", sender: self)

    }

    @IBAction func inputYoutubeURLToSettingPage(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Paste Youtube URL", message: "Example: https://youtu.be/nSDgHBxUbVQ", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in

            guard
                let textFieldInputString = alert.textFields?[0].text
                else { print("textFields[0] is nil.")
                    return
            }

            let youtubeURL = textFieldInputString

            let youtubeID = String(youtubeURL.suffix(11))

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard
                let liveChatSettingViewController = storyboard.instantiateViewController(withIdentifier: "LiveChatSettingViewController") as? LiveChatSettingViewController
                else { print("As LiveChatSettingViewController error")
                    return
            }

            liveChatSettingViewController.youtubeID = youtubeID

            self.present(liveChatSettingViewController, animated: true, completion: nil)

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

    }

}

extension ParlourViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 1

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoMainViewCollectionViewCell", for: indexPath) as? VideoMainCollectionViewCell else {
                fatalError("Cell can't as VideoMainCollectionViewCell")
        }

        XCDYouTubeClient.default().getVideoWithIdentifier("gKwN39UwM9Y") { (video: XCDYouTubeVideo?, error) in

            guard
                let url = video?.thumbnailURL
                else { print("url is nil.")
                    return
            }

            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                guard
                    let data = data
                    else { print("data is nil.")
                        return
                }

                DispatchQueue.main.async {
                    print("imageData", data)
                    cell.videoMainImageView.image = UIImage(data: data)
                    //videoMainImageView is nil
                }

            }).resume()

        }

        return cell

    }

}

extension ParlourViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }
}

extension ParlourViewController: AVPlayerViewControllerDelegate {

//    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
//
//        playerViewController.delegate = self
//        return false
//
//    }

}
