//
//  MainViewController.swift
//  YAWTA
//
//  Created by MAC on 25/04/2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UIViewController {
    
    let nc = NotificationController()
    let ah = AppleHealthController()
    
    var notificationsAllowed: Bool!
    var notificationScheduled: Bool! {
        didSet {
            if self.notificationScheduled {
                nc.beginNotifications()
            } else {
                nc.removeNotifications()
            }
        }
    }
    
    @IBOutlet weak var totalWaterLabel: UIButton!
    @IBOutlet weak var appleHealthButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    
    var model = UserModel()
    
    var totalWaterAmount: Double = 0.0 {
        didSet {
            totalWaterLabel.setTitle("\(self.totalWaterAmount)", for: .normal)
            updateBackground()
            if totalWaterAmount > 2 {
                notificationScheduled = false
            }
        }
    }
    
    var wave = SPWaterProgressIndicatorView.init(frame: .zero)
    var isAnimating: Bool = false {
        didSet{
            if isAnimating {
                self.wave.startAnimation()
            } else {
                self.wave.stopAnimation()
            }
        }
    }
    
    // MARK: VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#E0F8FF")
        
        // Water animation
        self.wave = SPWaterProgressIndicatorView(frame: self.view.bounds)
        self.wave.center = self.view.center
        self.view.addSubview(self.wave)
        self.view.sendSubviewToBack(wave)
        
        // Reduce total water amount to zero every new day
        NotificationCenter.default.addObserver(self, selector: #selector(isDayChanged), name: Notification.Name.isDayChangedNotification, object: nil)
        
        // Check if notification settings changed
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Resume animation
        NotificationCenter.default.addObserver(self, selector: #selector(appleHealthButtonAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        nc.requestAuthorization()
        ah.checkAvailability()
        updateUI()
    }
    
    @objc private func checkNotificationStatus() {
        nc.center.getNotificationSettings{ (settings) in
            if (settings.authorizationStatus == .authorized) {
                print("N authorized")
                self.notificationsAllowed = true
            } else {
                print("N not authorized")
                self.notificationsAllowed = false
            }
        }
    }
    
    @objc func isDayChanged() {
        let date = model.getDate()
        
        if  Date.dayToday() != date {
            self.model.refreshTotal()
            print("startNewDay fired!")
            notificationScheduled = model.getNotificationStatus()
            updateUI()
            
        }
    }
    
    func updateUI() {
        print("UPDATE UI FIRED WITH: \(model)")
        DispatchQueue.main.async {
            self.totalWaterAmount = self.model.getWaterStatus()
            self.notificationButton.isSelected = self.model.getNotificationStatus()
            self.appleHealthButton.isSelected = self.ah.authorizationStatus()
        }
    }
    
    @IBAction func button1L(_ sender: UIButton) {
        addWater(amount: 1.0)
    }
    
    @IBAction func button500ml(_ sender: UIButton) {
        addWater(amount: 0.5)
    }
    
    @IBAction func button250ml(_ sender: UIButton) {
        addWater(amount: 0.25)
    }
    
    func updateBackground() {
        let location = CGFloat(totalWaterAmount)
        let percent = Int(100.0 * location) / 2
        self.wave.completionInPercent = percent
    }
    
    func addWater(amount: Double) {
        totalWaterAmount += amount
        model.addWater(amount)

        if ah.authorizationStatus() {
            ah.save(amount)
            print("Healthkit saved")
        }
    }
    
    @objc func appleHealthButtonAnimation() {
        if ah.authorizationStatus() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1
            animation.toValue = 0.6
            animation.duration = 0.7
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            appleHealthButton.layer.add(animation, forKey: "pulsating")
        }
    }
    
    @IBAction func appleHealthButtonTapped(_ sender: UIButton) {
        sender.isSelected = ah.authorizationStatus()
        if ah.authorizationStatus() {
            sender.isUserInteractionEnabled = false
        } else {
            sender.isUserInteractionEnabled = true
            fireAlert(message: "Enable Apple Health sync please") {
                // Move to health app
                guard let url = URL(string: "x-apple-health://") else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        if notificationsAllowed {
            sender.isSelected.toggle()
            model.setNotification(sender.isSelected)
            notificationScheduled = sender.isSelected
        } else {
            fireAlert(message: "You should allow notifications first") {
                // Move to settings app
                if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        }
        
    }
    
    func fireAlert(message: String, handler: @escaping ()->Void) {
        let ac = UIAlertController(title: "Opps", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) in
            handler()}))
        present(ac, animated: true)
    }
}
