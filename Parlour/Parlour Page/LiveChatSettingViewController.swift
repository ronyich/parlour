//
//  LiveChatSettingViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/17.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import XCDYouTubeKit
import NotificationBannerSwift

protocol LiveChatSettingDelegate: AnyObject {

    func manager(_ manager: LiveChatSettingViewController?, didFetchChannel: Channel)

    func showChatRoomViewController(sender: Bool)

}

class LiveChatSettingViewController: UIViewController {

    var youtubeID: String?

    var video: Video?

    weak var delegate: LiveChatSettingDelegate?

    @IBOutlet weak var videoThumbnailImageView: UIImageView!

    @IBOutlet weak var prepareVideoTitleLabel: UILabel!

    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var constraintView: UIView!
    
    //@IBOutlet weak var typeTextField: UITextField!

    //@IBOutlet weak var passwordTextField: UITextField!

    let videosReference = Database.database().reference(withPath: "videos")

    let channelsReference = Database.database().reference(withPath: "channels")

    override func viewDidLoad() {
        super.viewDidLoad()

        getVideoProperty(videoIdentifier: youtubeID)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMessagesCollectionViewToEndEditing))
        self.view.addGestureRecognizer(tapGesture)

        if let flareGradientImage = CAGradientLayer.darkGrayGradation(on: constraintView) {

            constraintView.backgroundColor = UIColor(patternImage: flareGradientImage)

        } else {

            print("flareGradientImage error.")

        }

    }

    @objc func tapMessagesCollectionViewToEndEditing() {

        titleTextField.endEditing(true)
        //typeTextField.endEditing(true)
        //passwordTextField.endEditing(true)

    }

    func getVideoProperty(videoIdentifier: String?) {

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error) in

            if let error = error {

                self.dismiss(animated: true, completion: {

                    let banner = NotificationBanner(title: "Wrong Youtube URL format", subtitle: "Example: https://youtu.be/nSDgHBxUbVQ", style: .danger)

                    banner.show()

                })

                print(VideoError.videoIDNotFound, error.localizedDescription)

            } else {

                guard
                    let url = video?.thumbnailURL
                    else { print(DataTaskError.urlNotFound)
                        return
                }

                guard
                    let title = video?.title
                    else { print(VideoError.videoTitleNotFound)
                        return
                }

                guard
                    let youtubeID = self.youtubeID
                    else { print("YoutubeID is nil.")
                        return
                }

                guard
                    let duration = video?.duration
                    else { print("duration is nil.")
                        return
                }

                guard
                    let uid = Auth.auth().currentUser?.uid
                    else { print("uid is nil.")
                        return
                }

                let videoItem = Video(title: title, youtubeID: youtubeID, thumbnail: url.absoluteString, currentTime: 0, duration: Int(duration), hostID: uid)

                self.video = videoItem

                URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                    if let error = error {

                        print(DataTaskError.urlNotFound, error.localizedDescription)

                    } else {

                        guard
                            let data = data
                            else { print(DataTaskError.dataNotFound)
                                return
                        }

                        DispatchQueue.main.async {

                            self.videoThumbnailImageView.image = UIImage(data: data)
                            self.videoThumbnailImageView.contentMode = .scaleAspectFit

                            self.prepareVideoTitleLabel.text = title

                        }

                    }

                }).resume()

            }

        }

    }

    @IBAction func startLiveChat(_ sender: UIButton) {

        guard
            let uid = Auth.auth().currentUser?.uid
            else { print(UserError.userIDNotFound)
                return
        }

        guard
            let displayName = Auth.auth().currentUser?.displayName
            else { print(UserError.displayNameNotFound)
                return
        }

        guard let youtubeID = self.youtubeID
            else { print("YoutubeID is nil.")
                return
        }

        guard
            let title = titleTextField.text, title != ""
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Title is empty", comment: ""), subtitle: NSLocalizedString("Please Input your chat room title over 1 character.", comment: ""), style: .danger)

                banner.show()

                return
        }

        guard
            let channelID = channelsReference.childByAutoId().key
            else { print("channelID is nil in LiveChatSettingViewController.")
                return
        }

        guard
            let video = video
            else { print("video is nil.")
                return
        }

        let channelItem = Channel(hostID: uid, title: title, type: "", isLive: "YES", password: "", youtubeID: youtubeID, channelID: channelID, playerState: "", currentTime: "0", hostName: displayName)

        channelsReference.child(channelID).setValue(channelItem.uploadChannelObjectToFirebase())

        videosReference.child(channelID).setValue(video.saveVideoObjectToFirebase())

        dismiss(animated: true) { [weak self] in

            self?.delegate?.manager(self, didFetchChannel: channelItem)
            self?.delegate?.showChatRoomViewController(sender: true)

        }

        Analytics.logEvent("Start_Live_Chat", parameters: nil)

    }

//    @IBAction func startButton(_ sender: UIButton) {
//
//        guard
//            let chatRoomViewController = storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController
//            else { fatalError("As ChatRoomViewController error.")
//        }
//
//        guard
//            let uid = Auth.auth().currentUser?.uid
//            else { print(UserError.userIDNotFound)
//                return
//        }
//
//        guard let youtubeID = self.youtubeID
//            else { print("YoutubeID is nil.")
//                return
//        }
//
//        guard
//            let title = titleTextField.text
//            else { print("title is nil.")
//                return
//        }
//
//        guard
//            let type = typeTextField.text
//            else { print("type is nil.")
//                return
//        }
//
//        guard
//            let password = passwordTextField.text
//            else { print("password is nil.")
//                return
//        }
//
//        // MARK: editing...
//        let videoItem = Channel(hostID: uid, title: titleTextField.text, type: typeTextField, isLive: "YES", password: passwordTextField, youtubeID: <#T##String#>, channelID: <#T##String#>, playerState: <#T##String#>, currentTime: <#T##String#>)
//
//        videosReference.child(uid).setValue(videoItem.saveVideoControlObjectToFirebase())
//
////        chatRoomViewController.youtubeID = youtubeID
////        chatRoomViewController.chatRoomTitle = titleTextField.text
////        chatRoomViewController.chatRoomType = typeTextField.text
////        chatRoomViewController.chatRoomPassword = passwordTextField.text ?? ""
//
//        present(chatRoomViewController, animated: true, completion: nil)
//
//    }

    @IBAction func cancelLiveChatSetting(_ sender: UIButton) {

        dismiss(animated: true, completion: nil)

        Analytics.logEvent("Cancel_Live_Chat_Setting", parameters: nil)

    }

}
