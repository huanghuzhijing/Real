//
//  SmallVideoCell.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/12.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher
import BMPlayer
import SnapKit
import NVActivityIndicatorView

class SmallVideoCell: UICollectionViewCell, RegisterCellFromNib {
    var heartCount = 0
    var heart_count = ""
    let stopButton = UIButton(type: .custom)
    var didSelectAvatarOrNameButton: (()->())?
    var switchPlay: (()->())?
    
    var smallVideo = NewsModel() {
        didSet {
            bgImageView.image = nil
            nameButton.setTitle("@" + smallVideo.raw_data.user.info.name, for: .normal)
            avatarButton.kf.setImage(with: URL(string: smallVideo.raw_data.user.info.avatar_url), for: .normal)
//            vImageView.isHidden = !smallVideo.raw_data.user.info.user_verified
//            concernButton.isSelected = smallVideo.raw_data.user.relation.is_following
            titleLabel.attributedText = smallVideo.raw_data.attrbutedText
            heartCount = smallVideo.raw_data.action.digg_count * 9
            if(heartCount > 9999){
               
                heart_count = String(format: "%.1f", Float(heartCount)/10000) + "W"
            }else{
                heart_count = String(heartCount)
            }
            heartBtn.set(image: UIImage(named: "white_heart_small"), title: heart_count, titlePosition: .bottom,
                              additionalSpacing: 10.0, state: .normal)
            commentBtn.set(image: UIImage(named: "comment_white"), title: smallVideo.raw_data.action.commentCount, titlePosition: .bottom,
                         additionalSpacing: 10.0, state: .normal)
            shareBtn.set(image: UIImage(named: "share_white"), title: smallVideo.raw_data.action.forwardCount, titlePosition: .bottom,
                         additionalSpacing: 10.0, state: .normal)
        }
    }
    
    /// 头像按钮
    @IBOutlet weak var avatarButton: AnimatableButton!
    /// 用户名按钮
    @IBOutlet weak var nameButton: AnimatableButton!
    /// 关注按钮
    /// 标题
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var scrollLabel: UILabel!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
   
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    
    @IBAction func clickHeart(_ sender: Any) {
        var imgName = ""
        if(heartBtn.isSelected == true){
            heartBtn.isSelected = false
            heartCount-=1
            imgName = "white_heart_small"
        }else{
            heartBtn.isSelected = true
            heartCount+=1
            imgName = "red_heart_small"
        }
        heartBtn.set(image: UIImage(named: imgName), title: String(heartCount), titlePosition: .bottom,
                     additionalSpacing: 10.0, state: .normal)
    }
    /// 关注按钮点击
    @IBAction func concernButtonClicked(_ sender: UIButton) {
        if sender.isSelected { // 已经关注，点击则取消关注
            // 已关注用户，取消关注
            NetworkTool.loadRelationUnfollow(userId: smallVideo.raw_data.user.info.user_id, completionHandler: { (_) in
                sender.isSelected = !sender.isSelected
                sender.theme_backgroundColor = "colors.globalRedColor"
            })
        } else { // 未关注，点击则关注这个用户
            // 点击关注按钮，关注用户
            NetworkTool.loadRelationFollow(userId: smallVideo.raw_data.user.info.user_id, completionHandler: { (_) in
                sender.isSelected = !sender.isSelected
                sender.theme_backgroundColor = "colors.userDetailFollowingConcernBtnBgColor"
            })
        }
    }
    /// 头像按钮或用户名按钮点击
    @IBAction func avatarButtonClicked(_ sender: AnimatableButton) {
        didSelectAvatarOrNameButton?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(stopButton)
        stopButton.tag = BMPlayerControlView.ButtonType.play.rawValue
        stopButton.setImage(UIImage(named: "new_play_video_44x44_"), for: .selected)
        stopButton.setImage(UIImage(named: "navigation_background_clear"), for: .normal)
        stopButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
//        playButton.tag = BMPlayerControlView.ButtonType.play.rawValue
//        playButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_play"),  for: .normal)
//        playButton.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_pause"), for: .selected)
//        playButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
//
//        playButton.snp.makeConstraints { (make) in
//            make.width.equalTo(50)
//            make.height.equalTo(50)
//            make.center.equalTo(mainMaskView)
//        }
        stopButton.snp.makeConstraints{ (make) in
            make.height.equalTo(350)
            make.width.equalTo(150)
            make.center.equalToSuperview()
        }
    }
    @objc func onButtonPressed(_ button: UIButton) {
        stopButton.isSelected = !stopButton.isSelected
        switchPlay!()
    }
}
