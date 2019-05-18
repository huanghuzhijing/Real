//
//  UserDetailViewController.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - 自定义一个可以接受上层 tableView 手势的 tableView
class UserDetailTableView: UITableView, UIGestureRecognizerDelegate {
    // 底层 tableView 实现这个 UIGestureRecognizerDelegate 代理方法，就可以响应上层 tableView 的滑动手势，
    // otherGestureRecognizer 就是它上层的 view 持有的手势，这里的话，上层应该是 scrollView 和 顶层 tabelview
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 保证其他手势的存在
        guard let otherView = otherGestureRecognizer.view else { return false }
        // 如果其他手势的 view 是 UIScrollView，就不能让 UserDetailTableView 响应
        if otherView.isMember(of: UIScrollView.self) { return false }
        // 其他手势是 tableView 的 pan 手势，就让他响应
        let isPan = gestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        if isPan && otherView.isKind(of: UIScrollView.self) { return true }
        return false
    }
}

class UserDetailViewController: UIViewController {
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent    }

    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UserDetailTableView!
    
 
    
    var userId: Int = 0
    var userDetail = UserDetail()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background_clear"), for: .default)
        navigationController?.navigationBar.isTranslucent = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = false
        if(redOrWhite.elementsEqual("red")){
             navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background"), for: .default)
            StatusBarBGC.setStatusBarBackgroundColor(color: redColor!)
        }else{
            navigationController?.navigationBar.barStyle = .default
             navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background_white"), for: .default)
        }
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_background_white"), for: .default)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 UI
        setupUI()
        // 按钮点击
        selectedAction()
    }
    /// 懒加载 头部
    private lazy var headerView = UserDetailHeaderView2.loadViewFromNib()
    /// 懒加载 底部
    //    private lazy var myBottomView: UserDetailBottomView = {
    //        let myBottomView = UserDetailBottomView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    //        myBottomView.delegate = self
    //        return myBottomView
    //    }()
    /// 懒加载 导航栏
    private lazy var navigationBar = UserDetailNavigationBar.loadViewFromNib()
    /// 懒加载 导航栏
    private lazy var topTabScrollView = TopTabScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension UserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        view.addSubview(topTabScrollView)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.ym_dequeueReusableCell(indexPath: indexPath) as UserDetailCell
        return cell
    }
    //上下滑动个人动态列表时，调用scrollViewDidScroll方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let navigationBarHeight: CGFloat = isIPhoneX ? -88.0 : -64.0
        
        if offsetY < navigationBarHeight {
            let totalOffset = kUserDetailHeaderBGImageViewHeight + abs(offsetY)
            let f = totalOffset / kUserDetailHeaderBGImageViewHeight
            headerView.backgroundImageView.frame = CGRect(x: -screenWidth * (f - 1) * 0.5, y: offsetY, width: screenWidth * f, height: totalOffset)
            navigationBar.navigationBar.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        } else {
            
            var alpha: CGFloat = (offsetY + 40) / 58
            alpha = min(alpha, 1.0)
//            navigationBar.navigationBar.backgroundColor = UIColor(white: 1.0, alpha: alpha)
//            preferredStatusBarStyle.rawValue = 11
            navigationBar.backgroundColor = UIColor(white: 1.0, alpha: alpha)
            StatusBarBGC.setStatusBarBackgroundColor(color: UIColor(white: 1.0, alpha: alpha))
//           preferredStatusBa
            if alpha == 1.0 {
                
                navigationController?.navigationBar.barStyle = .default
                navigationBar.returnButton.theme_setImage("images.personal_home_back_black_24x24_", forState: .normal)
                navigationBar.moreButton.theme_setImage("images.new_more_titlebar_24x24_", forState: .normal)
            } else {
                navigationController?.navigationBar.barStyle = .black
                navigationBar.returnButton.theme_setImage("images.personal_home_back_white_24x24_", forState: .normal)
                navigationBar.moreButton.theme_setImage("images.new_morewhite_titlebar_22x22_", forState: .normal)
            }
            // 14 + 15 + 14
            var alpha1: CGFloat = offsetY / 57
            if offsetY >= 43 {
//                navigationController?.navigationBar.isTranslucent = false
                alpha1 = min(alpha1, 1.0)
                navigationBar.nameLabel.isHidden = false
                navigationBar.concernButton.isHidden = false
                navigationBar.nameLabel.textColor = UIColor(r: 0, g: 0, b: 0, alpha: alpha1)
                navigationBar.concernButton.alpha = alpha1
            } else {
                
                alpha1 = min(0.0, alpha1)
                navigationBar.nameLabel.textColor = UIColor(r: 0, g: 0, b: 0, alpha: alpha1)
                navigationBar.concernButton.alpha = alpha1
            }
            
            headerView.y = 0
//            if offsetY >= -46 {
//                navigationController?.navigationBar.isTranslucent = false
//            }else{
//                navigationController?.navigationBar.isTranslucent = true
//            }
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    
}

