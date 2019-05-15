//
//  LBFMHomeRecommendController.swift
//  LBFM-Swift
//
//  Created by liubo on 2019/2/1.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import SwiftMessages

class LBFMHomeRecommendController: UIViewController {
//    视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarBackgroundAlpha = 0
        //设置导航栏背景透明
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //视图将要消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navBarBackgroundAlpha = 1
        //重置导航栏背景
        self.navigationController?.navigationBar.shadowImage = nil
    }
    // 穿插的广告数据
    private var recommnedAdvertList:[LBFMRecommnedAdvertModel]?
    
    // cell 注册
    private let LBFMRecommendHeaderViewID     = "LBFMRecommendHeaderView"
    private let LBFMRecommendFooterViewID     = "LBFMRecommendFooterView"
    
    // 注册不同的cell
    private let LBFMRecommendHeaderCellID     = "LBFMRecommendHeaderCell"
    // 猜你喜欢
    private let LBFMRecommendGuessLikeCellID  = "LBFMRecommendGuessLikeCell"
    // 热门有声书
    private let LBFMHotAudiobookCellID        = "LBFMHotAudiobookCell"
    // 广告
    private let LBFMAdvertCellID              = "LBFMAdvertCell"
    // 懒人电台
    private let LBFMOneKeyListenCellID        = "LBFMOneKeyListenCell"
    // 为你推荐
    private let LBFMRecommendForYouCellID     = "LBFMRecommendForYouCell"
    // 推荐直播
    private let LBFMHomeRecommendLiveCellID   = "LBFMHomeRecommendLiveCell"
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = UICollectionView.init(frame:.zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .white
        // - 注册头视图和尾视图
        collection.register(LBFMRecommendHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LBFMRecommendHeaderViewID)
        collection.register(LBFMRecommendFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LBFMRecommendFooterViewID)

        // - 注册不同分区cell
        // 默认
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(LBFMRecommendHeaderCell.self, forCellWithReuseIdentifier: LBFMRecommendHeaderCellID)
        // 猜你喜欢
        collection.register(LBFMRecommendGuessLikeCell.self, forCellWithReuseIdentifier: LBFMRecommendGuessLikeCellID)
        // 热门有声书
        collection.register(LBFMHotAudiobookCell.self, forCellWithReuseIdentifier: LBFMHotAudiobookCellID)
        // 广告
        collection.register(LBFMAdvertCell.self, forCellWithReuseIdentifier: LBFMAdvertCellID)
        // 懒人电台
        collection.register(LBFMOneKeyListenCell.self, forCellWithReuseIdentifier: LBFMOneKeyListenCellID)
        // 为你推荐
        collection.register(LBFMRecommendForYouCell.self, forCellWithReuseIdentifier: LBFMRecommendForYouCellID)
        // 推荐直播
        collection.register(LBFMHomeRecommendLiveCell.self, forCellWithReuseIdentifier: LBFMHomeRecommendLiveCellID)
        collection.uHead = URefreshHeader{ [weak self] in self?.setupLoadData() }
        return collection
    }()
    lazy var viewModel: LBFMRecommendViewModel = {
        return LBFMRecommendViewModel()
    }()
   
    // 毛玻璃背景
    private lazy var blurImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加滑动视图
//
        
        self.blurImageView = UIImageView.init(frame:  CGRect(x:0 , y:0 , width: LBFMScreenWidth, height: LBFMNavBarHeight * 2 ))
        self.blurImageView.image = UIImage(named: "1")
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
        visualEffectView.frame = self.blurImageView.bounds
        //添加毛玻璃效果层
        self.blurImageView.addSubview(visualEffectView)
