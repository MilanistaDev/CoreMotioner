//
//  AvtivityInterfaceController.swift
//  CoreMotioner
//
//  Created by 麻生 拓弥 on 2017/01/19.
//  Copyright © 2017年 麻生 拓弥. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class AvtivityInterfaceController: WKInterfaceController {

    @IBOutlet var confidenceLabel: WKInterfaceLabel!
    @IBOutlet var mainActivityImage: WKInterfaceImage!
    @IBOutlet var subActivityImage: WKInterfaceImage!

    let activityManager = CMMotionActivityManager()

    // CMMotionActivity(ユーザの動作状態)
    var confidence = ""
    var stationary: Bool = false
    var walking: Bool = false
    var running: Bool = false
    var automotive: Bool = false
    var cycling: Bool = false

    // MARK:- Life cycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // アクティビティ取得不可なら
        if !CMMotionActivityManager.isActivityAvailable() {
            self.confidenceLabel.setText("Not supported")
            self.mainActivityImage.setImageNamed("notSupported")
        }
    }

    // Apple Watch は iOS デバイスとライフサイクルが異なる
    // 画面が消えるとdidDeactivateが呼ばれるので停止してしまう
    // 画面がつくとwillActiveが呼ばれるのでここで取得開始する
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        // アクティビティ取得可能だったら取得する
        if CMMotionActivityManager.isActivityAvailable() {
            self.displayActivityData()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        // 停止処理
        self.activityManager.stopActivityUpdates()
    }

    // MARK:- Private method
    /**
      アクティビティデータを取得し表示する
    */
    func displayActivityData() {
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
                self.confidenceLabel.setText(self.confidence)

                // 静止・歩行・走行が複数trueにはならないと思われ・・・
                if self.stationary {
                    self.mainActivityImage.setImageNamed("stationary")
                } else if self.walking {
                    self.mainActivityImage.setImageNamed("walking")
                } else if self.running {
                    self.mainActivityImage.setImageNamed("running")
                }
                                                        
                // 交通機関で移動・自転車で移動も同時にtrueとはならないと思われ・・・
                if self.automotive {
                    self.subActivityImage.setImageNamed("automotive")
                } else if self.cycling {
                    self.subActivityImage.setImageNamed("cycling")
                }
            })
        })
    }
}
