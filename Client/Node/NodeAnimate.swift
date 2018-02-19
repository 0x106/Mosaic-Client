//
//  NodeAnimate.swift
//  Client
//
//  Created by Jordan Campbell on 18/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

private let frequency = 1.0 / 60.0

// each Node stores a list of animation instances
class Animation {
    
    var duration: Double = 0.0
    var value: [Float] = [Float]()
    var scaleValue: Float = 1.0
    var singleScale: Bool = false
    var type: String = "setTo"
    var property: String = ""

    var data: Dictionary<String, Any>
    var action: SCNAction = SCNAction()
    
    var custom: Bool = false
    
    init(_ _data: Dictionary<String, Any>) {
        self.data = _data
        
        self.setValues()
        self.setAnimation()
    }
    
    func setValues() {
        
        if let _property = self.data["property"] as? String {
            self.property = _property
        }
        
        if let _duration = self.data["duration"] as? String {
            self.duration = Double(_duration)!
        }
        
        if let valueString = self.data["value"] as? String {
            let _value = extractValuesFromCSV(valueString)
            if _value.count == 1 {
                self.scaleValue = _value[0]
                self.singleScale = true
            } else if _value.count == 3 {
                self.value = _value
//                self.value = SCNVector3Make(_value[0], _value[1], _value[2])
            } else { }
        }
        
        if let _type = self.data["command"] as? String {
            self.type = _type
        }
    }
    
    func setAnimation() {
        
        if property == "position" {
            if type == "setTo" {
                let translation = SCNVector3Make(self.value[0], self.value[1], self.value[2])
                self.action = SCNAction.move(to: translation, duration: self.duration)
            } else if type == "changeBy" {
                let translation = SCNVector3Make(self.value[0], self.value[1], self.value[2])
                self.action = SCNAction.move(by: translation, duration: self.duration)
            } else {
            }
        }
        
        if property == "rotation" {
            if type == "setTo" {
                let rotation = SCNVector3Make(self.value[0], self.value[1], self.value[2])
                self.action = SCNAction.rotateTo(x: CGFloat(rotation.x),
                                               y: CGFloat(rotation.y),
                                               z: CGFloat(rotation.z),
                                               duration: duration)
            } else if type == "changeBy" {
                let rotation = SCNVector3Make(self.value[0], self.value[1], self.value[2])
                self.action = SCNAction.rotateBy(x: CGFloat(rotation.x),
                                               y: CGFloat(rotation.y),
                                               z: CGFloat(rotation.z),
                                               duration: duration)
            } else {
            }
        }
    
        if property == "scale" {
            if self.singleScale {
                if type == "setTo" {
                    self.action = SCNAction.scale(to: CGFloat(self.scaleValue), duration: self.duration)
                } else if type == "changeBy" {
                    self.action = SCNAction.scale(by: CGFloat(self.scaleValue), duration: self.duration)
                } else {
                }
            }
        }
        
        if property == "transparency" || property.hasSuffix("color") {
            self.custom = true
        }
    }
    
    func _print() {
        let output = "Animation: \(self.data)"
        print(output)
    }
}

extension Node {
    
    func performAnimations() {
        for _animation in self.animations {
            
            if _animation.custom {
                
                if _animation.property.hasSuffix("color") {
                    let count = _animation.duration / frequency
                    var iteration = 0
                    
                    if _animation.type == "changeBy" {
                        var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
                            if iteration == Int(count) {timer.invalidate()}
                            
                            let percent = (Float(iteration) * Float(1.0 / count))

                            let alpha = percent
                            
                            let r1 = ((_animation.value[0]/255) * alpha), r2 = Float(self.backgroundColor.cgColor.components![0]) * (1 - alpha)
                            let g1 = ((_animation.value[1]/255) * alpha), g2 = Float(self.backgroundColor.cgColor.components![1]) * (1 - alpha)
                            let b1 = ((_animation.value[2]/255) * alpha), b2 = Float(self.backgroundColor.cgColor.components![2]) * (1 - alpha)
                            
                            var a1:Float = 1.0, a2:Float = 0.0
                            if _animation.value.count == 4 {
                                a1 = _animation.value[3] * alpha
                            }
                            
                            if self.backgroundColor.cgColor.components!.count == 4 {
                                a2 = Float(self.backgroundColor.cgColor.components![3]) * (1 - alpha)
                            }
                            
                            if _animation.property == "background-color" {
                                self.backgroundColor = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            if _animation.property == "color" {
                                self.color = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            if _animation.property == "border-top-color" {
                                self.borderColor[top] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            if _animation.property == "border-left-color" {
                                self.borderColor[left] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            if _animation.property == "border-right-color" {
                                self.borderColor[right] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            if _animation.property == "border-bottom-color" {
                                self.borderColor[bottom] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(a1 + a2))
                            }
                            
                            let _ = self.render()
                            iteration += 1
                        }
                    } else if _animation.type == "setTo" {
                        var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
                            if iteration == Int(count) {timer.invalidate()}
                            
                            let percent = (Float(iteration) * Float(1.0 / count))
                            
                            let alpha = percent / 255
                            
                            var a1:Float = 1.0
                            if _animation.value.count == 4 {
                                a1 = _animation.value[3] * alpha
                            }
                            
                            if _animation.property == "background-color" {
                                self.backgroundColor = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            if _animation.property == "color" {
                                self.color = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            if _animation.property == "border-top-color" {
                                self.borderColor[top] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            if _animation.property == "border-left-color" {
                                self.borderColor[left] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            if _animation.property == "border-right-color" {
                                self.borderColor[right] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            if _animation.property == "border-bottom-color" {
                                self.borderColor[bottom] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
                            }
                            
                            let _ = self.render()
                            iteration += 1
                        }
                    } else {}
            }
                
            } else {
                self.rootNode.runAction(_animation.action)
            }
        }
    }

    func addAnimation(_ action: Dictionary<String, Any>) {
        if let _ = action["property"] as? String {
            let _animation = Animation(action)
            self.animations.append( _animation )
        } else {
            return
        }
    }
    
}
