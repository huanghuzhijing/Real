//
//  HomeViewController.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import SGPagingView
import RxSwift
import RxCocoa

var redColor: UIColor?
class HomeViewController: UIViewController {
    /// 标题和内容
    private var pageTitleView: SGPageTitleView?
    private var pageContentView: SGPageContentCollectionView?
    override var prefersStatusBarHidden: Bool {
        return false
        
    }
    
    /// 自定义导航栏
    private lazy var navigationBar = HomeNavigationView.loadViewFromNib()
    
    private lazy var disposeBag = DisposeBag()
    /// 添加频道按钮
    private lazy var addChannelButton: UIButton = {
        let addChannelButton = UIButton(frame: CGRect(x: screenWidth - newsTitleHeight, y: 0, width: newsTitleHeight, height: newsTitleHeight))
        addChannelButton.theme_setImage("images.add_channel_titlbar_thin_new_16x16_", forState: .normal)
        let separatorView = UIView(frame: CGRect(x: 0, y: newsTitleHeight - 1, width: newsTitleHeight, height: 1))
        separatorView.theme_backgroundColor = "colors.separatorViewColor"
        addChannelButton.addSubview(separatorView)
        return addChannelButton
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StatusBarBGC.setStatusBarBackgroundColor(color: UIColorFromRGB(rgbValue: 0xC44943))
//        UIApplication.shared.keyWindow?.theme_backgroundColor = "colors.windowColor"
//        // 设置状态栏属性
//        navigationController?.navigationBar.barStyle = .black
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background" + (UserDefaults.standard.bool(forKey: isNight) ? "_night" : "")), for: .default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置 UI
        setupUI()
        // 点击事件
        clickAction()
    }
}

// MARK: - 导航栏按钮点击
extension HomeViewController {
    
    /// 设置 UI
    private func setupUI() {
        let url = ""
        if(redColor == nil ){  redColor = navigationBar.backgroundColor!}
        view.theme_backgroundColor = "colors.cellBackgroundColor"
        // 设置自定义导航栏
        navigationItem.titleView = navigationBar
        // 添加频道
        view.addSubview(addChannelButton)
//        let queue = DispatchQueue.global()
//        let group = DispatchGroup.init()
//        queue.async(group: group, execute: {
//            for i in 1...9 {
//                print(i)
//            }
//        })
//        queue.async(group: group, execute: {
//            let data = NSData.init(contentsOf: URL.init(string: url)!)
//            let img = UIImage.init(data: data! as Data )
//            for i in 11...19 {
//                print(i)
//            }
//            
//        })
//        
//        group.wait()
//        print(222)
        // 首页顶部新闻标题的数据
        NetworkTool.loadHomeNewsTitleData {
            // 向数据库中插入数据
            let news: [HomeNewsTitle] = $0.filter{
                !$0.name.elementsEqual("北京")
            }
            NewsTitleTable().insert(news)
            let configuration = SGPageTitleViewConfigure()
            configuration.titleColor = .black
            configuration.titleSelectedColor = .globalRedColor()
            configuration.indicatorColor = .clear
            // 标题名称的数组
            self.pageTitleView = SGPageTitleView(frame: CGRect(x: 0, y: 0, width: screenWidth - newsTitleHeight, height: newsTitleHeight), delegate: self, titleNames: news.compactMap({
                return $0.name }), configure: configuration)
            self.pageTitleView!.backgroundColor = .clear
            self.view.addSubview(self.pageTitleView!)
            // 设置子控制器
            _ = news.compactMap({ (newsTitle) -> () in
                    let videoTableVC = VideoTableViewController()
                    videoTableVC.newsTitle = newsTitle
                    videoTableVC.setupRefresh(with: .video)
                    self.addChildViewController(videoTableVC)
            })
            // 内容视图
            self.pageContentView = SGPageContentCollectionView(frame: CGRect(x: 0, y: newsTitleHeight, width: screenWidth, height: self.view.height - newsTitleHeight), parentVC: self, childVCs: self.childViewControllers)
            self.pageContentView?.delegatePageContentCollectionView = self
            self.view.addSubview(self.pageContentView!)
        }
    }
    
    /// 点击事件
    private func clickAction() {
        // 搜索按钮点击
        navigationBar.didSelectSearchButton = {
           self.present(SunRevolutionViewController(), animated: true, completion: nil)
        }
        // 头像按钮点击
        navigationBar.didSelectAvatarButton = { [weak self] in
            let storyboard = UIStoryboard(name: String(describing: MoreLoginViewController.self), bundle: nil)
            let moreLoginVC = storyboard.instantiateViewController(withIdentifier: String(describing: MoreLoginViewController.self)) as! MoreLoginViewController
            moreLoginVC.modalSize = (width: .full, height: .custom(size: Float(screenHeight - (isIPhoneX ? 44 : 20))))
            UIApplication.shared.keyWindow?.rootViewController?.present(moreLoginVC, animated: true, completion: nil)
        }
        // 相机按钮点击
        navigationBar.didSelectCameraButton = {
            
        }
        /// 添加频道点击
        //        addChannelButton.rx.controlEvent(.touchUpInside)
        //            .subscribe(onNext: { [weak self] in
        //                let homeAddCategoryVC = HomeAddCategoryController.loadStoryboard()
        //                homeAddCategoryVC.modalSize =     (width: .full, height: .custom(size: Float(screenHeight - (isIPhoneX ? 44 : 20))))
        //                self!.present(homeAddCategoryVC, animated: true, completion: nil)
        //            })
        //            .disposed(by: disposeBag)
    }
    
}

// MARK: - SGPageTitleViewDelegate
extension HomeViewController: SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate {
    /// 联动 pageContent 的方法
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        self.pageContentView?.setPageContentCollectionViewCurrentIndex(selectedIndex)
    }
    
    /// 联动 SGPageTitleView 的方法
    func pageContentView(_ pageContentView: SGPageContentCollectionView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        self.pageTitleView!.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
    }
}
