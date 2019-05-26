//
//  SunRevolutionViewController.swift
//  RxCocoaVideo
//
//  Created by 胡涛 on 2019/5/26.
//  Copyright © 2019 胡涛. All rights reserved.
//

import UIKit
//引入ARkit所需的包
import ARKit
import SceneKit


class SunRevolutionViewController: UIViewController,ARSCNViewDelegate {
    
    //需要arscenview、ARSession、ARConfiguration ar必备的三个
    
    let arSCNView = ARSCNView()
    let arSession = ARSession()
    let arConfiguration = ARWorldTrackingConfiguration()
    
    //添加太阳、地球、月亮节点
    let sunNode = SCNNode()
    let moonNode = SCNNode()
    let earthNode = SCNNode()
    let moonRotationNode = SCNNode()//月球围绕地球转动的节点
    let earthGroupNode =  SCNNode()//地球和月球当做一个整体的节点 围绕太阳公转需要
    
    let sunHaloNode = SCNNode()//太阳光晕
    
    
    
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        // Pause the view's session
        arSession.pause()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        StatusBarBGC.setStatusBarBackgroundColor(color: .clear)
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        arConfiguration.isLightEstimationEnabled = true//自适应灯光（室內到室外的話 畫面會比較柔和）
        
        arSession.run(arConfiguration, options: [.removeExistingAnchors,.resetTracking])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIButton()
        button1.setImage(UIImage(named: "lefterbackicon_titlebar_24x24_"), for: .normal)
        button1.addTarget(self, action: #selector(resetX), for: UIControlEvents.touchUpInside)
        let buttonItem1 = UIBarButtonItem.init(customView: button1)
        
        let button2 = UIButton()
        button2.setImage(UIImage(named: "feed_share_24x24_"), for: .normal)
        button2.addTarget(self, action: #selector(resetY), for: UIControlEvents.touchUpInside)
        let buttonItem2 = UIBarButtonItem.init(customView: button2)
        
        let button3 = UIButton()
        button3.setImage(UIImage(named: "history_profile_24x24_"), for: .normal)
        button3.addTarget(self, action: #selector(resetZ), for: UIControlEvents.touchUpInside)
        let buttonItem3 = UIBarButtonItem.init(customView: button3)
        
        navigationItem.rightBarButtonItems = [buttonItem1,buttonItem2,buttonItem3]
        //设置arSCNView属性 history_profile_24x24_ lefterbackicon_titlebar_
        arSCNView.frame = self.view.frame
        
        arSCNView.session = arSession
        arSCNView.automaticallyUpdatesLighting = true//自动调节亮度
        
        self.view.addSubview(arSCNView)
        arSCNView.addSubview(button3)
        arSCNView.addSubview(button2)
        arSCNView.addSubview(button1)
        button1.snp.makeConstraints(){
            $0.top.equalToSuperview().offset(30)
            $0.left.equalToSuperview().offset(30)
            $0.width.height.equalTo(30)
        }
        button2.snp.makeConstraints(){
            $0.top.equalToSuperview().offset(30)
            $0.right.equalToSuperview().offset(-30)
            $0.width.height.equalTo(30)
        }
        button3.snp.makeConstraints(){
            $0.top.equalToSuperview().offset(30)
            $0.right.equalTo(button2.snp.left).offset(-30)
            $0.width.height.equalTo(30)
        }
        
        arSCNView.delegate = self
        
        self.initNode()
        
        self.sunRotation()
        
        self.earthTurn()
        
        self.sunTurn()
        
        self.addLight()
        
        // Do any additional setup after loading the view.
    }
    var x = 0
    var y = 0
    var z = -15
    @objc func resetX(){
        setBack()
    }
    @objc func resetY(){
        self.dismiss(animated: true)
    }
    @objc func resetZ(){
        arSession.pause()
        arSession.run(arConfiguration, options: [.removeExistingAnchors,.resetTracking])
        x = 0
        y = 0
        z = -15
        sunNode.position = SCNVector3(x, y, z)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setBack(){
        let sphore = SCNSphere(radius: 15)
        let backNode = SCNNode(geometry: sphore)
        sphore.firstMaterial?.diffuse.contents = UIImage(named: "star")
        sphore.firstMaterial?.isDoubleSided = true
        backNode.position = SCNVector3Zero
        self.arSCNView.scene.rootNode.addChildNode(backNode)
    }
    
    //MARK:初始化节点信息
    func initNode()  {
        
        //1.设置几何
        sunNode.geometry = SCNSphere(radius: 3)
        earthNode.geometry =  SCNSphere(radius: 1)
        moonNode.geometry =  SCNSphere(radius: 0.5)
        //2.渲染图
        // multiply： 把整张图拉伸，之后会变淡
        //diffuse:平均扩散到整个物体的表面，平切光泽透亮
        //   AMBIENT、DIFFUSE、SPECULAR属性。这三个属性与光源的三个对应属性类似，每一属性都由四个值组成。AMBIENT表示各种光线照射到该材质上，经过很多次反射后最终遗留在环境中的光线强度（颜色）。DIFFUSE表示光线照射到该材质上，经过漫反射后形成的光线强度（颜色）。SPECULAR表示光线照射到该材质上，经过镜面反射后形成的光线强度（颜色）。通常，AMBIENT和DIFFUSE都取相同的值，可以达到比较真实的效果。
        //        EMISSION属性。该属性由四个值组成，表示一种颜色。OpenGL认为该材质本身就微微的向外发射光线，以至于眼睛感觉到它有这样的颜色，但这光线又比较微弱，以至于不会影响到其它物体的颜色。
        //        SHININESS属性。该属性只有一个值，称为“镜面指数”，取值范围是0到128。该值越小，表示材质越粗糙，点光源发射的光线照射到上面，也可以产生较大的亮点。该值越大，表示材质越类似于镜面，光源照射到上面后，产生较小的亮点。
        sunNode.geometry?.firstMaterial?.multiply.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5 //強度
        sunNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        //  地球图
        
        earthNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/earth-diffuse-mini.jpg"
        //  地球夜光图
        earthNode.geometry?.firstMaterial?.emission.contents = "art.scnassets/earth/earth-emissive-mini.jpg";
        earthNode.geometry?.firstMaterial?.specular.contents = "art.scnassets/earth/earth-specular-mini.jpg";
        
        //    月球圖
        moonNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/moon.jpg";
        
        //3.设置位置
        
        sunNode.position = SCNVector3(x, y, z)
        
        
        earthGroupNode.position = SCNVector3(10,0,0)//地月节点距离太阳的10
        
        earthNode.position = SCNVector3(3, 0, 0)
        
        moonRotationNode.position = earthNode.position //设置月球围绕地球转动的节点位置与地球的位置相同
        
        
        moonNode.position = SCNVector3(3, 0, 0)//月球距离月球围绕地球转动距离3
        
        //4.让rootnode为sun sun上添加earth earth添加moon
        
        //        sunNode.addChildNode(earthNode)
        
        //        earthNode.addChildNode(moonNode)
        
        moonRotationNode.addChildNode(moonNode)
        
        earthGroupNode.addChildNode(earthNode)
        earthGroupNode.addChildNode(moonRotationNode)
        
        
        sunNode.addChildNode(earthGroupNode)
        
        
        self.arSCNView.scene.rootNode.addChildNode(sunNode)
        let swipeUp = UISwipeGestureRecognizer(target:self, action:#selector(swipeUp(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target:self, action:#selector(swipeDown(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        let swipeLeft = UISwipeGestureRecognizer(target:self, action:#selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target:self, action:#selector(swipeRight(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let pinch = TapGestureManager(target:self,action:#selector(pinchDid(_:)))
        pinch.intervalTime = 10
        self.view.addGestureRecognizer(pinch)
    }
    
    @objc func pinchDid(_ recognizer:UIPinchGestureRecognizer) {
        //在监听方法中可以实时获得捏合的比例
        sunNode.position = SCNVector3(CGFloat(x), CGFloat(y), CGFloat(z) * recognizer.scale)
        //        if recognizer.scale > 0 {
        //            z += 1
        //            sunNode.position = SCNVector3(x, y, z * recognizer.scale)
        //        }else{
        //            z -= 1
        //            sunNode.position = SCNVector3(x, y, z)
        //        }
    }
    let offset = 5
    @objc func swipeUp(_ recognizer:UISwipeGestureRecognizer){
        y += offset
        sunNode.position = SCNVector3(x, y, z)
    }
    @objc func swipeDown(_ recognizer:UISwipeGestureRecognizer){
        y -= offset
        sunNode.position = SCNVector3(x, y, z)
    }
    @objc func swipeLeft(_ recognizer:UISwipeGestureRecognizer){
        x -= offset
        sunNode.position = SCNVector3(x, y, z)
    }
    @objc func swipeRight(_ recognizer:UISwipeGestureRecognizer){
        x += offset
        sunNode.position = SCNVector3(x, y, z)
    }
    var scale = CGFloat()
    func setNode(){
        sunNode.position = SCNVector3(CGFloat(x), CGFloat(y), CGFloat(z) * scale)
    }
    
    //MARK：设置太阳自转
    func sunRotation()  {
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 10.0//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        sunNode.addAnimation(animation, forKey: "sun-texture")
        
        
        
    }
    //MARK:设置地球自转和月亮围绕地球转
    /**
     月球如何围绕地球转呢
     可以把月球放到地球上，让地球自转月球就会跟着地球，但是月球的转动周期和地球的自转周期是不一样的，所以创建一个月球围绕地球节点（与地球节点位置相同），让月球放到地月节点上，让这个节点自转，设置转动速度即可
     */
    
    func earthTurn()  {
        //苹果有一套自带的动画
        earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)), forKey: "earth-texture")//duration标识速度 数字越小数字速度越快
        //设置月球自转
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 3//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        moonNode.addAnimation(animation, forKey: "moon-rotation")//月球自转
        
        //设置月球公转
        let moonRotationAnimation = CABasicAnimation(keyPath: "rotation")
        
        moonRotationAnimation.duration = 4//速度
        
        moonRotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        moonRotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        
        
        moonRotationNode.addAnimation(moonRotationAnimation, forKey: "moon rotation around earth")
        
        
    }
    
    
    //MARK：设置地球公转
    func sunTurn()  {
        
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 20//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        earthGroupNode.addAnimation(animation, forKey: "earth rotation around sun")//月球自转
        
    }
    
    //MARK://设置太阳光晕和被光找到的地方
    func addLight() {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.red //被光找到的地方颜色
        
        
        sunNode.addChildNode(lightNode)
        
        lightNode.light?.attenuationEndDistance = 20.0 //光照的亮度随着距离改变
        lightNode.light?.attenuationStartDistance = 1.0
        
        SCNTransaction.begin()
        
        
        SCNTransaction.animationDuration = 1
        
        
        
        lightNode.light?.color =  UIColor.white
        lightNode.opacity = 0.5 // make the halo stronger
        
        SCNTransaction.commit()
        
        sunHaloNode.geometry = SCNPlane.init(width: 25, height: 25)
        
        sunHaloNode.rotation = SCNVector4Make(1, 0, 0, Float(0 * Double.pi / 180.0))
        sunHaloNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        sunHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant // no lighting
        sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false // 不要有厚度，看起来薄薄的一层
        sunHaloNode.opacity = 5
        
        sunHaloNode.addChildNode(sunHaloNode)
    }
    
    
}
class TapGestureManager:UIPinchGestureRecognizer,UIGestureRecognizerDelegate {
    //想间隔的时长
    var intervalTime: TimeInterval?
    //用于完成间隔的计时器
    private var eventTimer: Timer?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }
    // 是否响应触摸手势的代理方法
    func gestureRecognizer(gestureRecognizer: UIPinchGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (eventTimer != nil) {
            return false
        }
        
        eventTimer = Timer(timeInterval: intervalTime ?? 0, target: self, selector: #selector(deinitTimer), userInfo: nil, repeats: false)
        RunLoop.current.add(eventTimer!, forMode: RunLoopMode.commonModes)
        
        return true
    }
    
    @objc func deinitTimer() {
        eventTimer?.invalidate()
        eventTimer = nil
    }
}
