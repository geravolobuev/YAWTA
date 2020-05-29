//
//  NotificationController.swift
//  YAWTA
//
//  Created by MAC on 28/04/2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationController {
    
    let center =  UNUserNotificationCenter.current()
    static let shared = NotificationCenter()
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications authorized")

            } else if let error = error {
                print(error.localizedDescription)

            }
        }
    }

    
    func beginNotifications() {
        
        center.removeAllPendingNotificationRequests()
        
        for hour in 9...21
            
        {
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.minute = 0
            dateComponents.hour = hour
            
            let content = UNMutableNotificationContent()
            content.title = "WATER!"
            content.subtitle = "Drink some water dude!"
            content.sound = UNNotificationSound.default
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "id: " + String(hour) + UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            
        }
        print("Notification scheduled")
    }
    
    
    func removeNotifications() {
        center.removeAllPendingNotificationRequests()
        print("Notificaiton is stopped")
    }
}
