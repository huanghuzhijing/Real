//
//  SmallVideoViewController.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/12.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BMPlayer
import NVActivityIndicatorView
import SnapKit

class SmallVideoViewController: UIViewController {
    
    /// 播放器
    private lazy var player = BMPlayer(customControlView: SmallVideoPlayerCustomView())
    
    private let disposeBag = DisposeBag()
    /// 小视频数组
    var smallVideos = [NewsModel]()
    /// 原始 索引
    var originalIndex = 0
    /// 当前索引
    var currentIndex = 0
    /// 标题按钮
    @IBOutlet weak var titleButton: UIButton!
    /// 顶部约束
    @IBOutlet weak var titleTop: NSLayoutConstraint!
//    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    /// 评论按钮
   
    /// 显示背景图片的 collectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SmallVideoViewController {
    
    func setupUI() {
        collectionView.collectionViewLayout = SmallVideoLayout()
        collectionView.ym_registerCell(cell: SmallVideoCell.self)
//        bottomViewBottom.constant = isIPhoneX ? 34 : 0
//        bottomViewBottom.istran
        titleTop.constant = isIPhoneX ? 40 : 0
        view.layoutIfNeeded()
//        let smallVideo = smallVideos[originalIndex]
        titleButton.theme_setImage("images.douyin_logo_new_100x28_", forState: .normal)
        collectionView.scrollToItem(at: IndexPath(item: originalIndex, section: 0), at: .centeredVertically, animated: false)
        // 设置播放器
        setupPlayer(currentIndex: originalIndex)
    }
    
    /// 设置播放器
    private func setupPlayer(currentIndex: Int) {
        // 当前的视频
        let smallVide = smallVideos[currentIndex]
        if let videoURLString = smallVide.raw_data.video.play_addr.url_list.first {
            // https://aweme.snssdk.com/aweme/v1/play/?video_id=887cc4819fd543e68125b471142de2ee&line=0&app_id=13
            // http://v9-dy.ixigua.com/f0c5b6992b84ec8581be670a9f0e6db6/5a5f3713/video/m/220dcaa08afe2814fe982a551581d7051c311518ee4000028f420dbd167/
            let dataTask = URLSession.shared.dataTask(with: URL(string: videoURLString)!, completionHandler: { (data, response, error) in
                // 主线程添加播放器
                DispatchQueue.main.async {
                    // 获取当前的 cell
                    if let cell: SmallVideoCell = self.collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? SmallVideoCell  {
                        if self.player.isPlaying { self.player.pause() }
                        // 先把 bgImageView 的子视图移除，再添加
//                        for subview in cell.bgImageView.subviews { subview.removeFromSuperview() }
                        cell.bgImageView.addSubview(self.player)
                        self.player.snp.makeConstraints({ $0.edges.equalTo(cell.bgImageView) })
                        let asset = BMPlayerResource(url: URL(string: response!.url!.absoluteString)!)
                        self.player.setVideo(resource: asset)
                    }
                   
                }
            })
            dataTask.resume()
        }
        
    }
    
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SmallVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return smallVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.ym_dequeueReusableCell(indexPath: indexPath) as SmallVideoCell
        cell.smallVideo = smallVideos[indexPath.item]
        cell.switchPlay = switchPlay
        // 头像按钮名按钮点击
        cell.didSelectAvatarOrNameButton = {
            let postCommentView = PostCommentView.loadViewFromNib()
            postCommentView.placeholderLabel.text = "优质评论将会被优先展示"
            postCommentView.isEmojiButtonSelected = false
            UIApplication.shared.keyWindow?.backgroundColor = .white
            UIApplication.shared.keyWindow?.addSubview(postCommentView)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
       
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.player.isPlaying { self.player.pause() }
        let currentIndex = Int(scrollView.contentOffset.y / scrollView.height + 0.5)
        // 根据当前索引设置播放器
        setupPlayer(currentIndex: currentIndex)
    }
}

// MARK: - 点击事件
extension SmallVideoViewController {
     func switchPlay() {
        if self.player.isPlaying { self.player.pause() }else{
            self.player.play()
        }
    }
    /// 关闭按钮点击
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        firstPlay = -1
        self.player.pause()
    }
    /// 标题按钮点击
    @IBAction func titleButtonClicked(_ sender: UIButton) {
        
    }
    /// 更多按钮点击
    @IBAction func moreButtonClicked(_ sender: UIButton) {
        
    }
    /// 写评论按钮点击
    @IBAction func writeButtonClicked(_ sender: UIButton) {
        
    }
    /// 评论按钮点击
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        
    }
    /// 点赞按钮点击
    @IBAction func diggButtonClicked(_ sender: UIButton) {
        
    }
    /// 分享按钮点击
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        
    }
}
