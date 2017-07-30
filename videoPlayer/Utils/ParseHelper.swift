//
//  ParseHelper.swift
//  Princess Polly
//
//  Created by Big Shark on 12/02/2017.
//  Copyright © 2017 w3axis. All rights reserved.
//

import Foundation
import SwiftyJSON


class ParseHelper {
    static func parseVideo(_ rawData: JSON) -> VideoModel{
        let video = VideoModel()
        video.id = rawData["id"].stringValue
        video.image = rawData["image"].stringValue
        video.small_video = rawData["small_video"].stringValue
        video.description = rawData["description"].stringValue
        return video
    }
    
    static func getLocalVideoURL(_ urlString: String) -> URL? {
        let filenames = urlString.components(separatedBy: "/")
        let filename = filenames[filenames.count - 2] + filenames[filenames.count - 1]
        var savedFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"  + "/" + filename
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: savedFilePath) {
            savedFilePath = "file:" + savedFilePath
            let localURL = URL(string: savedFilePath)!
            return localURL
        } else {
            return nil
        }

    }
}
