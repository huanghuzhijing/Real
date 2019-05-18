//
//  LBFMPlayCell.swift
//  LBFM-Swift
//
//  Created by liubo on 2019/3/8.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit
import StreamingKit
import MediaPlayer
var currentProgress = Float(0)
class LBFMPlayCell: UICollectionViewCell {
    var playUrl:String?
    var timer: Timer?
    // 是否是第一次播放
    var isFirstPlay:Bool = true
    // 音频播放器
    var img = UIImage(named: "fj")
    // 标题
    private var titleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    // 图片
    private var imageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    // 弹幕按钮
    private lazy var barrageBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "NPProDMOff_24x24_"), for: UIControlState.normal)
        return button
    }()
    // 播放机器按钮
    private lazy var machineBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "npXPlay_30x30_"), for: UIControlState.normal)
        return button
    }()
    // 设置按钮
    private lazy var setBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "NPProSet_25x24_"), for: UIControlState.normal)
        return button
    }()
    // 进度条
    private lazy var slider:UISlider = {
        let slider = UISlider(frame: CGRect.zero)
        slider.setThumbImage(UIImage(named: "playProcessDot_n_7x16_"), for: .normal)
        slider.maximumTrackTintColor = UIColor.lightGray
        slider.minimumTrackTintColor = LBFMButtonColor
        // 滑块滑动停止后才触发ValueChanged事件
        //        slider.isContinuous = false
        
        slider.addTarget(self, action: #selector(LBFMPlayCell.change(slider:)), for: UIControlEvents.valueChanged)
        
        slider.addTarget(self, action: #selector(LBFMPlayCell.sliderDragUp(sender:)), for: UIControlEvents.touchUpInside)
        return slider
    }()
    // 当前时间
    private lazy var currentTime:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = LBFMButtonColor
        return label
    }()
    // 总时间
    private lazy var totalTime:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = LBFMButtonColor
        label.textAlignment = NSTextAlignment.right
        return label
    }()
    // 播放暂停按钮
    private lazy var playBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "toolbar_play_n_p_78x78_"), for: UIControlState.normal)
        button.setImage(UIImage(named: "toolbar_pause_n_p_78x78_"), for: UIControlState.selected)
        button.addTarget(self, action: #selector(playBtn(button:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    // 上一曲按钮
    private lazy var prevBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "toolbar_prev_n_p_24x24_"), for: UIControlState.normal)
        return button
    }()
    
    // 下一曲按钮
    private lazy var nextBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "toolbar_next_n_p_24x24_"), for: UIControlState.normal)
        return button
    }()
    // 消息列表按钮
    private lazy var msgBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "playpage_icon_list_24x24_"), for: UIControlState.normal)
        return button
    }()
    // 定时按钮
    private lazy var timingBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage(named: "playpage_icon_timing_24x24_"), for: UIControlState.normal)
        return button
    }()
    
    private lazy var blurImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// 设置布局
        
        self.blurImageView = UIImageView.init(frame:  CGRect(x:0 , y: -200 , width: LBFMScreenWidth, height: self.bounds.height + 201))
        
        self.blurImageView.image = UIImage(named: "1")
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
        visualEffectView.frame = self.blurImageView.bounds
        //添加毛玻璃效果层
        self.blurImageView.addSubview(visualEffectView)
        self.insertSubview(self.blurImageView, belowSubview: self)
        setUpUI()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        if currentProgress == 0 {
            playBtn.isSelected = false
            MusicTool.sharedTools.pause()
            MusicTool.sharedTools.seek(toTime: Double(currentProgress * Float(MusicTool.sharedTools.duration())))
        }else{
            isFirstPlay = false
            starTimer()
            slider.value = currentProgress
            
            playBtn.isSelected = true
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    deinit {
        if currentProgress == 0 {
            removeTimer()
        }
    }
    
    func setUpUI(){
        // 标题
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        // 图片
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(LBFMScreenHeight * 0.7 - 260)
        }
        // 弹幕按钮
        self.addSubview(self.barrageBtn)
        self.barrageBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(self.imageView.snp.bottom).offset(20)
            make.height.width.equalTo(30)
        }
        // 设置按钮
        self.addSubview(self.setBtn)
        self.setBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(self.imageView.snp.bottom).offset(20)
            make.height.width.equalTo(30)
        }
        // 播放机器按钮
        self.addSubview(self.machineBtn)
        self.machineBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.setBtn.snp.left).offset(-20)
            make.top.equalTo(self.imageView.snp.bottom).offset(20)
            make.height.width.equalTo(30)
        }
        // 进度条
        self.addSubview(self.slider)
        self.slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-90)
        }
        // 当前时间
        self.addSubview(self.currentTime)
        self.currentTime.text = "00:00"
        self.currentTime.snp.makeConstraints { (make) in
            make.left.equalTo(self.slider)
            make.top.equalTo(self.slider.snp.bottom).offset(5)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        // 总时间
        self.addSubview(self.totalTime)
        self.totalTime.text = "21:33"
        self.totalTime.snp.makeConstraints { (make) in
            make.right.equalTo(self.slider)
            make.top.equalTo(self.slider.snp.bottom).offset(5)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        // 播放暂停按钮
        self.addSubview(self.playBtn)
        self.playBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.height.width.equalTo(60)
            make.centerX.equalToSuperview()
        }
        // 上一曲按钮
        self.addSubview(self.prevBtn)
        self.prevBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.playBtn.snp.left).offset(-30)
            make.height.width.equalTo(25)
            make.centerY.equalTo(self.playBtn)
        }
        // 下一曲按钮
        self.addSubview(self.nextBtn)
        self.nextBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.playBtn.snp.right).offset(30)
            make.height.width.equalTo(25)
            make.centerY.equalTo(self.playBtn)
        }
        // 消息列表按钮
        self.addSubview(self.msgBtn)
        self.msgBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.width.equalTo(40)
        }
        // 定时按钮
        self.addSubview(self.timingBtn)
        self.timingBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.width.equalTo(40)
        }
    }
    
    var playTrackInfo:LBFMPlayTrackInfo?{
        didSet{
            if let model = playTrackInfo{
                self.titleLabel.text = model.title
                self.totalTime.text = getMMSSFromSS(duration: model.duration)
                self.playUrl = model.playUrl64
                self.imageView.kf.setImage(with: URL(string: model.coverLarge ?? "http://fdfs.xmcdn.com/group59/M01/9B/9D/wKgLeFzbokLxpqoDAAIgpr_9v2g763.jpg"))
                self.blurImageView.kf.setImage(with: URL(string: model.coverLarge ?? "http://fdfs.xmcdn.com/group59/M01/9B/9D/wKgLeFzbokLxpqoDAAIgpr_9v2g763.jpg"))
                UserDF.setString(key: "title", value: model.title!)
                UserDF.setInt(key: "duration", value: model.duration)
                UserDF.setString(key: "playUrl64", value: model.playUrl64!)
                UserDF.setString(key: "imageView", value: model.coverLarge ?? "http://fdfs.xmcdn.com/group59/M01/9B/9D/wKgLeFzbokLxpqoDAAIgpr_9v2g763.jpg")
                
            }else{
                self.titleLabel.text = UserDF.getString(key: "title")
                self.totalTime.text = getMMSSFromSS(duration: UserDF.getInt(key: "duration"))
                self.playUrl = UserDF.getString(key: "playUrl64")
                self.imageView.kf.setImage(with: URL(string: UserDF.getString(key: "imageView") ))
                self.blurImageView.kf.setImage(with: URL(string: UserDF.getString(key: "imageView")))
            }
            img = imageView.image
            
        }
    }
    
    func getMMSSFromSS(duration:Int)->(String){
        var min = duration / 60
        let sec = duration % 60
        var hour : Int = 0
        if min >= 60 {
            hour = min / 60
            min = min % 60
            if hour > 0 {
                return String(format: "%02d:%02d:%02d", hour, min, sec)
            }
        }
        return String(format: "%02d:%02d", min, sec)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func playBtn(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            if isFirstPlay {
                if let url = self.playUrl{
                    MusicTool.sharedTools.play(urlString: url)
                    UserDF.setString(key: "url", value: url)
                    starTimer()
                    isFirstPlay = false
                }else{
                    
                    MusicTool.sharedTools.play(urlString:  UserDF.getString(key: "url"))
                    starTimer()
                    isFirstPlay = false
                }
                
            }else {
                starTimer()
                MusicTool.sharedTools.resume()
            }
        }else{
            
            removeTimer()
            setInfoCenterCredentials(playbackState: 0)
            MusicTool.sharedTools.pause()
        }
        
    }

    func starTimer() {
        MusicTool.sharedTools.displayLink = CADisplayLink(target: self, selector: #selector(updateCurrentLabel))
        MusicTool.sharedTools.displayLink?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func removeTimer() {
        MusicTool.sharedTools.displayLink?.invalidate()
        MusicTool.sharedTools.displayLink = nil
    }
}

extension LBFMPlayCell{
    @objc func setUpTimesView() {
        let currentTime:Int = Int(MusicTool.sharedTools.progress())
        self.currentTime.text = getMMSSFromSS(duration: currentTime)
        let progress = Float(MusicTool.sharedTools.progress() / MusicTool.sharedTools.duration())
        slider.value = progress
    }
    @objc func updateCurrentLabel() {
        let currentTime:Int = Int(MusicTool.sharedTools.progress())
        self.currentTime.text = getMMSSFromSS(duration: currentTime)
        let progress = Float(MusicTool.sharedTools.progress() / MusicTool.sharedTools.duration())
        slider.value = progress
        currentProgress = progress
        self.setInfoCenterCredentials(playbackState: 1)
    }
    @objc func change(slider:UISlider) {
        print("slider.value = %d",slider.value)
        MusicTool.sharedTools.seek(toTime: Double(slider.value * Float(MusicTool.sharedTools.duration())))
    }
    
    @objc func sliderDragUp(sender: UISlider) {
        print("value:(sender.value)")
    }
    // 设置后台播放显示信息
    func setInfoCenterCredentials(playbackState: Int) {
        DispatchQueue.global().async {
            let mpic = MPNowPlayingInfoCenter.default()
            
            //专辑封面
            let mySize = CGSize(width: 400, height: 400)
            var albumArt = NSObject()
            if #available(iOS 10.0, *) {
                albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
                    if let i = self.img{
                        return i
                    }else{
                        return UIImage(named: "fj")!
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            
            //获取进度
            let postion = Double(MusicTool.sharedTools.progress())
            let duration = Double(MusicTool.sharedTools.duration())
            
            mpic.nowPlayingInfo = [MPMediaItemPropertyTitle: self.playTrackInfo?.title,
                                   MPMediaItemPropertyArtist: self.playTrackInfo?.categoryName,
                                   MPMediaItemPropertyArtwork: albumArt,
                                   MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                                   MPMediaItemPropertyPlaybackDuration: duration,
                                   MPNowPlayingInfoPropertyPlaybackRate: playbackState]
        }
    }

    //后台操作
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            print("no event\n")
            return
        }
        
        if event.type == UIEventType.remoteControl {
            switch event.subtype {
            case .remoteControlTogglePlayPause:
                print("暂停/播放")
            case .remoteControlPreviousTrack:
                print("上一首")
            case .remoteControlNextTrack:
                print("下一首")
//            case .remoteControlPlay:
//                print("播放")
//                audioPlayer.resume()
//            case .remoteControlPause:
//                print("暂停")
//                audioPlayer.pause()
                //后台播放显示信息进度停止
                setInfoCenterCredentials(playbackState: 0)
            default:
                break
            }
        }
    }
}
