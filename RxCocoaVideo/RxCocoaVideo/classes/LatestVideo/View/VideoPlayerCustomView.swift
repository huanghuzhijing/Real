//
//  VideoPlayerCustomView.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import BMPlayer
import SnapKit

class VideoPlayerCustomView: BMPlayerControlView {
    
    override func customizeUIComponents() {
        BMPlayerConf.topBarShowInCase = .none
    }
    
}
