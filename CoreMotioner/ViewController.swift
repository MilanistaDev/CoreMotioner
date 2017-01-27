//
//  ViewController.swift
//  CoreMotioner
//
//  Created by 麻生 拓弥 on 2017/01/11.
//  Copyright © 2017年 麻生 拓弥. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    // MARK:- Property

    @IBOutlet weak var acc_xLabel: UILabel!
    @IBOutlet weak var acc_yLabel: UILabel!
    @IBOutlet weak var acc_zLabel: UILabel!
    
    @IBOutlet weak var gyro_xLabel: UILabel!
    @IBOutlet weak var gyro_yLabel: UILabel!
    @IBOutlet weak var gyro_zLabel: UILabel!
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var stationaryLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var automotiveLabel: UILabel!
    @IBOutlet weak var cyclingLabel: UILabel!
    
    @IBOutlet weak var numberOfStepsLabel: UILabel!
    @IBOutlet weak var weeklyStepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var weeklyDistanceLabel: UILabel!
    @IBOutlet weak var averageActivePaceLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var currentCadenceLabel: UILabel!
    @IBOutlet weak var floorAscendedLabel: UILabel!
    @IBOutlet weak var floorDescendedLabel: UILabel!
    @IBOutlet weak var pedometerEventTypeLabel: UILabel!
    
    @IBOutlet weak var relativeAttitudeLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!

    // インスタンス生成
    let motionManager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let altimeter = CMAltimeter()
    
    // CMAccelerometerData(加速度)
    var acc_x: Double = 0.0
    var acc_y: Double = 0.0
    var acc_z: Double = 0.0
    
    // CMGyroData(ジャイロ)
    var gyro_x: Double = 0.0
    var gyro_y: Double = 0.0
    var gyro_z: Double = 0.0
    
    // CMMotionActivity(ユーザの動作状態)
    var confidence = ""
    var stationary: Bool = false
    var walking: Bool = false
    var running: Bool = false
    var automotive: Bool = false
    var cycling: Bool = false
    
    // CMPedometerData(歩数・距離)
    var numberOfSteps: NSNumber = 0
    var weeklyStepCount: NSNumber = 0
    var moveDistance: NSNumber = 0
    var weeklyDistance: NSNumber = 0
    var averageActivePace: NSNumber = 0
    var currentPace: NSNumber = 0
    var currentCadence: NSNumber = 0
    var floorAscended: NSNumber = 0
    var floorDescended: NSNumber = 0
    
    // CMPedometerEvent(歩行の一時停止・再開)
    var pedometerEventType = ""
    
    // CMAltitudeData(相対高度・気圧)
    var relativeAltitude: NSNumber = 0
    var pressure: NSNumber = 0
    
    // CMDeviceMotion・CMAttitude・CMlogItem・CMSensorRecorder(現状加速度だけ？) は扱わない

    // MARK:- Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI周りの初期設定
        self.setUp()

        // データ取得
        self.getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // バックグラウンドで動作させる場合は適切な場所でstopする
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.stopGyroUpdates()
        self.activityManager.stopActivityUpdates()
        self.pedometer.stopUpdates()
        self.pedometer.stopEventUpdates()
        self.altimeter.stopRelativeAltitudeUpdates()
    }

    // MARK:- First Settings

    func setUp() {
        
        self.navigationItem.title = "CoreMotion Test"
        self.navigationController?.navigationBar.barTintColor = UIColor().ginzaLineColor()
    }

    // MARK:- Get Data

    func getData() {
    
        // 加速度データ取得
        if (self.motionManager.isAccelerometerAvailable) {
            self.acquireAcceleration()
        } else {
            self.acc_xLabel.text = "Not supported"
            self.acc_yLabel.text = "Not supported"
            self.acc_zLabel.text = "Not supported"
        }
        
        // ジャイロデータ取得
        if (self.motionManager.isGyroAvailable) {
            self.acquireGyro()
        } else {
            self.gyro_xLabel.text = "Not supported"
            self.gyro_yLabel.text = "Not supported"
            self.gyro_zLabel.text = "Not supported"
        }
        
        // 動作状態，信頼度取得
        if (CMMotionActivityManager.isActivityAvailable()){
            self.acquireMotionActuvity()
        } else {
            self.confidenceLabel.text = "Not supported"
            self.stationaryLabel.text = "Not supported"
            self.walkingLabel.text = "Not supported"
            self.runningLabel.text = "Not supported"
            self.automotiveLabel.text = "Not supported"
            self.cyclingLabel.text = "Not supported"
        }

        // CMPedometerData取得(今日の歩数・歩行距離・階段上り下り数)
        // 歩数取得可能か
        if (!CMPedometer.isStepCountingAvailable()) {
            self.numberOfStepsLabel.text = "Not supported"
        }
        // 距離取得可能か
        if (!CMPedometer.isDistanceAvailable()) {
            self.distanceLabel.text = "Not supported"
        }
        // 3mくらいフロアの上り下り数取得可能か
        // エレベータは含まないらしい
        if (!CMPedometer.isFloorCountingAvailable()) {
            self.floorAscendedLabel.text = "Not supported"
            self.floorDescendedLabel.text = "Not supported"
        }
        // ペース取得可能か
        if (!CMPedometer.isPaceAvailable()) {
            self.averageActivePaceLabel.text = "Not supported"
            self.currentPaceLabel.text = "Not supported"
        }
        // カデンツ取得可能か
        if (!CMPedometer.isCadenceAvailable()) {
            self.currentCadenceLabel.text = "Not supported"
        }
        // 一応呼ぶ；使えない場合は guard 文で return される
        self.aquireDailyPedometerData()

        // CMPedometerData取得(1週間分の歩数・歩行距離)
        // 現在から1週間分の歩数取得可能か
        if (!CMPedometer.isStepCountingAvailable()) {
            self.weeklyStepsLabel.text = "Not supported"
        }
        // 現在から1週間分の距離取得可能か
        if (!CMPedometer.isDistanceAvailable()) {
            self.weeklyDistanceLabel.text = "Not supported"
        }
        self.acquireWeeklyPedometerData()

        // CMPedometerEventType
        // 歩行停止再開情報取得
        if (CMPedometer.isPedometerEventTrackingAvailable()) {
            self.acquirePedometerEventType()
        } else {
            self.pedometerEventTypeLabel.text = "Not supported"
        }

        // 高度・気圧取得
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            self.acquireAltimeter()
        } else {
            self.relativeAttitudeLabel.text = "Not supported"
            self.pressureLabel.text = "Not supported"
        }
    }
    
    /**
      加速度取得
    */
    func acquireAcceleration() {
        
        self.motionManager.accelerometerUpdateInterval = 1/10
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!,
                                            withHandler: {
            (data: CMAccelerometerData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    // Alert 表示
                    return
                }
                self.acc_x = exData.acceleration.x
                self.acc_y = exData.acceleration.y
                self.acc_z = exData.acceleration.z
                self.acc_xLabel.text = self.acc_x.description
                self.acc_yLabel.text = self.acc_y.description
                self.acc_zLabel.text = self.acc_z.description
            })
        })
    }
    
    /**
      ジャイロデータ取得
    */
    func acquireGyro() {
        self.motionManager.gyroUpdateInterval = 1/10
        self.motionManager.startGyroUpdates(to: OperationQueue.current!,
                                   withHandler: {
            (data: CMGyroData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    return
                }
                self.gyro_x = exData.rotationRate.x
                self.gyro_y = exData.rotationRate.y
                self.gyro_z = exData.rotationRate.z
                self.gyro_xLabel.text = self.gyro_x.description
                self.gyro_yLabel.text = self.gyro_y.description
                self.gyro_zLabel.text = self.gyro_z.description
            })
        })
    }
    
    /**
      ユーザの状態検出
    */
    func acquireMotionActuvity() {
        
        self.activityManager.startActivityUpdates(to: OperationQueue.current!,
                                         withHandler: {(data: CMMotionActivity?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data else {
                    return
                }
                // ユーザの状態(Bool)
                self.stationary = exData.stationary
                self.walking = exData.walking
                self.running = exData.running
                self.automotive = exData.automotive
                self.cycling = exData.cycling
                
                // confidence は CMMotionActivityConfidence 型
                // ユーザの状態の信頼度(精度)
                switch exData.confidence {
                case .low:
                    self.confidence = "Low"
                case .medium:
                    self.confidence = "Medium"
                case .high:
                    self.confidence = "High"
                }
                self.confidenceLabel.text = self.confidence
                self.stationaryLabel.text = self.stationary ? "YES" : "NO"
                self.walkingLabel.text = self.walking ? "YES" : "NO"
                self.runningLabel.text = self.running ? "YES" : "NO"
                self.automotiveLabel.text = self.automotive ? "YES" : "NO"
                self.cyclingLabel.text = self.cycling ? "YES" : "NO"
            })
        })
    }

    /**
      Pedometer 今日のデータ
    */
    func aquireDailyPedometerData() {

        let now = Date()    // 現在時間
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let today = calendar.date(from: components) // 今日の0時時点

        self.pedometer.startUpdates(from: today!, withHandler: {
            (data: CMPedometerData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    return
                }
                // 歩数取得
                self.numberOfSteps = exData.numberOfSteps
                self.numberOfStepsLabel.text = self.numberOfSteps.description

                // 距離取得
                if let distance = exData.distance {
                    self.moveDistance = distance
                    self.distanceLabel.text = NSString(format: "%.2f[km]", Double(self.moveDistance)/1000) as String
                }

                // 3mくらいフロアの上り下り数取得
                if let upFloor = exData.floorsAscended {
                    self.floorAscended = upFloor
                    self.floorAscendedLabel.text = self.floorAscended.description
                }
                if let downFloor = exData.floorsDescended {
                    self.floorDescended = downFloor
                    self.floorDescendedLabel.text = self.floorDescended.description
                }

                // ペース取得
                // 平均の活動ペース[second/meter](適切なタイミングから(Date()など)の方がいい)
                if let avgPave = exData.averageActivePace {
                    self.averageActivePace = avgPave
                    self.averageActivePaceLabel.text = NSString(format: "%.2f[s/m]", Double(self.averageActivePace)) as String
                }
                // 現在の活動ペース[second/meter]
                if let curPace = exData.currentPace {
                    self.currentPace = curPace
                    self.currentPaceLabel.text = NSString(format: "%.2f[s/m]", Double(self.currentPace)) as String
                }

                // カデンツ取得
                // 現在のリズム・抑揚[steps/s]
                if let cadence = exData.currentCadence {
                    self.currentCadence = cadence
                    self.currentCadenceLabel.text = NSString(format: "%.2f[steps/s]", Double(self.currentCadence)) as String
                }
            })
        })
    }

    /**
      1週間分の歩数・歩行距離
    */
    func acquireWeeklyPedometerData() {

        let now = Date()
        let date = Date(timeInterval: -60*60*24*7, since: now)
        self.pedometer.queryPedometerData(from: date, to: now, withHandler: {
            (data: CMPedometerData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    return
                }
                // 現在から1週間分の歩数取得
                self.weeklyStepCount = exData.numberOfSteps
                self.weeklyStepsLabel.text = self.weeklyStepCount.description

                // 現在から1週間分の距離取得
                if let wDistance = exData.distance {
                    self.weeklyDistance = wDistance
                    self.weeklyDistanceLabel.text = NSString(format: "%.2f[km]", Double(self.weeklyDistance)/1000) as String
                }
            })
        })
    }

    /**
      歩行のイベントタイプを取得
      .pause: 一時停止，.resume: 再開
    */
    func acquirePedometerEventType() {
        
        self.pedometer.startEventUpdates(handler: {
            (event: CMPedometerEvent?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exEvent = event, error == nil else {
                    return
                }
                switch exEvent.type {
                case .pause:
                    self.pedometerEventType = "PAUSE"
                case .resume:
                    self.pedometerEventType = "RESUME"
                }
                self.pedometerEventTypeLabel.text = self.pedometerEventType
            })
        })
    }

    /**
      相対高度・気圧
      起動したところからXX[m]
      気圧は取得データは[kPa]なので10倍して[hPa]に
    */
    func acquireAltimeter() {
        
        self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: {
            (data: CMAltitudeData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    return
                }
                self.relativeAltitude = exData.relativeAltitude
                self.pressure = exData.pressure
                self.relativeAttitudeLabel.text = NSString(format: "%.2f[m]", Double(self.relativeAltitude)) as String
                self.pressureLabel.text = NSString(format: "%.2f[hPa]", Double(self.pressure)*10) as String
            })
        })
    }

    // MARK:- Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIColor {
    func ginzaLineColor() -> UIColor {
        return UIColor(red: 243.0/255.0, green: 151.0/255.0, blue: 0.0, alpha: 1.0)
    }
}
