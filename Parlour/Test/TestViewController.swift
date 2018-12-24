//
//  TestViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/20.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import YouTubePlayer

class TestViewController: UIViewController, YouTubePlayerDelegate {

    @IBOutlet var videoPlayer: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        videoPlayer.delegate = self

        videoPlayer.playerVars = [

            "playsinline": "1",
            "controls": "1"

            ] as YouTubePlayerView.YouTubePlayerParameters

        videoPlayer.loadPlaylistID("PLC6D7B81753E76C5E")

    }

    func playerReady(_ videoPlayer: YouTubePlayerView) {

        //videoPlayer.play()
        videoPlayer.seekTo(50, seekAhead: true)
    }

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {

        if playerState.rawValue == "-1" {
            print("Unstarted")
        } else if playerState.rawValue == "0" {
            print("Ended")
        } else if playerState.rawValue == "1" {
            print("Playing")
        } else if playerState.rawValue == "2" {
            print("Paused")
        } else if playerState.rawValue == "3" {
            print("Buffering")
        } else if playerState.rawValue == "4" {
            print("Queued")
        } else {
            print("Nothing")
        }
    }

}
