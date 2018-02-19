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
            } else {
                if type == "setTo" {
                    self.action = SCNAction.scale(to: CGFloat(self.value[0]), duration: self.duration)
                } else if type == "changeBy" {
                    self.action = SCNAction.scale(by: CGFloat(self.value[0]), duration: self.duration)
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
    
    func getTargetColor(_ _alpha: Float, _ _type: String, _ target: [Float], _ _current: [CGFloat]) -> [Float] {
        
        var _target = target
        
        if _type == "changeBy" {
            for i in 0...3 {
                _target[i] += Float(_current[i])
            }
            if _target.count == 4 && _current.count == 4 {
                _target[3] += Float(_current[3])
            }
        }
        
        let r1 = ((_target[0]/255) * _alpha), r2 = Float(_current[0]) * (1 - _alpha)
        let g1 = ((_target[1]/255) * _alpha), g2 = Float(_current[1]) * (1 - _alpha)
        let b1 = ((_target[2]/255) * _alpha), b2 = Float(_current[2]) * (1 - _alpha)
        
        var a1:Float = 1.0, a2:Float = 0.0
        if _target.count == 4 {
            a1 = _target[3] * _alpha
        }
        
        if _current.count == 4 {
            a2 = Float(_current[3]) * (1 - _alpha)
        }
        
        return [r1, r2, g1, g2, b1, b2, a1, a2]
    }
    
    func performAnimations() {
        for _animation in self.animations {
            
            if _animation.custom {
                
                if _animation.property.hasSuffix("color") {
                    let count = _animation.duration / frequency
                    var iteration = 0

                    var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
                        if iteration == Int(count) {timer.invalidate()}
                        
                        let percent = (Float(iteration) * Float(1.0 / count))

                        let alpha = percent
                        
                        if _animation.property == "background-color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.backgroundColor.cgColor.components!)
                            self.backgroundColor = UIColor(red:   CGFloat(target[0] + target[1]),
                                                           green: CGFloat(target[2] + target[3]),
                                                           blue:  CGFloat(target[4] + target[5]),
                                                           alpha: CGFloat(target[6] + target[7]))
                        }
                        
                        if _animation.property == "color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.color.cgColor.components!)
                            self.color = UIColor(red:   CGFloat(target[0] + target[1]),
                                                           green: CGFloat(target[2] + target[3]),
                                                           blue:  CGFloat(target[4] + target[5]),
                                                           alpha: CGFloat(target[6] + target[7]))
                        }
                        
                        if _animation.property == "border-top-color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.borderColor[top].cgColor.components!)
                            self.borderColor[top] = UIColor(red:   CGFloat(target[0] + target[1]),
                                                             green: CGFloat(target[2] + target[3]),
                                                             blue:  CGFloat(target[4] + target[5]),
                                                             alpha: CGFloat(target[6] + target[7]))
                        }
                        
                        if _animation.property == "border-left-color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.borderColor[left].cgColor.components!)
                            self.borderColor[left] = UIColor(red:   CGFloat(target[0] + target[1]),
                                                            green: CGFloat(target[2] + target[3]),
                                                            blue:  CGFloat(target[4] + target[5]),
                                                            alpha: CGFloat(target[6] + target[7]))

                        }
                        
                        if _animation.property == "border-right-color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.borderColor[right].cgColor.components!)
                            self.borderColor[right] = UIColor(red:   CGFloat(target[0] + target[1]),
                                                            green: CGFloat(target[2] + target[3]),
                                                            blue:  CGFloat(target[4] + target[5]),
                                                            alpha: CGFloat(target[6] + target[7]))

                        }
                        
                        if _animation.property == "border-bottom-color" {
                            let target = self.getTargetColor(alpha, _animation.type, _animation.value, self.borderColor[bottom].cgColor.components!)
                            self.borderColor[bottom] = UIColor(red:   CGFloat(target[0] + target[1]),
                                                            green: CGFloat(target[2] + target[3]),
                                                            blue:  CGFloat(target[4] + target[5]),
                                                            alpha: CGFloat(target[6] + target[7]))

                        }
                        
                        let _ = self.render()
                        iteration += 1
                    }
                    
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











//var _ = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { timer in
//    if iteration == Int(count) {timer.invalidate()}
//
//    let percent = (Float(iteration) * Float(1.0 / count))
//
//    let alpha = percent / 255
//
//    var a1:Float = 1.0
//    if _animation.value.count == 4 {
//        a1 = _animation.value[3] * alpha
//    }
//
//    if _animation.property == "background-color" {
//        self.backgroundColor = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    if _animation.property == "color" {
//        self.color = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    if _animation.property == "border-top-color" {
//        self.borderColor[top] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    if _animation.property == "border-left-color" {
//        self.borderColor[left] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    if _animation.property == "border-right-color" {
//        self.borderColor[right] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    if _animation.property == "border-bottom-color" {
//        self.borderColor[bottom] = UIColor(red: CGFloat(_animation.value[0] * alpha), green: CGFloat(_animation.value[1] * alpha), blue: CGFloat(_animation.value[2] * alpha), alpha: CGFloat(a1))
//    }
//
//    let _ = self.render()
//    iteration += 1
//}

