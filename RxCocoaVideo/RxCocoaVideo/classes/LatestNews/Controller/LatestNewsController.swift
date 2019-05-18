//
//  LatestNewsViewController.swift
//  RxSwiftTableViewVideo
//
//  Created by 胡涛 on 2018/7/11.
//  Copyright © 2018年 胡涛. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

var iconStr:String = ""
var temperature:String = ""
var redOrWhite: String = "white"
class LatestNewsController: HomeTableViewController {
   

    var maxCursor = 0
    var dongtais = [UserDetailDongtai]()
    var weatherInfo = WeatherModel(){
        didSet{
            navigationBar.weatherModel = weatherInfo
        }
    }
    
    var locationManager: CLLocationManager = CLLocationManager()
    let disposeBag = DisposeBag()
    override func viewWillAppear(_ animated: Bool) {
         StatusBarBGC.setStatusBarBackgroundColor(color: UIColor.white)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置 UI
        setupUI()
        // 设置刷新控件
        setupRefresh()
        clickAction()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
            DispatchQueue.global().async {
                self.loadLocationInfo()
            }
        }
        
        
        
    }
    /// 懒加载 导航栏
    private lazy var navigationBar = WeatherNavigationBar.loadViewFromNib()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension LatestNewsController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let aNews = news[indexPath.row]
        return aNews.weitoutiaoHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    //跳转到动态详情
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aNews = news[indexPath.row]
        
        let userId = aNews.user_info.user_id
        let value = aNews.share_url
        let id = getIntFromString(str: value)
        self.setupFooter(id,userId, value: value, completionHandler: {
            self.dongtais = $0
//            for dongtai in self.dongtais {
//                if($1 == self.getIntFromString(str: dongtai.id_str)){
//                    let dongtaiDetailVC = DongtaiDetailViewController()
//                    dongtaiDetailVC.dongtai = dongtai
//                    self.navigationController?.pushViewController(dongtaiDetailVC, animated: true)
//                }
//            }
            if self.dongtais.count > 0 {
                let dongtaiDetailVC = DongtaiDetailViewController()
                dongtaiDetailVC.dongtai = self.dongtais.first!
                self.navigationController?.pushViewController(dongtaiDetailVC, animated: true)
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.ym_dequeueReusableCell(indexPath: indexPath) as LatestNewsCellTableViewCell
        cell.aNews = news[indexPath.row]
        //跳转到用户详情
        cell.coverButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                let userDetailVC = UserDetailViewController()
                userDetailVC.userId = cell.aNews.user_info.user_id
                redOrWhite = "white"
                self?.navigationController?.pushViewController(userDetailVC, animated: true)
            })
            .disposed(by: cell.disposeBag)
        // 展示大图
        cell.didSelectCell = { [weak self] (selectedIndex) in
            let previewBigImageVC = PreviewVCViewController()
            previewBigImageVC.images = cell.aNews.image_list
            previewBigImageVC.selectedIndex = selectedIndex
            self!.present(previewBigImageVC, animated: false, completion: nil)
        }
        return cell
    }
    private func setupFooter(_ id: Int,_ userId: Int, value: String ,completionHandler:@escaping ((_ datas: [UserDetailDongtai])->())) {
        NetworkTool.loadUserDetailDongtai(id: id,userId: userId, maxCursor: self.maxCursor, completionHandler: {
            if $1.count == 0 {
                return
            }
            completionHandler($1)
        })
        
    }
    func getIntFromString(str:String) -> Int {
        let scanner = Scanner(string: str)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number :Int = 0
        
        scanner.scanInt(&number)
        
        return number
        
    }
}

extension LatestNewsController {
    /// 设置 UI
    private func setupUI() {
        // 判断是否是夜间
      
//       UIApplication.shared.statusBarStyle = .default
//        StatusBarBGC.setStatusBarBackgroundColor(color: UIColor(white: 1, alpha: 1))
//        UIApplication.shared.statusBarStyle = .default
        MyThemeStyle.setupNavigationBarStyle(self, UserDefaults.standard.bool(forKey: isNight))
        // 添加 导航栏左右侧按钮
//        navigationItem.titleView = navigationBar
        // 添加通知
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveDayOrNightButtonClicked), name: NSNotification.Name(rawValue: "dayOrNightButtonClicked"), object: nil)
        tableView.ym_registerCell(cell: LatestNewsCellTableViewCell.self)
        navigationItem.titleView = navigationBar
