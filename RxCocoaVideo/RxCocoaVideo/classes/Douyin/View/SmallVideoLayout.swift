//
//  SmallVideoLayout.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/12.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit

class SmallVideoLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        itemSize = CGSize(width: collectionView!.width, height: collectionView!.height)
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .vertical
    }
    
}