//        view.insertSubview(self.blurImageView, belowSubview: view)
        self.view.addSubview(self.collectionView)
        
        
        
        self.collectionView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        self.collectionView.uHead.beginRefreshing()
        setupLoadData()
        setupLoadRecommendAdData()
        
    }
    func changeNav(url: String){
        let iv = UIImageView()
        iv.kf.setImage(with: URL(string:url))
        self.blurImageView.kf.setImage(with: URL(string:url))
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
    }
    func setupLoadData(){
        // 加载数据
        viewModel.updateDataBlock = { [unowned self] in
            self.collectionView.uHead.endRefreshing()
            // 更新列表数据
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 2), at: UICollectionViewScrollPosition.bottom, animated: false)
                self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: UICollectionViewScrollPosition.bottom, animated: false)
            }
        }
        viewModel.refreshDataSource()
    }
    func setupLoadRecommendAdData() {
        // 首页穿插广告接口请求
        LBFMRecommendProvider.request(.recommendAdList) { result in
            if case let .success(response) = result {
                // 解析数据
                let data = try? response.mapJSON()
                let json = JSON(data!)
                if let advertList = JSONDeserializer<LBFMRecommnedAdvertModel>.deserializeModelArrayFrom(json: json["data"].description) { // 从字符串转换为对象实例
                    self.recommnedAdvertList = advertList as? [LBFMRecommnedAdvertModel]
                    self.collectionView.reloadData()
                    
                }
            }
        }
        
    }
}

extension LBFMHomeRecommendController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let s = viewModel.numberOfSections(collectionView:collectionView)
        return s
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let n =  viewModel.numberOfItemsIn(section: section)
        return n
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let moduleType = viewModel.homeRecommendList?[indexPath.section].moduleType
        if moduleType == "focus" || moduleType == "square" || moduleType == "topBuzz" {
            let cell:LBFMRecommendHeaderCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMRecommendHeaderCellID, for: indexPath) as! LBFMRecommendHeaderCell
            cell.focusModel = viewModel.focus
            cell.squareList = viewModel.squareList
            cell.topBuzzListData = viewModel.topBuzzList
            cell.delegate = self
            cell.changeNav = changeNav
            //            cell.backgroundColor = .clear
            //            cell.contentView.backgroundColor = .clear
            return cell
        }else if moduleType == "guessYouLike" || moduleType == "paidCategory" || moduleType == "categoriesForLong" || moduleType == "cityCategory"{
            // 横式排列布局cell
            let cell:LBFMRecommendGuessLikeCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMRecommendGuessLikeCellID, for: indexPath) as! LBFMRecommendGuessLikeCell
            cell.delegate = self
            cell.recommendListData = viewModel.homeRecommendList?[indexPath.section].list
            return cell
        }else if moduleType == "categoriesForShort" || moduleType == "playlist" || moduleType == "categoriesForExplore"{
            // 竖式排列布局cell
            let cell:LBFMHotAudiobookCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMHotAudiobookCellID, for: indexPath) as! LBFMHotAudiobookCell
            cell.delegate = self
            cell.recommendListData = viewModel.homeRecommendList?[indexPath.section].list
            return cell
        }else if moduleType == "ad" {
            let cell:LBFMAdvertCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMAdvertCellID, for: indexPath) as! LBFMAdvertCell
            if indexPath.section == 7 {
                cell.adModel = self.recommnedAdvertList?[0]
            }else if indexPath.section == 13 {
                cell.adModel = self.recommnedAdvertList?[1]
            // }else if indexPath.section == 17 {
            // cell.adModel = self.recommnedAdvertList?[2]
            }
            return cell
        }else if moduleType == "oneKeyListen" {
            let cell:LBFMOneKeyListenCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMOneKeyListenCellID, for: indexPath) as! LBFMOneKeyListenCell
            cell.oneKeyListenList = viewModel.oneKeyListenList
            return cell
        }else if moduleType == "live" {
            let cell:LBFMHomeRecommendLiveCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMHomeRecommendLiveCellID, for: indexPath) as! LBFMHomeRecommendLiveCell
            cell.liveList = viewModel.liveList
            return cell
        }else {
            let cell:LBFMRecommendForYouCell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFMRecommendForYouCellID, for: indexPath) as! LBFMRecommendForYouCell
            return cell

        }
