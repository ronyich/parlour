//
//  ErrorHandle.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/11.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation

enum UserError: Error {

    case userIDNotFound, displayNameNotFound

}

enum MessageError: Error {

    case  messageIdNotFound, messageInputTextError

}

enum TypeAsError: Error {

    case snapshotValueAsDictionaryError, messageValueAsDictionaryError, messageContentAsStringError, messageSentDateAsStringError, stringAsDateError, currentTimeAsIntError, titleAsStringError, snapshotChildAsDataSnapshotError, videoIDAsStringError, thumbnailAsStringError, durationAsIntError

}

enum VideoError: Error {

    case titleError, videoIDError, nextVideoIDError, hotsIDError, currentTimeError, snapshotValueAsDictionaryError, videoURLNotFound, videoTitleNotFound, videoIDNotFound, videoDurationNotFound, videoThumbnailNotFound, videosNotFound, videosCountOutOfRange

}

enum TableViewError: Error {

    case cellAsMainVideoTableViewCellError,cellAsPopularVideoTableViewCellError, invalidSection, getIndexPathError, cellAsMainVideoTableViewCell

}

enum CollectionViewError: Error {

    case cellAsPopularVideoCollectionViewCellError, cellAsPopularVideoCollectionView, getIndexPathError

}

enum DataTaskError: Error {

    case urlNotFound, dataNotFound

}
