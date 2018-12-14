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

    let videoListsReference = Database.database().reference().child("videoLists")

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

    func getVideoList() {

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

            self.delegate?.manager(self, didFetch: newVideos)

        }

    }

}
