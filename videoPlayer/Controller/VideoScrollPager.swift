//
//  VideoScrollPager.swift
//  videoPlayer
//
//  Created by Quan Zhuxian on 26/07/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import UIKit
import Toast_Swift
import AVKit
import AVFoundation

var player = AVPlayer()

class VideoScrollPager: UIViewController {
    let cellSize = UIScreen.main.bounds.size//CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height)
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    var videos = [VideoModel]()
    var currentIndex = 0
    
    
    @IBOutlet weak var descriptionView: UIView!
  
    var selectedIndex = 0
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    var timer = Timer()
    
    var isHiding = false
    
    var playerLayer: AVPlayerLayer!

    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        
        // add player notification observe
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        UIApplication.shared.isStatusBarHidden = true
        
        descriptionViewHeightConstraint.constant = 0
        self.showLoadingView()
        ApiFunctions.getVideoLists(completion: {
            message, videos in
            if message == "success" {
                self.videos = videos
                self.videoCollectionView.reloadData()
                self.downloadVideo()
            }
            else {
                self.showToastWithDuration(string: message, duration: 3.0)
            }
        })
        
        
        
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func showDescription(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        player.pause()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(performShowDescription), userInfo: nil, repeats: true)
    }
    
    func performShowDescription() {
        
        self.descriptionViewHeightConstraint.constant += cellSize.height / 30
        if self.descriptionViewHeightConstraint.constant >= cellSize.height {
            timer.invalidate()
            self.descriptionViewHeightConstraint.constant = cellSize.height
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction func hideDescription(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(performHideDescription), userInfo: nil, repeats: true)
    }
    
    func performHideDescription() {
        self.descriptionViewHeightConstraint.constant -= cellSize.height / 20
        if self.descriptionViewHeightConstraint.constant <= 0 {
            timer.invalidate()
            self.descriptionViewHeightConstraint.constant = 0
            self.view.isUserInteractionEnabled = true
            player.play()
            self.isHiding = false
        }
    }
    
    func playerItemDidReachEnd() {
        if selectedIndex < videos.count - 1 {
            
            //self.playerView.isHidden = true
            videoCollectionView.scrollToItem(at: IndexPath(item: selectedIndex + 1, section: 0), at: .left, animated: true)
            
        }
    }
    
    func downloadVideo() {
        
        
        if currentIndex < videos.count {
            let video =  videos[currentIndex]
            ApiFunctions.downloadVideo(urlString: video.small_video, completion: {
                message, url in
                if message == "success" {
                    if self.selectedIndex == self.currentIndex {
                        self.hideLoadingView()
                        self.selectItem(self.selectedIndex)
                    }
                    self.currentIndex += 1
                    self.downloadVideo()
                }
                else {
                    self.downloadVideo()
                }
            })
        }
        else {
            return
        }
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        if selectedIndex > 0 {
            //self.playerView.isHidden = true
            videoCollectionView.scrollToItem(at: IndexPath(item: selectedIndex - 1, section: 0), at: .left, animated: true)
            
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        if selectedIndex < videos.count - 1 {
            //self.playerView.isHidden = true
            videoCollectionView.scrollToItem(at: IndexPath(item: selectedIndex + 1, section: 0), at: .left, animated: true)
            
        }
    }
    
    
    
    func selectItem(_ index : Int) {
        selectedIndex = index
        
        do {
            descriptionTextView.attributedText = try NSAttributedString(data: videos[index].description.data(using: .unicode)!, options:
            [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        }
        catch {
            
        }
        
        //descriptionTextView.text = videos[index].description
        let url = ParseHelper.getLocalVideoURL(videos[selectedIndex].small_video)
        if url != nil {
            self.hideLoadingView()
            playVideo(url!)
        }
        else {
            player.pause()
            playerView.isHidden = true
            self.showLoadingView()
        }
        
        //playVideoWith(videos[selectedIndex].video_data!)
        
        //self.playerView.isHidden = false
    }
    
    
    func playVideo(_ url: URL) {
        player.pause()
        player = AVPlayer(url: url)
        let layers = playerView.layer.sublayers
        if layers != nil {
            for layer in layers! {
                layer.removeFromSuperlayer()
            }
        }
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        if playerView.layer.sublayers == nil {
            playerView.layer.addSublayer(playerLayer)
        }
        
        player.play()
    }
    
    
}

extension VideoScrollPager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell
        cell.setCell(videos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    
    
}

extension VideoScrollPager: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            if videos.count > 0 {
                
                if scrollView.contentOffset.x < 0 {
                    
                }
                else if scrollView.contentOffset.x > CGFloat(videos.count - 1) * cellSize.height{
                    
                }
            }
        }
        else {
            self.isHiding = true
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
        
            NSLog("end scrolling")
            let index = Int((scrollView.contentOffset.x / cellSize.width) + 0.1)
            selectItem(index)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            let index = Int((scrollView.contentOffset.x / cellSize.width) + 0.1)
            selectItem(index)
        }
    }
    
}


extension VideoScrollPager {
    
    func showToastWithDuration(string: String!, duration: Double) {
        self.view.makeToast(string, duration: duration, position: .bottom)
    }
    
    func showLoadingView()
    {
        self.view.makeToastActivity(.center)
        //self.view.isUserInteractionEnabled = false
    }
    
    func hideLoadingView()
    {
        self.view.hideToastActivity()
        //self.view.isUserInteractionEnabled = true
        
        playerView.isHidden = false
    }
    
    
}



