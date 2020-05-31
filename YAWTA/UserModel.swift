//
//  ModelController.swift
//  YAWTA
//
//  Created by MAC on 25/04/2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import Foundation

struct UserModel {
    
    static let shared = UserModel()
    
    private var user = User(currentWaterIntake: 0, notificationIsOn: true, date: Date.dayToday())
    
    mutating func addWater(_ amount: Double) {
        user.currentWaterIntake += amount
        save()
    }
    
    mutating func setNotification(_ isOn: Bool) {
        user.notificationIsOn = isOn
        save()
    }
    
    func getWaterStatus() -> Double {
        return user.currentWaterIntake
    }
    
    func getNotificationStatus() -> Bool {
        return user.notificationIsOn
    }
    
    func getDate() -> Int {
        return user.date
    }
    
    mutating func refreshTotal() {
        user.currentWaterIntake = 0.0
        user.date = Date.dayToday()
    }
    
    func save() {
        let encoder = JSONEncoder()
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userConfigFileURL = documentDirectoryURL.appendingPathComponent("user").appendingPathExtension("json")
        
        if let data = try? encoder.encode(user) {
            try? data.write(to: userConfigFileURL)
        }
    }
    
    init(testing: Bool = false) {
        if !testing {
            let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userConfigFileURL = documentDirectoryURL.appendingPathComponent("user").appendingPathExtension("json")
            
            if let data = try? Data(contentsOf: userConfigFileURL) {
                let decoder = JSONDecoder()
                user = try! decoder.decode(User.self, from: data)
            }
        }
    }
}
