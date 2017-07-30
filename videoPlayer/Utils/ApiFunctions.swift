//
//  ApiFunctions.swift
//  Princess Polly
//
//  Created by Big Shark on 12/02/2017.
//  Copyright © 2017 w3axis. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ApiFunctions{
    static func getVideoLists(completion: @escaping (String, [VideoModel]) -> ()) {
        Alamofire.request("http://mamacgroup.com/news/api/news.php").responseJSON { response in
            if response.result.isSuccess
            {
                let resultObject = JSON(response.result.value!).arrayValue                
                var videos = [VideoModel]()
                for object in resultObject{
                    videos.append(ParseHelper.parseVideo(object))
                }
                completion("success", videos)
                
            }
            else{
                completion("Sorry, failed to get video list", [])
            }
        }
    }
    
    
    static func downloadVideo(urlString: String,completion: @escaping (String, URL?) -> ()){
        let filenames = urlString.components(separatedBy: "/")
        let filename = filenames[filenames.count - 2] + filenames[filenames.count - 1]
        let localUrl = ParseHelper.getLocalVideoURL(urlString)
        if localUrl == nil {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent(filename)
                return (documentsURL, [.removePreviousFile])
            }
            
            Alamofire.download(urlString, to: destination).responseData { response in
                if let destinationUrl = response.destinationURL {
                    
                    completion("success", destinationUrl)
                }
                else {
                    completion("fail", nil)
                }
            }
        }
        else {
            completion("success", localUrl)
        }
    }
    
    static func downloadData(urlString: String, completion: @escaping (String, Data?) -> ()) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionTask?
        dataTask?.cancel()
        dataTask = defaultSession.dataTask(with: URL(string: urlString)!) {
            data, response, error in
            if error != nil {
                completion("fail", nil)
            }
            else if let data = data {
                completion("success", data)
            }
        }
        dataTask?.resume()
    }
}