//        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // 每个分区的内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetForSectionAt(section: section)
    }
    
    // 最小item间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.minimumInteritemSpacingForSectionAt(section: section)
    }
    
    // 最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.minimumLineSpacingForSectionAt(section: section)
    }
    
    // item 的尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let moduleType = viewModel.homeRecommendList?[indexPath.section].moduleType
        let size = viewModel.sizeForItemAt(indexPath: indexPath)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.referenceSizeForHeaderInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return viewModel.referenceSizeForFooterInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sec = indexPath.section
        let moduleType = viewModel.homeRecommendList?[indexPath.section].moduleType
        if kind == UICollectionElementKindSectionHeader {
            let headerView : LBFMRecommendHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LBFMRecommendHeaderViewID, for: indexPath) as! LBFMRecommendHeaderView
            headerView.homeRecommendList = viewModel.homeRecommendList?[indexPath.section]
            // 分区头右边更多按钮点击跳转
            headerView.headerMoreBtnClick = {[weak self]() in
                if moduleType == "guessYouLike"{
                    let vc = LBFMHomeGuessYouLikeMoreController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else if moduleType == "paidCategory" {
                    let vc = LBFMHomeVIPController(isRecommendPush:true)
                    vc.title = "精品"
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else if moduleType == "live"{
                    let vc = LBFMHomeLiveController()
                    vc.title = "直播"
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else {
                    guard let categoryId = self?.viewModel.homeRecommendList?[indexPath.section].target?.categoryId else {return}
                    if categoryId != 0 {
                        let vc = LBFMClassifySubMenuController(categoryId:categoryId,isVipPush:false)
                        vc.title = self?.viewModel.homeRecommendList?[indexPath.section].title
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            return headerView
        }else if kind == UICollectionElementKindSectionFooter {
            let footerView : LBFMRecommendFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LBFMRecommendFooterViewID, for: indexPath) as! LBFMRecommendFooterView
            return footerView
        }
        return UICollectionReusableView()
    }
}
// - 点击顶部分类按钮进入相对应界面
extension LBFMHomeRecommendController:LBFMRecommendHeaderCellDelegate {
    
    func recommendHeaderBannerClick(url: String) {
        
        
           
            let vc = LBFMWebViewController(url:url)
            vc.title = title
            self.navigationController?.pushViewController(vc, animated: true)
        

    }

    func recommendHeaderBtnClick(categoryId:String,title:String,url:String){
        if url == ""{
            if categoryId == "0"{
                let warning = MessageView.viewFromNib(layout: .cardView)
                warning.configureTheme(.warning)
                warning.configureDropShadow()

                let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
                warning.configureContent(title: "Warning", body: "暂时没有数据!!!", iconText: iconText)
                warning.button?.isHidden = true
                var warningConfig = SwiftMessages.defaultConfig
                warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
                SwiftMessages.show(config: warningConfig, view: warning)
            }else{
                let vc = LBFMClassifySubMenuController(categoryId:Int(categoryId)!)
                vc.title = title
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let vc = LBFMWebViewController(url:url)
            vc.title = title
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// - 点击猜你喜欢cell代理方法
extension LBFMHomeRecommendController:LBFMRecommendGuessLikeCellDelegate {
    func recommendGuessLikeCellItemClick(model: LBFMRecommendListModel) {
        let vc = LBFMPlayDetailController(albumId: model.albumId)
        self.navigationController?.pushViewController(vc, animated: true)
        print("点击猜你喜欢")
    }
}

// - 点击热门有声书等cell代理方法
extension LBFMHomeRecommendController:LBFMHotAudiobookCellDelegate {
    func hotAudiobookCellItemClick(model: LBFMRecommendListModel) {
        let vc = LBFMPlayDetailController(albumId: model.albumId)
        self.navigationController?.pushViewController(vc, animated: true)
        print("点击热门有声书")
    }
}
extension LBFMHomeRecommendController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        let offsetY = scrollView.contentOffset.y
        if (Int(offsetY) > kNavBarBottom)
        {
            let alpha = offsetY / CGFloat(kNavBarBottom)
            navBarBackgroundAlpha = alpha
//            self.rightBarButton1.setImage(UIImage(named: "icon_more_n_30x31_"), for: UIControlState.normal)
//            self.rightBarButton2.setImage(UIImage(named: "icon_share_n_30x30_"), for: UIControlState.normal)
        }else{
            navBarBackgroundAlpha = 0
//            self.rightBarButton1.setImage(UIImage(named: "icon_more_h_30x31_"), for: UIControlState.normal)
//            self.rightBarButton2.setImage(UIImage(named: "icon_share_h_30x30_"), for: UIControlState.normal)
        }
    }
}




