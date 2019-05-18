//
//  WeatherNavigationBar.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit

class WeatherNavigationBar: UIView,NibLoadable {
    
    /// 头像按钮点击
    var didSelectAvatarButton: (()->())?
    
    var weatherModel = WeatherModel(){
        didSet{
            icon.setImage( UIImage(named: weatherModel.iconStr), for: .normal)
            city.setTitle("上海", for: .normal)
            city.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -5, 0)
            temprature.setTitle(weatherModel.temprature, for: .normal)
            temprature.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0)
        }
    }
    @IBOutlet var icon: UIButton!
    @IBOutlet var city: UIButton!
    @IBOutlet var temprature: UIButton!
    @IBOutlet var avatarButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        city.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        temprature.contentVerticalAlignment = UIControlContentVerticalAlignment.top
        avatarButton.theme_setImage("images.home_no_login_head", forState: .normal)
        avatarButton.theme_setImage("images.home_no_login_head", forState: .highlighted)
        
    }
    
    /// 固有的大小
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    @IBAction func showUserInfo(_ sender: Any) {
         didSelectAvatarButton?()
    }
    
}
