//
//  ParlourTableViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/23.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import XCDYouTubeKit
import MessageKit
import YouTubePlayer
import Crashlytics
import NotificationBannerSwift

class ParlourTableViewController: UITableViewController {

    var sender: Sender?

    var channel: Channel?

    var channels: [Channel] = []

    let channelsReference = Database.database().reference(withPath: "channels")

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarColor()

        tableView.register(UINib(nibName: "ParlourTableViewCell", bundle: nil), forCellReuseIdentifier: "ParlourTableViewCell")

        channelsReference.queryOrdered(byChild: "playerState").queryEqual(toValue: "Playing").observe(.value) { (snapshot) in

            var newChannels: [Channel] = []

            print("snapshot.children", snapshot.childrenCount)

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot {

                    guard
                        let dictionary = snapshot.value as? [String: Any]
                        else { print("dictionary is nil.")
                            return
                    }

                    guard
                        let youtubeID = dictionary["youtubeID"] as? String
                        else { print("youtubeID ID is nil.")
                            return
                    }

                    guard
                        let title = dictionary["title"] as? String
                        else { print("title is nil.")
                            return
                    }

                    guard
                        let type = dictionary["type"] as? String
                        else { print("type is nil.")
                            return
                    }

                    guard
                        let password = dictionary["password"] as? String
                        else { print("password is nil.")
                            return
                    }

                    guard
                        let isLive = dictionary["isLive"] as? String
                        else { print("isLive is nil.")
                            return
                    }

                    guard
                        let channelID = dictionary["channelID"] as? String
                        else { print("channelID is nil.")
                            return
                    }

                    guard
                        let hostID = dictionary["hostID"] as? String
                        else { print("hostID is nil in ParlourViewController.")
                            return
                    }

                    guard
                        let playerState = dictionary["playerState"] as? String
                        else { print("playerState is nil.")
                            return
                    }

                    guard
                        let currentTime = dictionary["currentTime"] as? String
                        else { print("currentTime is nil.")
                            return
                    }

                    guard
                        let hostName = dictionary["hostName"] as? String
                        else { print("hostName is nil.")
                            return
                    }

                    if playerState == "Playing" {

                        let channel = Channel(hostID: hostID, title: title, type: type, isLive: isLive, password: password, youtubeID: youtubeID, channelID: channelID, playerState: playerState, currentTime: currentTime, hostName: hostName)

                        newChannels.append(channel)

                    } else {

                        // playerState is other state.

                    }

                    DispatchQueue.main.async {

                        self.channels = newChannels
                        self.tableView.reloadData()

                    }

                }

            }

        }

    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 0: return channels.count

        default: fatalError("\(TableViewError.invalidSection)")

        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:

            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "ParlourTableViewCell", for: indexPath) as? ParlourTableViewCell
                else { fatalError("\(TableViewError.cellAsMainVideoTableViewCellError)")
            }

            if let flareGradientImage = CAGradientLayer.darkGrayGradation(on: cell.constraintView) {

                cell.constraintView.backgroundColor = UIColor(patternImage: flareGradientImage)

            } else {

                print("flareGradientImage error.")

            }

            cell.selectionStyle = .none

            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(fetchUserTapTableViewImageToPlayVideo))

            cell.videoImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.videoImageView.isUserInteractionEnabled = true

            if channels.count >= 1 {

                XCDYouTubeClient.default().getVideoWithIdentifier(channels[indexPath.row].youtubeID) { (video: XCDYouTubeVideo?, error) in

                    guard
                        let url = video?.thumbnailURL
                        else { print("url is nil.")
                            return
                    }

                    URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                        if let error = error {

                            print("URLSession with url Error: \(error.localizedDescription)")

                        } else {

                            guard
                                let data = data
                                else { print("data is nil.")
                                    return
                            }

                            DispatchQueue.main.async {

                                cell.videoImageView.image = UIImage(data: data)
                                cell.videoImageView.contentMode = .scaleAspectFit

                                //crash
                                cell.channelTitleLabel.text = self.channels[indexPath.row].title
                                cell.channelHostNameLabel.text = self.channels[indexPath.row].hostName

                            }

                        }

                    }).resume()

                }

            } else if channels.count == 0 {

                let banner = NotificationBanner(title: NSLocalizedString("Welcome to Parlour", comment: ""), subtitle: NSLocalizedString("There is currently no video chat, tap + button to open a video.", comment: ""), style: .info)

                banner.show()

            } else {

                print("channels is nil.)")

            }

            return cell

        default: fatalError("\(TableViewError.invalidSection)")

        }

    }

    @objc func fetchUserTapTableViewImageToPlayVideo(sender: UITapGestureRecognizer) {

        guard
            let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView))
            else { print(TableViewError.getIndexPathError)
                return
        }

        guard
            channels.count >= 1
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Live is over", comment: ""), subtitle: NSLocalizedString("Please tap refresh button or add a new live chat.", comment: ""), style: .danger)

                banner.show()

                return

        }

        self.channel = channels[indexPath.row]

        performSegue(withIdentifier: "Go_To_ChatRoomViewController", sender: self)

        Analytics.logEvent("Fetch_User_Tap_TableView_Image_To_Play_Video", parameters: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Go_To_ChatRoomViewController" {

            guard
                let chatRoomViewController = segue.destination as? ChatRoomViewController
                else { print("segue as ChatRoomViewController error.")
                    return
            }

            chatRoomViewController.channel = channel

        } else {

            print("segue id error.")

        }

    }

    @IBAction func inputYoutubeURLToSettingPage(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: NSLocalizedString("Paste Youtube URL", comment: ""), message: NSLocalizedString("Example: https://youtu.be/nSDgHBxUbVQ", comment: ""), preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in

            guard
                let textFieldInputString = alert.textFields?.first?.text
                else { print("textFields.first is nil.")
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

            liveChatSettingViewController.delegate = self

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

        Analytics.logEvent("Input_Youtube_URL_To_SettingPage", parameters: nil)

    }

    func setNavigationBarColor() {

        // Set color value in CAGradientLayer.swift
        guard
            let navigationController = navigationController,
            let flareGradientImage = CAGradientLayer.darkGrayGradation(on: navigationController.navigationBar)
            else {
                print("Error creating gradient color!")
                return
        }

        navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)

        tableView.backgroundColor = UIColor(patternImage: flareGradientImage)

    }

}

extension ParlourTableViewController: LiveChatSettingDelegate {

    func manager(_ manager: LiveChatSettingViewController?, didFetchChannel: Channel) {

        self.channel = didFetchChannel

    }

    func showChatRoomViewController(sender: Bool) {

        sender == true ? performSegue(withIdentifier: "Go_To_ChatRoomViewController", sender: self) : nil

    }

}
