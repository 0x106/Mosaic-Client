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
    var value: SCNVector3 = SCNVector3Make(0,0,0)
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
                self.value = SCNVector3Make(_value[0], _value[1], _value[2])
            } else { }
        }
        
        if let _type = self.data["command"] as? String {
            self.type = _type
        }
    }
    
    func setAnimation() {
        
        if property == "position" {
            if type == "setTo" {
                self.action = SCNAction.move(to: self.value, duration: self.duration)
            } else if type == "changeBy" {
                self.action = SCNAction.move(by: self.value, duration: self.duration)
            } else {
            }
        }
        
        if property == "rotation" {
            if type == "setTo" {
                self.action = SCNAction.rotateTo(x: CGFloat(value.x),
                                               y: CGFloat(value.y),
                                               z: CGFloat(value.z),
                                               duration: duration)
            } else if type == "changeBy" {
                self.action = SCNAction.rotateBy(x: CGFloat(value.x),
                                               y: CGFloat(value.y),
                                               z: CGFloat(value.z),
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
    
//    func animateColorProperty(_ _animation: Animation) {
    
//    }

    func performAnimations() {
        for _animation in self.animations {
            
            print("Handling animation")
            
            if _animation.custom {
                
                print("custom animation")
            
                if _animation.property.hasSuffix("color") {
                    let count = _animation.duration / frequency
                    var iteration = 0
                    
                    if _animation.type == "changeBy" {
                        var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
                            if iteration == Int(count) {timer.invalidate()}
                            
                            let percent = (Float(iteration) * Float(1.0 / count))

                            let alpha = percent
                            
                            let r1 = ((_animation.value.x/255) * alpha), r2 = Float(self.backgroundColor.cgColor.components![0]) * (1 - alpha)
                            let g1 = ((_animation.value.y/255) * alpha), g2 = Float(self.backgroundColor.cgColor.components![1]) * (1 - alpha)
                            let b1 = ((_animation.value.z/255) * alpha), b2 = Float(self.backgroundColor.cgColor.components![2]) * (1 - alpha)
                            
                            if _animation.property == "background-color" {
                                self.backgroundColor = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "color" {
                                self.color = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-top-color" {
                                self.borderColor[top] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-left-color" {
                                self.borderColor[left] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-right-color" {
                                self.borderColor[right] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-bottom-color" {
                                self.borderColor[bottom] = UIColor(red:   CGFloat(r1 + r2), green: CGFloat(g1 + g2), blue:  CGFloat(b1 + b2), alpha: CGFloat(1.0))
                            }
                            
                            let _ = self.render()
                            iteration += 1
                        }
                    } else if _animation.type == "setTo" {
                        var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
                            if iteration == Int(count) {timer.invalidate()}
                            
                            let percent = (Float(iteration) * Float(1.0 / count))
                            
                            let alpha = percent / 255
                            
                            if _animation.property == "background-color" {
                                self.backgroundColor = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "color" {
                                self.color = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-top-color" {
                                self.borderColor[top] = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-left-color" {
                                self.borderColor[left] = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-right-color" {
                                self.borderColor[right] = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            if _animation.property == "border-bottom-color" {
                                self.borderColor[bottom] = UIColor(red: CGFloat(_animation.value.x * alpha), green: CGFloat(_animation.value.y * alpha), blue: CGFloat(_animation.value.z * alpha), alpha: CGFloat(1.0))
                            }
                            
                            let _ = self.render()
                            iteration += 1
                        }
                    } else {print("incorrect suffix \(_animation.property)")}
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
