//
//  PreviewDongtaiBigImageLayout.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/10.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit

class PreviewDongtaiBigImageLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        itemSize = CGSize(width: collectionView!.width, height: collectionView!.height)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
    
}
