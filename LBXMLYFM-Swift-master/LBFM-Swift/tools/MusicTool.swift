//
//  MusicTool.swift
//  LBFM-Swift
//
//  Created by 胡涛 on 2019/5/15.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit
import AVFoundation
import StreamingKit
class MusicTool: NSObject {
    var player = STKAudioPlayer()
    var currenturl: String!
    static let sharedTools = MusicTool()
    private override init() {}
    func play(urlString: String) {
        player.play(URL(string: urlString)!)
    }
    func pause() {
        player.pause()
    }
    func resume() {
        player.resume()
    }
    func seek(toTime d: Double){
        player.seek(toTime: d)
    }
    func duration() -> Double{
        return player.duration
    }
    func progress() -> Double{
        return player.progress
    }
    var displayLink: CADisplayLink?
    
    
}
class UserDF{
    class func setString(key: String,value: String){
        UserDefaults.standard.set(value, forKey: key)
    }
    class func getString(key: String) -> String{
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    class func setInt(key: String,value: Int){
        UserDefaults.standard.set(value, forKey: key)
    }
    class func getInt(key: String) -> Int{
        return UserDefaults.standard.integer(forKey: key)
    }
}
