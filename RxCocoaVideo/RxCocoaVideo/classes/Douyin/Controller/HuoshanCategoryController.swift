//
//  HuoshanCategoryController.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/12.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import SVProgressHUD

var firstPlay: Int?
class HuoshanCategoryController: UIViewController {
    /// 标题
    var newsTitle = HomeNewsTitle()
    
    @IBOutlet weak var collectionView: UICollectionView!
    /// 刷新时间
    var maxBehotTime: TimeInterval = 0.0
    /// 视频数据
    var smallVideos = [NewsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.configuration()
        collectionView.collectionViewLayout = HuoshanLayout()
        collectionView.theme_backgroundColor = "colors.tableViewBackgroundColor"
        collectionView.ym_registerCell(cell: HuoshanCell.self)
        // 添加刷新控件
        setRefresh()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute:
            {
                if let index = firstPlay{
                    if(index != -1){
                        let smallVideoVC = SmallVideoViewController()
                        smallVideoVC.originalIndex = index
                        smallVideoVC.smallVideos = self.smallVideos
                        UIApplication.shared.setStatusBarHidden(true, with: .fade)
                        self.present(smallVideoVC, animated: false, completion: nil)
                        firstPlay = nil
                    }
                }
        })
        
    }
    /// 添加刷新控件
    func setRefresh() {
        // 下拉刷新
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        let header = RefreshHeader { [weak self] in
            // 获取首页、视频、小视频的新闻列表数据
            NetworkTool.loadApiNewsFeeds(category: self!.newsTitle.category, ttFrom: .enterAuto) {
                if self!.collectionView.mj_header.isRefreshing { self!.collectionView.mj_header.endRefreshing() }
                self!.maxBehotTime = $0
                self!.smallVideos = $1
                self!.collectionView.reloadData()
            }
        }
        header?.isAutomaticallyChangeAlpha = true
        header?.lastUpdatedTimeLabel.isHidden = true
        collectionView.mj_header = header
        header?.beginRefreshing()
        // 添加加载更多数据
        collectionView.mj_footer = RefreshAutoGifFooter(refreshingBlock: { [weak self] in
            NetworkTool.loadMoreApiNewsFeeds(category: self!.newsTitle.category, ttFrom: .enterAuto, maxBehotTime: self!.maxBehotTime, listCount: self!.smallVideos.count, {
                if self!.collectionView.mj_footer.isRefreshing { self!.collectionView.mj_footer.endRefreshing() }
                self!.collectionView.mj_footer.pullingPercent = 0.0
                if $0.count == 0 {
                    SVProgressHUD.showInfo(withStatus: "没有更多数据啦！")
                    return
                }
                self!.smallVideos += $0
                self!.collectionView.reloadData()
            })
        })
        collectionView.mj_footer.isAutomaticallyChangeAlpha = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HuoshanCategoryController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return smallVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.ym_dequeueReusableCell(indexPath: indexPath) as HuoshanCell
        cell.smallVideo = smallVideos[indexPath.item]
        if(firstPlay == nil && firstPlay != -1) {firstPlay = indexPath.item}
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let smallVideoVC = SmallVideoViewController()
        smallVideoVC.originalIndex = indexPath.item
        smallVideoVC.smallVideos = smallVideos
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
        present(smallVideoVC, animated: false, completion: nil)
    }
}

class HuoshanLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        let itemWidth = (screenWidth - 2) * 0.5
        itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        scrollDirection = .vertical
        minimumLineSpacing = 1.0
        minimumInteritemSpacing = 1.0
    }
}
