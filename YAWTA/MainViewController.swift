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
    
    @IBOutlet weak var totalWaterLabel: UIButton!
    @IBOutlet weak var appleHealthButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    
    var userConfig: UserConfig? {
        didSet {
            ModelController.shared.saveUserData(self.userConfig!)
            if self.userConfig!.notificationIsOn && totalWaterAmount < 2 {
                nc.beginNotifications()
            } else {
                nc.removeNotifications()
            }
        }
    }
    
    var totalWaterAmount: Double = 0.0 {
        didSet {
            totalWaterLabel.setTitle("\(self.totalWaterAmount)", for: .normal)
            updateBackground()
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
        
        let savedUserConfig = ModelController.shared.loadUserData()
        
        if let savedConfig = savedUserConfig {
            userConfig = savedConfig
            updateUI()
        } else {
            nc.requestAuthorization()
            ah.checkAvailability()
            userConfig = UserConfig(currentWaterIntake: 0.0, notificationIsOn: true, date: Date.dayToday())
            updateUI()
        }
        
        
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
        if let date = userConfig?.date {
            if Date.dayToday() != date {
                var savedUserConfig = ModelController.shared.loadUserData()
                savedUserConfig!.currentWaterIntake = 0.0
                savedUserConfig!.date = Date.dayToday()
                ModelController.shared.saveUserData(savedUserConfig!)
                userConfig = savedUserConfig
                print("startNewDay fired!")
                updateUI()
            }
        }
    }
    
    func updateUI() {
        guard let config = userConfig else { return }
        print("UPDATE UI FIRED WITH: \(config)")
        DispatchQueue.main.async {
            self.totalWaterAmount = config.currentWaterIntake
            self.notificationButton.isSelected = config.notificationIsOn
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
        print(location)
        let percent = Int(100.0 * location) / 2
        self.wave.completionInPercent = percent
    }
    
    func addWater(amount: Double) {
        totalWaterAmount += amount

        if ah.authorizationStatus() {
            ah.save(amount)
            print("Healthkit saved")
        }
        userConfig?.currentWaterIntake = self.totalWaterAmount
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
            userConfig?.notificationIsOn = sender.isSelected
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
