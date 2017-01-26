//
//  InterfaceController.swift
//  CoreMotionerforWatch Extension
//
//  Created by 麻生 拓弥 on 2017/01/19.
//  Copyright © 2017年 麻生 拓弥. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    @IBOutlet var eventTypeImageView: WKInterfaceImage!
    @IBOutlet var stepCountsLabel: WKInterfaceLabel!
    
    let pedometer: CMPedometer = CMPedometer()

    // CMPedometerData(歩数・距離)
    var numberOfSteps: NSNumber = 0
    // CMPedometerEvent(歩行の一時停止・再開)
    var pedometerEventType = ""

    // MARK:- Life cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // 歩数・EventType取得不可の場合
        if !CMPedometer.isStepCountingAvailable() {
            self.stepCountsLabel.setText("-")
        }
        if !CMPedometer.isPedometerEventTrackingAvailable() {
            self.eventTypeImageView.setImageNamed("notSupported")
        }
    }

    // Apple Watch は iOS デバイスとライフサイクルが異なる
    // 画面が消えるとdidDeactivateが呼ばれるので停止してしまう
    // 画面がつくとwillActiveが呼ばれるのでここで取得開始する
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        // 歩数・EventType取得可能の場合取得メソッド呼ぶ
        if CMPedometer.isStepCountingAvailable() {
            self.acquirePedometerData()
        }
        if CMPedometer.isPedometerEventTrackingAvailable() {
            self.displayEventType()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()

        // 終了処理
        self.pedometer.stopUpdates()
        self.pedometer.stopEventUpdates()
    }

    // MARK:- Private method
    /**
      今日歩いた歩数を取得し表示する
    */
    func acquirePedometerData() {

        let now = Date()    // 現在時間
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let today = calendar.date(from: components) // 今日の0時

        self.pedometer.startUpdates(from: today!, withHandler: {
            (data: CMPedometerData?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exData = data, error == nil else {
                    return
                }
                // 歩数取得
                self.numberOfSteps = exData.numberOfSteps
                self.stepCountsLabel.setText(self.numberOfSteps.description)
            })
        })
    }

    /**
      現在のEventTypeを取得し表示する
      .pause: 一時停止，.resume: 再開
    */
    func displayEventType() {

        self.pedometer.startEventUpdates(handler: {
            (event: CMPedometerEvent?, error: Error?) in
            DispatchQueue.main.async(execute: { () in
                guard let exEvent = event, error == nil else {
                    return
                }
                switch exEvent.type {
                case .pause:
                    self.pedometerEventType = "PAUSE"
                    self.eventTypeImageView.setImageNamed("paused")
                case .resume:
                    self.pedometerEventType = "RESUME"
                    self.eventTypeImageView.setImageNamed("resume")
                }
            })
        })
    }
}
