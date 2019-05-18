//
//  LBFMHomeController.swift
//  LBFM-Swift
//
//  Created by liubo on 2019/2/1.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit
import DNSPageView
class LBFMHomeController: UIViewController {
    
    //Mark: - 导航栏右边按钮
    private lazy var rightBarButton1:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x:0, y:0, width:30, height: 30)
        button.setImage(UIImage(named: "icon_more_h_30x31_"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(listen), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    //Mark: - 导航栏右边按钮
    private lazy var rightBarButton2:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x:0, y:0, width:30, height: 30)
        button.setImage(UIImage(named: "icon_share_h_30x30_"), for: UIControlState.normal)
//        button.addTarget(self, action: #selector(nil), for: UIControlEvents.touchUpInside)
        return button
    }()
    @objc func listen(){
        let vc = LBFMHomeClassifyController()
        vc.title = "分类"
        let rvc = LBFMNavigationController.init(rootViewController: vc)
        self.present(rvc, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarBackgroundAlpha = 0
        view.backgroundColor = UIColor.white
        
        // 单独设置titleView的frame
        navigationItem.titleView = pageViewManager.titleView
        pageViewManager.titleView.frame = CGRect(x: 0, y: 0, width: LBFMScreenWidth - 160, height: 44)
        let rightBarButtonItem1:UIBarButtonItem = UIBarButtonItem.init(customView: rightBarButton1)
        let rightBarButtonItem2:UIBarButtonItem = UIBarButtonItem.init(customView: rightBarButton2)
        
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem1]

        // 单独设置contentView的大小和位置，可以使用autolayout或者frame
        let contentView = pageViewManager.contentView
        view.addSubview(pageViewManager.contentView)
        contentView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            contentView.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    private lazy var pageViewManager: DNSPageViewManager = {
        // 创建DNSPageStyle，设置样式
        let style = DNSPageStyle()
        style.isShowBottomLine = true
        style.isTitleViewScrollEnabled = true
        style.titleViewBackgroundColor = UIColor.clear
        style.titleSelectedColor = UIColor.black
        style.titleColor = UIColor.gray
        style.bottomLineColor = LBFMButtonColor
        style.bottomLineHeight = 2
        
        // 设置标题内容
        let titles = ["推荐","会员","直播","广播"]
        let viewControllers:[UIViewController] = [LBFMHomeRecommendController(),LBFMHomeVIPController(),LBFMHomeLiveController(),LBFMHomeBroadcastController()]
        for vc in viewControllers{
            self.addChildViewController(vc)
        }
       
        
        return DNSPageViewManager(style: style, titles: titles, childViewControllers: childViewControllers)
    }()
    func setupPageStyle() {
        // 创建DNSPageStyle，设置样式
        let style = DNSPageStyle()
        style.isTitleViewScrollEnabled = false
        style.isTitleScaleEnabled = true
        style.isShowBottomLine = true
        style.titleSelectedColor = UIColor.black
        style.titleColor = UIColor.gray
        style.bottomLineColor = LBFMButtonColor
        style.bottomLineHeight = 2
        
        let titles = ["推荐","分类","VIP","直播","广播"]
        let viewControllers:[UIViewController] = [LBFMHomeRecommendController(),LBFMHomeClassifyController(),LBFMHomeVIPController(),LBFMHomeLiveController(),LBFMHomeBroadcastController()]
        for vc in viewControllers{
            self.addChildViewController(vc)
        }
        let pageView = DNSPageView(frame: CGRect(x: 0, y: LBFMNavBarHeight, width: LBFMScreenWidth, height: LBFMScreenHeight - LBFMNavBarHeight - 44), style: style, titles: titles, childViewControllers: viewControllers)
        pageView.contentView.backgroundColor = UIColor.red
        view.addSubview(pageView)
    }

}
