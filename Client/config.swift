//
//  config.swift
//  Client
//
//  Created by Jordan Campbell on 12/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import SwiftyJSON
import ARKit

var config: Dictionary<String, Dictionary<String, Any>> = Dictionary<String, Dictionary<String, Any>>()

func initConfig() {
    var cf = Dictionary<String, Any>()
    cf["key"] = "-firstdiv"
    cf["isVisible"] = true
    cf["position"] = SCNVector3Make(0, 0, 0)
    cf["rotation"] = SCNVector3Make(0, 0, 0)
    cf["scale"] = SCNVector3Make(0, 0, 0)
    cf["background-color"] = [73, 91, 110]

    config[ cf["key"] as! String ] = cf
}


func getConfigVar(forKey key: String) -> Dictionary<String, Any>? {
    return config[key]
}

