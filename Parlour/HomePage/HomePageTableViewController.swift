//
//  HomePageTableViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/12.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase

protocol HomePageDelegate: AnyObject {

    func manager(_ manager: HomePageTableViewController, didFailWith error: Error)

}

class HomePageTableViewController: UITableViewController {

//    static let shared = HomePageTableViewController()

    weak var delegate: HomePageDelegate?

    let videoManager = VideoManager()

    var video: Video?

    var videos: [Video]?

    var tapGestureRecognizer = UITapGestureRecognizer()

    let videoListsReference = Database.database().reference().child("videoLists")

    var popularVideoCollectionView: UICollectionView?

    let videoLists = ["gKwN39UwM9Y", "H1D1YUz4uhg", "xNDj7QztVbQ", "7nzuDfAj_nE", "s0kRfpGz03Q"]

    @IBAction func refreshTableView(_ sender: UIButton) {

        tableView.reloadData()

        print("ButtonPressed")

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MainVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "MainVideoTableViewCell")

        tableView.register(UINib(nibName: "PopularVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "PopularVideoTableViewCell")

        //videoManager.getVideoList()

        videoListsReference.child("list01").observe(.value) { (snapshot) in

            var newVideos: [Video] = []

            for child in snapshot.children {

                guard
                    let snapshot = child as? DataSnapshot
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.snapshotChildAsDataSnapshotError)
                        return
                }

                guard
                    let listDictionary = snapshot.value as? [String: Any]
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.snapshotValueAsDictionaryError)
                        return
                }

                guard
                    let title = listDictionary["title"] as? String
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.titleAsStringError)
                        return
                }

                guard
                    let videoID = listDictionary["videoID"] as? String
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.videoIDAsStringError)
                        return
                }

                guard
                    let thumbnail = listDictionary["thumbnail"] as? String
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.thumbnailAsStringError)
                        return
                }

                guard
                    let duration = listDictionary["duration"] as? Int
                    else { self.delegate?.manager(self, didFailWith: TypeAsError.durationAsIntError)
                        return
                }

                let video = Video(title: title, videoID: videoID, thumbnail: thumbnail, duration: duration)

                newVideos.append(video)

            }

            DispatchQueue.main.async {

                self.videos = newVideos

                self.tableView.reloadData()

            }

        }

    }

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
                let cell = tableView.dequeueReusableCell(withIdentifier: "MainVideoTableViewCell", for: indexPath) as? MainVideoTableViewCell
                else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: TableViewError.cellAsMainVideoTableViewCellError)))
            }

            if let videos = videos {

                if let firstVideo = videos.first {

                    if let url = URL(string: firstVideo.thumbnail) {

                        //var compeleteData = Data()

                        DispatchQueue.global().async {

                            do {

                                let data = try Data(contentsOf: url)

                                //compeleteData = data

                                DispatchQueue.main.async {

                                    cell.mainVideoImageView.image = UIImage(data: data)

                                    cell.mainVideoImageView.contentMode = .scaleAspectFit

                                }

                            } catch {

                                self.delegate?.manager(self, didFailWith: DataTaskError.dataHandlerError)
                                print(error.localizedDescription)

                            }

                        }

                    } else {

                        self.delegate?.manager(self, didFailWith: DataTaskError.urlNotFound)

                    }

                } else {

                    self.delegate?.manager(self, didFailWith: VideoError.videoNotFound)
                }

            } else {

                self.delegate?.manager(self, didFailWith: VideoError.videosNotFound)

            }

            cell.selectionStyle = .none

            cell.mainVideoImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.mainVideoImageView.isUserInteractionEnabled = true

            tapGestureRecognizer.addTarget(self, action: #selector(fetchUserTapTableViewImageToPlayVideo))

            return cell

        case 1:

            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "PopularVideoTableViewCell", for: indexPath) as? PopularVideoTableViewCell
                else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: TableViewError.cellAsPopularVideoTableViewCellError)))
            }

            cell.popularVideoCollectionView.register(UINib(nibName: "PopularVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularVideoCollectionViewCell")

            cell.popularVideoCollectionView.delegate = self
            cell.popularVideoCollectionView.dataSource = self

            let layout = cell.popularVideoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout

            layout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout?.itemSize = CGSize(width: 100, height: 100)
            layout?.minimumLineSpacing = 20

            popularVideoCollectionView = cell.popularVideoCollectionView

            cell.popularVideoCollectionView.reloadData()

            return cell

        default: fatalError("\(TableViewError.invalidSection)")

        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {

        case 0: return UITableView.automaticDimension

        case 1: return UITableView.automaticDimension

        default: fatalError("\(TableViewError.invalidSection)")

        }

    }

    @objc func fetchUserTapTableViewImageToPlayVideo() {

        guard let indexPath = tableView.indexPathForRow(at: tapGestureRecognizer.location(in: tableView))
            else { self.delegate?.manager(self, didFailWith: TableViewError.getIndexPathError)
                return
        }

        guard let videos = videos, videos.count >= 1
            else { self.delegate?.manager(self, didFailWith: VideoError.videosNotFound)
                return
        }

        video = videos[indexPath.row]

        print("videos[indexPath.row]", videos[indexPath.row])
        performSegue(withIdentifier: "Go_To_VideoPlayTableViewController", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Go_To_VideoPlayTableViewController" {

            guard
                let videoPlayTableViewController =  segue.destination as? VideoPlayTableViewController
                else { self.delegate?.manager(self, didFailWith: TypeAsError.segueAsVideoPlayTableViewControllerError)
                    return
            }

            videoPlayTableViewController.video = video

        } else {

            self.delegate?.manager(self, didFailWith: SegueError.segueIdentifierError)

        }

    }

}

