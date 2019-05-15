//
//  ViewController.swift
//  LBFM-Swift
//
//  Created by liubo on 2019/2/1.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SwiftMessages
class ViewController: UIViewController {
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let tabbar = self.setupTabBarStyle(delegate: self as? UITabBarControllerDelegate)
        //                self.window?.backgroundColor = UIColor.white
        //                self.window?.rootViewController = tabbar
        //                self.window?.makeKeyAndVisible()
        present(tabbar, animated: false)
    }
    /// 1.加载tabbar样式
    ///
    /// - Parameter delegate: 代理
    /// - Returns: ESTabBarController
    func setupTabBarStyle(delegate: UITabBarControllerDelegate?) -> ESTabBarController {
        let tabBarController = ESTabBarController()
        tabBarController.delegate = delegate
        tabBarController.title = "Irregularity"
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        tabBarController.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            let vc = LBFMNavigationController.init(rootViewController: LBFMPlayController(albumId:albumId, trackUid:trackUid, uid:uid))
            self.present(vc, animated: true, completion: nil)
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //                let warning = MessageView.viewFromNib(layout: .cardView)
            //                warning.configureTheme(.warning)
            //                warning.configureDropShadow()
            //
            //                let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
            //                warning.configureContent(title: "Warning", body: "暂时没有此功能", iconText: iconText)
            //                warning.button?.isHidden = true
            //                var warningConfig = SwiftMessages.defaultConfig
            //                warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            //                SwiftMessages.show(config: warningConfig, view: warning)
            //                //                let vc = FMPlayController()
            //                //                tabBarController?.present(vc, animated: true, completion: nil)
            //            }
        }
        
        let home = LBFMHomeController()
        let listen = LBFMListenController()
        let play = LBFMPlayController()
        let find = LBFMFindController()
        let mine = LBFMMineController()
        
        home.tabBarItem = ESTabBarItem.init(LBFMIrregularityBasicContentView(), title: "首页", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        listen.tabBarItem = ESTabBarItem.init(LBFMIrregularityBasicContentView(), title: "我听", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        play.tabBarItem = ESTabBarItem.init(LBFMIrregularityContentView(), title: nil, image: UIImage(named: "tab_play"), selectedImage: UIImage(named: "tab_play"))
        find.tabBarItem = ESTabBarItem.init(LBFMIrregularityBasicContentView(), title: "发现", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
        mine.tabBarItem = ESTabBarItem.init(LBFMIrregularityBasicContentView(), title: "我的", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
        let homeNav = LBFMNavigationController.init(rootViewController: home)
        let listenNav = LBFMNavigationController.init(rootViewController: listen)
        let playNav = LBFMNavigationController.init(rootViewController: play)
        let findNav = LBFMNavigationController.init(rootViewController: find)
        let mineNav = LBFMNavigationController.init(rootViewController: mine)
        home.title = "首页"
        listen.title = "我听"
        play.title = "播放"
        find.title = "发现"
        mine.title = "我的"
        
        tabBarController.viewControllers = [homeNav, listenNav, playNav, findNav, mineNav]
        return tabBarController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
