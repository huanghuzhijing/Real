//
//  HomeTableViewController.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

// 作为首页其他不同新闻类别的控制器的父控制器
//

import UIKit
import SVProgressHUD
import BMPlayer

class HomeTableViewController: UITableViewController {
    /// 播放器
    lazy var player: BMPlayer = BMPlayer(customControlView: VideoPlayerCustomView())
    /// 标题
    var newsTitle = HomeNewsTitle()
    /// 新闻数据
    var news = [NewsModel]()
    var newsComplete = [NewsModel]()
    /// 刷新时间
    var maxBehotTime: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.configuration()
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = "colors.tableViewBackgroundColor"
        tableView.theme_separatorColor = "colors.separatorViewColor"
    }
    
    /// 设置刷新控件
    func setupRefresh(with category: NewsTitleCategory = .hot) {
        // 刷新头部
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        let header = RefreshHeaderWeather { [weak self] in
            // 获取视频的新闻列表数据
            NetworkTool.loadApiNewsFeeds(category: category, ttFrom: .pull) {
                if self!.tableView.mj_header.isRefreshing { self!.tableView.mj_header.endRefreshing() }
                self!.player.removeFromSuperview()
                self!.maxBehotTime = $0
                self!.newsComplete =  $1.filter {
                    $0.cell_flag != 0 && !$0.label.elementsEqual("置顶")
                }
                if(self!.newsComplete.count > 0){
                    self!.news = self!.newsComplete
                    self!.tableView.reloadData()
                }
               
            }
        }
        header?.isAutomaticallyChangeAlpha = true
        header?.lastUpdatedTimeLabel.isHidden = true
        tableView.mj_header = header
        tableView.mj_header.beginRefreshing()
        // 底部刷新控件
        tableView.mj_footer = RefreshAutoGifFooter(refreshingBlock: { [weak self] in
            // 获取视频的新闻列表数据，加载更多
            NetworkTool.loadMoreApiNewsFeeds(category: category, ttFrom: .loadMore, maxBehotTime: self!.maxBehotTime, listCount: self!.news.count, {
                if self!.tableView.mj_footer.isRefreshing { self!.tableView.mj_footer.endRefreshing()}
                self!.tableView.mj_footer.pullingPercent = 0.0
                self!.player.removeFromSuperview()
                if $0.count == 0 {
                    SVProgressHUD.showInfo(withStatus: "没有更多数据啦！")
                    return
                }
                self!.newsComplete =  $0.filter(){
                    $0.cell_flag != 0
                }
                self!.news += self!.newsComplete
                self!.tableView.reloadData()
            })
        })
        tableView.mj_footer.isAutomaticallyChangeAlpha = true
        
    }
    //    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
    //        filterTodos = todos.filter(){
    //            $0.title.range(of: searchString!) != nil
    //        }
    //        return true
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
