//
//  LiveChatSettingViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/17.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class LiveChatSettingViewController: UIViewController {

    var youtubeID: String?

    @IBOutlet weak var videoThumbnailImageView: UIImageView!

    @IBOutlet weak var prepareVideoTitleLabel: UILabel!

    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var typeTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        getVideoProperty(videoIdentifier: youtubeID)

    }

    func getVideoProperty(videoIdentifier: String?) {

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error) in

            if let error = error {

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

    @IBAction func startButton(_ sender: UIButton) {

        guard
            let chatRoomViewController = storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController
            else { fatalError("As ChatRoomViewController error.") }

        //chatRoomViewController.navigationController?.title = titleTextField.text
        chatRoomViewController.youtubeID = youtubeID
        //typeTextField
        //passwordTextField
        show(chatRoomViewController, sender: self)
        //present(chatRoomViewController, animated: true, completion: nil)

    }

    @IBAction func cancelButton(_ sender: UIButton) {

        dismiss(animated: true, completion: nil)

    }

}
