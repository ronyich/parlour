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

    weak var delegate: HomePageDelegate?

    var videos: [Video]?

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

            if let url = URL(string: videos?[0].thumbnail ?? "") {

                if let data = try? Data(contentsOf: url) {

                    DispatchQueue.main.async {

                        cell.mainVideoImageView.image = UIImage(data: data)
                        cell.mainVideoImageView.contentMode = .scaleAspectFit

                    }

                } else {

                    self.delegate?.manager(self, didFailWith: DataTaskError.dataNotFound)

                }

            } else {

                self.delegate?.manager(self, didFailWith: DataTaskError.urlNotFound)

            }

            let tapGestureRecognizer = UITapGestureRecognizer()

            cell.mainVideoImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.mainVideoImageView.isUserInteractionEnabled = true

            tapGestureRecognizer.addTarget(self, action: #selector(playVideoInTableView))

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

    @objc func playVideoInTableView(sender: UITapGestureRecognizer) {

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainVideoTableViewCell") as? MainVideoTableViewCell
            else { fatalError(String(describing: self.delegate?.manager(self, didFailWith: TableViewError.cellAsMainVideoTableViewCellError)))
        }

        //let point = cell.mainVideoImageView.convert(cell.mainVideoImageView.center, to: tableView)

        //let indexPath = tableView.indexPathForRow(at: point)
        guard let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView))
            else { self.delegate?.manager(self, didFailWith: TableViewError.getIndexPathError)
                return
        }

        print("In playVideoInTableView")
        //print("point:", point)
        print("indexPath:", indexPath)

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

            if videos.count > 1 {

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
        tapGestureRecognizer.addTarget(self, action: #selector(playVideoInCollectionView))

        cell.videoImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.videoImageView.isUserInteractionEnabled = true

        return cell

    }

    @objc func playVideoInCollectionView(sender: UITapGestureRecognizer) {

        guard
            let indexPath = popularVideoCollectionView?.indexPathForItem(at: sender.location(in: popularVideoCollectionView))
            else { self.delegate?.manager(self, didFailWith: CollectionViewError.getIndexPathError)
                return
        }

        print("indexPath:", indexPath)

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
