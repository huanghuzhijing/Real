//
//  DongtaiCollectionView1.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/10.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit

class DongtaiCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, NibLoadable {
    
    var didSelect: ((_ selectedIndex: Int)->())?
    /// 是否发布了小视频
    var isPostSmallVideo = false
    /// 是否是动态详情
    var isDongtaiDetail = false
    
    var isWeitoutiao = false
    
    var thumbImages = [ThumbImage]() {
        didSet {
            reloadData()
        }
    }
    
    var largeImages = [ThumbImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = self
        backgroundColor = .clear
        collectionViewLayout = DongtaiCollectionViewFlowLayout()
        ym_registerCell(cell: DongtaiCollectionViewCell.self)
        isScrollEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.ym_dequeueReusableCell(indexPath: indexPath) as DongtaiCollectionViewCell
        DispatchQueue.global().async {
           cell.thumbImage = self.thumbImages[indexPath.item]
        }
        cell.isPostSmallVideo = isPostSmallVideo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return isDongtaiDetail ? Calculate.detailCollectionViewCellSize(thumbImages) : Calculate.collectionViewCellSize(thumbImages.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isWeitoutiao { didSelect?(indexPath.item); return }
        let previewBigImageVC = PreviewDongtaiBigImageController()
        previewBigImageVC.images = largeImages
        previewBigImageVC.selectedIndex = indexPath.item
        UIApplication.shared.keyWindow?.rootViewController?.present(previewBigImageVC, animated: false, completion: nil)
    }
}

class DongtaiCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 5
        minimumInteritemSpacing = 5
    }
}
