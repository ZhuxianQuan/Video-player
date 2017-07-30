//
//  VideoPlayerCell.swift
//  videoPlayer
//
//  Created by Quan Zhuxian on 26/07/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation

class VideoPlayerCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    
    func setCell(_ video: VideoModel) {
        guard let url = ParseHelper.getLocalVideoURL(video.image) else {
            return
        }
        
        do {
            let image = try Data(contentsOf: url)
            thumbnail.image = UIImage(data: image)
            
        }
        catch {
            
        }
    }
    
    
    
    
    
    
}
