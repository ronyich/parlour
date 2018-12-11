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

    case  messageIdNotFound

}

enum TypeAsError: Error {

    case snapshotValueAsDictionaryError, messageValueAsDictionaryError, messageContentAsStringError, messageSentDateAsStringError, stringAsDateError, currentTimeAsIntError

}

enum VideoError: Error {

    case titleError, videoIDError, nextVideoIDError, hotsIDError, currentTimeError, snapshotValueAsDictionaryError
}
