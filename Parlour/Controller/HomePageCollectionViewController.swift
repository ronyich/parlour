//
//  HomePageCollectionViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/29.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import XCDYouTubeKit

private let reuseIdentifier = "Cell"

class HomePageCollectionViewController: UICollectionViewController {

    @IBOutlet weak var videoMainView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

//        let youtubeVideoPlayer = XCDYouTubeVideoPlayerViewController()
//        youtubeVideoPlayer.videoIdentifier = "gKwN39UwM9Y"
//
//        youtubeVideoPlayer.present(in: videoMainView)
//        youtubeVideoPlayer.moviePlayer.prepareToPlay()

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1

    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 1

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        return cell
    }

    @IBAction func logoutToLoginView(_ sender: UIBarButtonItem) {

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
