//
//  NodeAnimate.swift
//  Client
//
//  Created by Jordan Campbell on 18/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

extension Node {
    func performAnimations() {
        
    }
    
//    func addAnimation(forProperty  property: String,
//                      withType     type:     String,
//                      withValue    value:    String,
//                      withDuration duration: String) {
    func addAnimation(_ action: Dictionary<String, Any>) {
        if let property = action["property"] as? String {
            
            var duration: Float = 0.0
            var value: SCNVector3 = SCNVector3Make(0,0,0)
            var type: String = "setTo"
            var animation: SCNAction = SCNAction()
            
            
            if let _duration = action["duration"] as? Float {
                duration = _duration
            }
            
            if let valueString = action["value"] as? String {
                let _value = extractValuesFromCSV(valueString)
                value = SCNVector3Make(_value[0], _value[1], _value[2])
            }
            
            if let _type = action["command"] as? String {
                type = _type
            }
            
            if property == "rotation" {
                if type == "setTo" {
//                    animation = 
                } else if type == "changeBy" {
                    
                } else {
                    
                }
            }
            
        } else {
            return
        }
    }
}