//        tableView.register(UINib(nibName: "WeitoutiaoCell", bundle: nil), forCellReuseIdentifier: "WeitoutiaoCell")
    }
    private func clickAction() {
        // 搜索按钮点击
       
        // 头像按钮点击
                navigationBar.didSelectAvatarButton = {
//                    let storyboard = UIStoryboard(name: String(describing: MoreLoginViewController.self), bundle: nil)
//                    let moreLoginVC = storyboard.instantiateViewController(withIdentifier: String(describing: MoreLoginViewController.self)) as! MoreLoginViewController
//                    moreLoginVC.modalSize = (width: .full, height: .custom(size: Float(screenHeight - (isIPhoneX ? 44 : 20))))
//                    UIApplication.shared.keyWindow?.rootViewController?.present(moreLoginVC, animated: true, completion: nil)
                    let storyboard = UIStoryboard(name: String(describing: MoreLoginViewController.self), bundle: nil)
                    let moreLVC = storyboard.instantiateViewController(withIdentifier: String(describing: MoreLoginViewController.self)) as! MoreLoginViewController
                    moreLVC.modalSize = (width: .full, height: .custom(size: Float(screenHeight - (isIPhoneX ? 44 : 20))))
                    UIApplication.shared.keyWindow?.rootViewController?.present(moreLVC,animated: true,completion: nil)
                    
                }
      
        
    }
    /// 接收到了按钮点击的通知
    @objc func receiveDayOrNightButtonClicked(notification: Notification) {
        let selected = notification.object as! Bool
        // 判断是否是夜间
        MyThemeStyle.setupNavigationBarStyle(self, UserDefaults.standard.bool(forKey: isNight))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: selected ? "follow_title_profile_night_18x18_" : "follow_title_profile_18x18_"), style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
    }
    /// 导航栏左侧按钮点击
    @objc private func leftBarButtonItemClicked() {
        
    }
    /// 导航栏右侧按钮点击
    @objc private func rightBarButtonItemClicked() {
        
    }
    
}
extension LatestNewsController: CLLocationManagerDelegate {
    
    
    func loadLocationInfo() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        
        
        // let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        //  self.view.addGestureRecognizer(singleFingerTap)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations[locations.count-1] as CLLocation
        if(location.horizontalAccuracy > 0){
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            updateWeatherInfo(latitude: latitude, longitude: longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error",error)
    }
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        NetworkTool.updateWeatherInfo(latitude: latitude, longitude: longitude, completionHandler: {
            if let result = $0 as? NSDictionary {
                self.updateUISuccess(jsonResult: result )
            }
            
        })
    }
    func updateUISuccess(jsonResult: NSDictionary!){
        
        if let tempResult = (jsonResult["main"] as! NSDictionary)["temp"]! as? Double{
            var temprature: Double
            
            temprature = round(tempResult - 273.15)
            //            asdas.text = jsonResult["name"] as? String
            //            tempra.text = "\(temprature)degrees"
            let condition = ((jsonResult["weather"] as! NSArray)[0] as! NSDictionary)["id"] as? Int
            let sunrise = (jsonResult["sys"] as! NSDictionary)["sunrise"] as? Double
            let sunset = (jsonResult["sys"] as! NSDictionary)["sunset"] as? Double
            let cityName = (jsonResult["name"] as? String)!
            switch cityName{
            case "Zaoyang" :
                weatherInfo.cityName = "枣阳"
                break
            case "Beijing" :
                weatherInfo.cityName = "北京"
                break
            case "Shanghai" :
                weatherInfo.cityName = "上海"
                break
            case "Shenzhen" :
                weatherInfo.cityName = "深圳"
                break
            case "Hangzhou" :
                weatherInfo.cityName = "杭州"
                break
            default:
                weatherInfo.cityName = cityName
            }
            temperature = "\(Int(temprature))℃"
            weatherInfo.temprature = temperature
            var nightTime = false
            let now = NSDate().timeIntervalSince1970
            
            if (now < sunrise! || now > sunset!) {
                nightTime = true
            }
            self.updateWeatherIcon(condition: condition!, nightTime: nightTime)
           
            weatherInfo.iconStr = iconStr
        }else{
        }
        
    }
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        //        self.iconStr= UIImage(named: "tstorm1")
        //        switch condition {
        //        case 800...:
        //            if (nightTime){
        //                self.iconStr= UIImage(named: "sunny_night") // sunny night?
        //            }
        //            else {
        //                self.iconStr= UIImage(named: "sunny")
        //            }
        //        default:
        //            if (nightTime){
        //                self.iconStr= UIImage(named: "tstorm1_night") // sunny night?
        //            }
        //            else {
        //                self.iconStr= UIImage(named: "tstorm1")
        //            }
        //        }
        // Thunderstorm
        
       if (condition < 600) {
           iconStr = "rain"
        }
            // Snow
        else if (condition < 700) {
            iconStr = "snowy"
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                iconStr = "cloudy"
            } else {
                iconStr = "cloudy"
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            iconStr = "thunder"
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                iconStr = "sunny" // sunny night?
            }
            else {
                iconStr = "sunny"
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                iconStr = "cloudy"
            }
            else{
                iconStr = "cloudy"
            }
        }
            // overcast clouds
        else if (condition == 804) {
            iconStr = "cloudy"
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            iconStr = "thunder"
        }
            // Cold
        else if (condition == 903) {
            iconStr = "snowy"
        }
            // Hot
        else if (condition == 904) {
            iconStr = "sunny"
        }
        else {
            // Weather condition not available
            iconStr = "dunno"
        }
    }
}
