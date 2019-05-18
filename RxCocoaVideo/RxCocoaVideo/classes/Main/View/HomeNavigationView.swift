//
//  HomeNavigationView.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import IBAnimatable

class HomeNavigationView: UIView, NibLoadable {
    
    @IBOutlet weak var searchButton: AnimatableButton!
    
    @IBOutlet var iconButton: UIButton!
    
    @IBOutlet var avatarButton: UIButton!
    /// 搜索按钮点击
    var didSelectSearchButton: (()->())?
    /// 头像按钮点击
    var didSelectAvatarButton: (()->())?
    /// 相机按钮点击
    var didSelectCameraButton: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchButton.theme_backgroundColor = "colors.cellBackgroundColor"
        searchButton.theme_setTitleColor("colors.grayColor150", forState: .normal)
        searchButton.setImage(UIImage(named: "search_small_16x16_"), for: [.normal, .highlighted])
        iconButton.set(image: UIImage(named: iconStr), title: temperature, titlePosition: .bottom,
                     additionalSpacing: -5, state: .normal)
//        iconButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0)
        avatarButton.theme_setImage("images.home_no_login_head", forState: .normal)
        avatarButton.theme_setImage("images.home_no_login_head", forState: .highlighted)
        // 首页顶部导航栏搜索推荐标题内容
        NetworkTool.loadHomeSearchSuggestInfo { (suggest) in
            self.searchButton.setTitle(suggest, for: .normal)
        }
    }
    
    /// 固有的大小
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    /// 重写 frame
    override var frame: CGRect {
        didSet {
            super.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 44)
        }
    }
    
    
    /// 头像按钮点击
    @IBAction func avatarButtonClicked(_ sender: Any) {
       didSelectAvatarButton?()
    }
    
    /// 搜索按钮点击
    @IBAction func searchButtonClicked(_ sender: AnimatableButton) {
        didSelectSearchButton?()
    }
    
}
