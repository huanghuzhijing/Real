//
//  MyTheme.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import SwiftTheme


enum MyTheme: Int {
    case day = 0
    case night = 1
    
    static var before = MyTheme.day
    static var current = MyTheme.day
    
    /// 选择主题
    static func switchTo(_ theme: MyTheme) {
        before = current
        current = theme
        
        switch theme {
        case .day: ThemeManager.setTheme(plistName: "default_theme", path: .mainBundle)
        case .night: ThemeManager.setTheme(plistName: "night_theme", path: .mainBundle)
        }
    }
    /// 选择了夜间主题
    static func switchNight(_ isToNight: Bool) {
        switchTo(isToNight ? .night : .day)
    }
    /// 判断当前是否是夜间主题
    static func isNight() -> Bool {
        return current == .night
    }
    
}
class StatusBarBGC{
    static func setStatusBarBackgroundColor(color : UIColor) {
        let statusBarWindow : UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let statusBar : UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
        /*
         if statusBar.responds(to:Selector("setBackgroundColor:")) {
         statusBar.backgroundColor = color
         }*/
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
}
struct MyThemeStyle {
    /// 设置导航栏样式 （日间、夜间）
    static func setupNavigationBarStyle(_ viewController: UIViewController, _ isNight: Bool) {
        if isNight { // 设置夜间主题
            viewController.navigationController?.navigationBar.barStyle = .black
            viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background_white_night"), for: .default)
            viewController.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.grayColor113()]
        } else {     // 设置日间主题
            viewController.navigationController?.navigationBar.barStyle = .default
            viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background_white"), for: .default)
        }
    }
}
