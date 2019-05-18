//
//  SmallVideoPlayerCustomView.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/12.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import BMPlayer

class SmallVideoPlayerCustomView: BMPlayerControlView {
    
    override func customizeUIComponents() {
    
        BMPlayerConf.topBarShowInCase = .none
        playButton.removeFromSuperview()
        currentTimeLabel.removeFromSuperview()
        totalTimeLabel.removeFromSuperview()
        timeSlider.removeFromSuperview()
        fullscreenButton.removeFromSuperview()
        progressView.removeFromSuperview()
        replayButton.removeFromSuperview()
    }
    
}
