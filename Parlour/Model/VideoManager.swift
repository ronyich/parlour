//
//  VideoManager.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/12.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import Firebase
import XCDYouTubeKit

protocol VideoManagerDelegate: AnyObject {

    func manager(_ manager: VideoManager, didFetch videos: [Video])

    func manager(_ manager: VideoManager, didFailWith error: Error)

}

class VideoManager {

    static let shared: VideoManager = VideoManager()
    weak var delegate: VideoManagerDelegate?

    func getVideoObject(videoIdentifier: String) {

//        let videoIdentifier = "gKwN39UwM9Y"

        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error) in

            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??                                               streamURLs[YouTubeVideoQuality.hd720] ??
                streamURLs[YouTubeVideoQuality.medium360] ??
                streamURLs[YouTubeVideoQuality.small240]) {

                guard
                    let url = video?.thumbnailURL
                    else { self.delegate?.manager(self, didFailWith: VideoError.videoURLNotFound)
                        return
                }

                guard
                    let title = video?.title
                    else { self.delegate?.manager(self, didFailWith: VideoError.videoTitleNotFound)
                        return
                }

                guard
                    let videoID = video?.identifier
                    else { self.delegate?.manager(self, didFailWith: VideoError.videoIDNotFound)
                        return
                }

                guard
                    let duration = video?.duration
                    else { self.delegate?.manager(self, didFailWith: VideoError.videoDurationNotFound)
                        return
                }

                let durationSeconds = Int(duration)

                URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                    guard
                        let data = data
                        else { self.delegate?.manager(self, didFailWith: DataTaskError.dataNotFound)
                            return
                    }

                    let videoItem = Video(title: title, videoID: videoID, thumbnail: url.absoluteString, duration: durationSeconds)

                    let videoListItemReference = Database.database().reference(withPath: "videoLists")

                    //let listID = videoListItemReference.key

                    //videoListItemReference.child("list01/4").setValue(videoItem.saveVideoObjectToFirebase())

                }).resume()

            } else {

                print(error?.localizedDescription)

            }

        }

    }

}
