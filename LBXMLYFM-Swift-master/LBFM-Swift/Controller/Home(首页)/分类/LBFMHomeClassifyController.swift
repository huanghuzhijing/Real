//
//  LBFMHomeClassifyController.swift
//  LBFM-Swift
//
//  Created by liubo on 2019/2/1.
//  Copyright © 2019 刘博. All rights reserved.
//

import UIKit

class LBFMHomeClassifyController: UIViewController {
   
    private let LBFMCellIdentifier = "LBFMHomeClassifyCell"
    private let LBFMHomeClassifyFooterViewID = "LBFMHomeClassifyFooterView"
    private let LBFMHomeClassifyHeaderViewID = "LBFMHomeClassifyHeaderView"
    // - 导航栏左边按钮
    private lazy var leftBarButton:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x:0, y:0, width:30, height: 30)
        button.setImage(UIImage(named: "playpage_icon_down_black_30x30_"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(leftBarButtonClick), for: UIControlEvents.touchUpInside)
        return button
    }()
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.register(LBFMHomeClassifyHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LBFMHomeClassifyHeaderViewID)
        collection.register(LBFMHomeClassifyFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LBFMHomeClassifyFooterViewID)
        
        collection.backgroundColor = LBFMDownColor
        return collection
    }()
    
    lazy var viewModel: LBFMHomeClassifyViewModel = {
        return LBFMHomeClassifyViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.left.right.top.height.equalToSuperview()
        }
        // 加载数据
        setupLoadData()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarButton)
    }
    @objc func leftBarButtonClick(){
        self.dismiss(animated: true)
    }
    func setupLoadData(){
        // 加载数据
        viewModel.updataBlock = { [unowned self] in
            // 更新列表数据
            self.collectionView.reloadData()
        }
        viewModel.refreshDataSource()
    }
}

extension LBFMHomeClassifyController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections(collectionView:collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsIn(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier:String = "\(indexPath.section)\(indexPath.row)"
        self.collectionView.register(LBFMHomeClassifyCell.self, forCellWithReuseIdentifier: identifier)
        let cell:LBFMHomeClassifyCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! LBFMHomeClassifyCell
        cell.backgroundColor = UIColor.white
        cell.layer.masksToBounds =  true
        cell.layer.cornerRadius = 4.0
        cell.layer.borderColor = UIColor.init(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1).cgColor
        cell.layer.borderWidth = 0.5
        cell.itemModel = viewModel.classifyModel?[indexPath.section].itemList![indexPath.row]
        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let categoryId:Int = viewModel.classifyModel?[indexPath.section].itemList![indexPath.row].itemDetail?.categoryId ?? 0
        let title = viewModel.classifyModel?[indexPath.section].itemList![indexPath.row].itemDetail?.title ?? ""
        let vc = LBFMClassifySubMenuController(categoryId: categoryId)
        vc.title = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //每个分区的内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetForSectionAt(section: section)
    }
    
    //最小 item 间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.minimumInteritemSpacingForSectionAt(section: section)
    }
    
    //最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.minimumLineSpacingForSectionAt(section: section)
    }
    
    //item 的尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItemAt(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.referenceSizeForHeaderInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return viewModel.referenceSizeForFooterInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView : LBFMHomeClassifyHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LBFMHomeClassifyHeaderViewID, for: indexPath) as! LBFMHomeClassifyHeaderView
            headerView.titleString = viewModel.classifyModel?[indexPath.section].groupName
            return headerView
        }else if kind == UICollectionElementKindSectionFooter {
            let footerView : LBFMHomeClassifyFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LBFMHomeClassifyFooterViewID, for: indexPath) as! LBFMHomeClassifyFooterView
            return footerView
        }
        return UICollectionReusableView()
    }
}