// MARK: - 点击事件
extension UserDetailViewController {
    
    /// 按钮点击
    private func selectedAction() {
        // 返回按钮点击
        navigationBar.returnButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in // 需要加 [weak self] 防止循环引用
                self?.navigationBar.backgroundColor = UIColor(white: 1.0, alpha: 1)
                StatusBarBGC.setStatusBarBackgroundColor(color: UIColor(white: 1.0, alpha: 1))
                UIApplication.shared.statusBarStyle = .default
//                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute:
//                    {
//
                self!.navigationController?.popViewController(animated: true)
//                })
               
            })
            .disposed(by: disposeBag)
        // 更多按钮点击
        navigationBar.moreButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { () in // 需要加 [weak self] 防止循环引用
                
            })
            .disposed(by: disposeBag)
        // 点击了关注按钮
        headerView.didSelectConcernButton = { [weak self] in
            self!.tableView.tableHeaderView = self!.headerView
        }
        // 当前的 topTab 类型
        topTabScrollView.currentTopTab = { [weak self] (topTab, index) in
            let cell = self!.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UserDetailCell
            let dongtaiVC = self!.childViewControllers[index] as! DongtaiTableViewController
            dongtaiVC.currentTopTabType = topTab.type
            // 偏移
            cell.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * screenWidth, y: 0), animated: true)
        }
    }
    
    
}

extension UserDetailViewController {
    /// 设置 UI
    private func setupUI() {
        view.theme_backgroundColor = "colors.cellBackgroundColor"
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationController?.navigationBar.barStyle = .black
        navigationItem.titleView = navigationBar
        tableView.ym_registerCell(cell: UserDetailCell.self)
//        tableView.tableFooterView = UIView()
        /// 获取用户详情数据  张雪峰 53271122458 马未都 51025535398
        //        userId = 8   // 这里可以注释掉，那么就会是不同的 userId 了
        NetworkTool.loadUserDetail(userId: userId) { (userDetail) in
            // 获取用户详情的动态列表数据
            NetworkTool.loadUserDetailDongtaiList(userId: self.userId, maxCursor: 0, completionHandler: { (cursor, dongtais) in
                if userDetail.bottom_tab.count != 0 {
                    // 底部 view 的高度
                    self.view.layoutIfNeeded()
                    //                    middleView.addSubview(originThreadView)
                    //                    originThreadView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: dongtai.origin_thread.height)
                    //                    originThreadView.originthread = dongtai.origin_thread  self.myBottomView.bottomTabs = userDetail.bottom_tab
                    //                    self.bottomview.addSubview(self.myBottomView)
                }
                self.userDetail = userDetail
                self.headerView.userDetail = userDetail
                self.navigationBar.userDetail = userDetail
                self.topTabScrollView.topTabs = userDetail.top_tab
                self.tableView.tableHeaderView = self.headerView
                let navigationBarHeight: CGFloat = isIPhoneX ? 88.0 : 64.0
                let rowHeight = screenHeight - navigationBarHeight - self.tableView.sectionHeaderHeight
                self.tableView.rowHeight = rowHeight
                // 一定要先 reload 一次，否则不能刷新数据，也不能设置行高
                self.tableView.reloadData()
                if userDetail.top_tab.count == 0 { return }
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UserDetailCell
                // 遍历
                for (index, topTab) in userDetail.top_tab.enumerated() {
                    let dongtaiVC = DongtaiTableViewController()
                    self.addChildViewController(dongtaiVC)
                    if index == 0 { dongtaiVC.currentTopTabType = topTab.type }
                    dongtaiVC.userId = userDetail.user_id
                    dongtaiVC.tableView.frame = CGRect(x: CGFloat(index) * screenWidth, y: 0, width: screenWidth, height: rowHeight)
                    cell.scrollView.addSubview(dongtaiVC.tableView)
                    if index == userDetail.top_tab.count - 1 {
                        cell.scrollView.contentSize = CGSize(width: CGFloat(userDetail.top_tab.count) * screenWidth, height: cell.scrollView.height)
                    }
                }
            })
        }
    }
}
