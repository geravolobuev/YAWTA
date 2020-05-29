//
//  AppleHealthController.swift
//  YAWTA
//
//  Created by MAC on 08.05.2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import Foundation
import HealthKit

class AppleHealthController {
    
    let healthStore = HKHealthStore()
    
    func checkAvailability() {
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            
            let types = Set([HKObjectType.quantityType(forIdentifier: .dietaryWater)!])
            
            healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("AH is not available")
                }
            }
        }
    }
    
    func authorizationStatus() -> Bool {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
            fatalError("*** Unable to create a heart rate quantity type ***")
        }

        let authorizationStatus = healthStore.authorizationStatus(for: quantityType)

        switch authorizationStatus {
        case .sharingAuthorized:
            print("AH sharing authorized")
            return true
        default:
            print("AH not determined or authorized")
            return false
        }   
    }
    
    
    func save(_ amount: Double) {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
            fatalError("*** Unable to create a heart rate quantity type ***")
        }
        
        let water = HKUnit.liter()
        let quantity = HKQuantity(unit: water, doubleValue: amount)
        
        let quantitySample = HKQuantitySample(type: quantityType,
                                              quantity: quantity,
                                              start: Date(),
                                              end: Date())
        healthStore.save(quantitySample) { success, error in
            if success {
                print("\(amount) was passed to AH")
            } else {
                print(error)
            }
        }
    }
    
}

