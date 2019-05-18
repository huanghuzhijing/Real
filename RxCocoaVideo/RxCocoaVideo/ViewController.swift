//
//  ViewController.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposrBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.configuration()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController{
    func setUI(){
        let btn = UIButton()
        btn.setTitle("click", for: .normal)
        btn.setTitleColor(UIColor.cyan, for: .normal)
        btn.backgroundColor = UIColor.red
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 6
         view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(44)
            $0.top.equalToSuperview().offset(444)
            
        }
        
        btn.rx.controlEvent(.touchUpInside).subscribe(onNext:
            {
                SVProgressHUD.showInfo(withStatus: "change")
                let group = DispatchGroup()
//                var index = 0
                let gloableQueue = DispatchQueue.global()
                gloableQueue.async(group: group, execute: {
                    print(Thread.current,"current")
                })
//                gloableQueue.async {
//                    for index1 in 0...10{
//                        Thread.sleep(forTimeInterval: 1)
//                        index = index1
//                        print(index)
//                        SVProgressHUD.showProgress(Float(index/9))
//                    }
//                }
               
                
            }
        ).disposed(by: disposrBag)
       
    }
}
