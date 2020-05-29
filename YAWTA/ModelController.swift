//
//  ModelController.swift
//  YAWTA
//
//  Created by MAC on 25/04/2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import Foundation

class ModelController {
    
    static let shared = ModelController()
    
    func loadUserData() -> UserConfig? {
           let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let userConfigFileURL = documentDirectoryURL.appendingPathComponent("userConfig").appendingPathExtension("json")
           
           guard let data = try? Data(contentsOf: userConfigFileURL) else { return nil }
           let items = (try? JSONDecoder().decode(UserConfig.self, from: data)) ?? nil
        print("Data is loaded")
        return items
       
    }
    
       
    func saveUserData(_ config: UserConfig) {
           let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let userConfigFileURL = documentDirectoryURL.appendingPathComponent("userConfig").appendingPathExtension("json")
           
           if let data = try? JSONEncoder().encode(config) {
               try? data.write(to: userConfigFileURL)
            print("Data is saved")
           }
       }
}
