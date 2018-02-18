//
//  ConfigManager.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import Alamofire

class ConfigManager {
    
    let config_server: String = "http://0c5161f8.ngrok.io"
    var config_data: Dictionary<String, Dictionary<String, Any>> = Dictionary<String, Dictionary<String, Any>>()
    
    func setup(_ url: String, _ data: Dictionary<String, Any>) {
        for (key,raw_value) in data {
            if let value = raw_value as? Dictionary<String, Any> {
                config_data[key] = value
            }
        }
        print("Config: \(config_data)")
    }
}







































//        if url.hasPrefix("http://www.") || url.hasPrefix("https://www.") {
//            let firstDotIndex = url.index(after: url.index(of: ".") ?? url.startIndex)
//            let temp = url[firstDotIndex..<url.endIndex]
//            let secndDotIndex = temp.index(after: temp.index(of: ".") ?? temp.endIndex)
//            output = String(temp[temp.startIndex..<secndDotIndex])
//        } else {
//            var index = url.index(of: "/") ?? url.startIndex
//            index = url.index(after: index)
//            index = url.index(after: index)
//            let temp = url[index..<url.endIndex]
//            let secndDotIndex = temp.index(after: temp.index(of: ".") ?? temp.endIndex)
//            output = String(temp[temp.startIndex..<secndDotIndex])
//        }
//
//        print(output)
