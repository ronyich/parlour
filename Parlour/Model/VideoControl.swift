//
//  VideoControl.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/12.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation

struct VideoControl {

    var nextVideoID: String
    var currentTime: Int
    var hostID: String

    init(nextVideoID: String, currentTime: Int, hostID: String) {

        self.nextVideoID = nextVideoID
        self.currentTime = currentTime
        self.hostID = hostID

    }

    func saveVideoControlObjectToFirebase() -> Any {
        
        return [
            
            "nextVideoID": nextVideoID,
            "currentTime": currentTime,
            "hostID": hostID
            
        ]
        
    }
}