extension HomePageTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return videos?.count ?? 1

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularVideoCollectionViewCell", for: indexPath) as? PopularVideoCollectionViewCell
            else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: CollectionViewError.cellAsPopularVideoCollectionViewCellError)))
        }

        if let videos = videos {

            if videos.count >= 1 {

                if let url = URL(string: videos[indexPath.row].thumbnail) {

                    var compeleteData = Data()

                    DispatchQueue.global().async {

                        do {

                            let data = try Data(contentsOf: url)

                            compeleteData = data

                            DispatchQueue.main.async {

                                cell.videoImageView.image = UIImage(data: compeleteData)
                                cell.videoTitleLabel.text = videos[indexPath.row].title

                                //cell.videoImageView.contentMode = .scaleAspectFit

                            }

                        } catch {

                        self.delegate?.manager(self, didFailWith: DataTaskError.dataNotFound)
                        print(error.localizedDescription)

                        }

                    }

                } else {

                    self.delegate?.manager(self, didFailWith: DataTaskError.urlNotFound)

                }

            } else {

                self.delegate?.manager(self, didFailWith: VideoError.videosCountOutOfRange)

            }

        } else {

            self.delegate?.manager(self, didFailWith: VideoError.videosNotFound)

        }

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(fetchUserTapCollectionViewImageToPlayVideo))

        cell.videoImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.videoImageView.isUserInteractionEnabled = true

        return cell

    }

    @objc func fetchUserTapCollectionViewImageToPlayVideo(sender: UITapGestureRecognizer) {

        guard
            let indexPath = popularVideoCollectionView?.indexPathForItem(at: sender.location(in: popularVideoCollectionView))
            else { self.delegate?.manager(self, didFailWith: CollectionViewError.getIndexPathError)
                return
        }

        guard let videos = videos, videos.count >= 1
            else { self.delegate?.manager(self, didFailWith: VideoError.videosNotFound)
                return
        }

        video = videos[indexPath.row]

        print("videos[indexPath.row]", videos[indexPath.row])
        performSegue(withIdentifier: "Go_To_VideoPlayTableViewController", sender: self)

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

extension HomePageTableViewController: VideoManagerDelegate {

    func manager(_ manager: VideoManager, didFetch videos: [Video]) {

        DispatchQueue.main.async {

            self.videos = videos

            self.tableView.reloadData()

        }

    }

    func manager(_ manager: VideoManager, didFailWith error: Error) {

        print("Fetch videos Error: \(error.localizedDescription)")

    }

}
