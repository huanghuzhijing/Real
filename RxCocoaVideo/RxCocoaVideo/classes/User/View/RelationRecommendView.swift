//
//  RelationRecommendView.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//  userDetail视图中点击关注后，推送的推荐关注

import UIKit

class RelationRecommendView: UIView, NibLoadable {

    var userCards = [UserCard]()

    @IBOutlet weak var labelHeight: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        theme_backgroundColor = "colors.cellBackgroundColor"
        collectionView.collectionViewLayout = RelationRecommendFlowLayout()
        collectionView.ym_registerCell(cell: RelationRecommendCell.self)
        collectionView.delegate = self
        collectionView.dataSource  = self
    }

}

extension RelationRecommendView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.ym_dequeueReusableCell(indexPath: indexPath) as RelationRecommendCell
        cell.userCard = userCards[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

class RelationRecommendFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        itemSize = CGSize(width: 142, height: 190)
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
    }
}
