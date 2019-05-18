//
//  PreviewUserAvatarController.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD
import Photos

class PreviewUserAvatarController: UIViewController {
    
    /// 头像 URL
    var avatar_url = ""
    
    var avatarRect: CGRect = .zero
    /// 保存图片
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        ImageDownloader.default.downloadImage(with: URL(string: avatar_url)!, progressBlock: { (receivedSize, totalSize) in
            let progress = Float(receivedSize) / Float(totalSize)
            SVProgressHUD.showProgress(progress)
            SVProgressHUD.setBackgroundColor(.clear)
            SVProgressHUD.setForegroundColor(UIColor.white)
        }) { (image, error, imageURL, data) in
            // 调用系统相册，保存到相册
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: { (success, error) in
                if success { SVProgressHUD.showSuccess(withStatus: "保存成功!") }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let avatarImageView = UIImageView()
        avatarImageView.kf.setImage(with: URL(string: avatar_url)!)
        view.addSubview(avatarImageView)
        
        UIView.animate(withDuration: 0.25, animations: {
            avatarImageView.frame = self.avatarRect
        }) { (_) in
            UIView.animate(withDuration: 0.25, animations: {
                avatarImageView.frame = CGRect(x: 0, y: (self.view.height - screenWidth) * 0.5, width: screenWidth, height: screenWidth)
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: false, completion: nil)
    }
    
}
