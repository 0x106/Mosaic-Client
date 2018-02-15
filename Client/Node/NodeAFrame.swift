//
//  NodeAFrame.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

let AFrameTypes: [String] = ["A-SCENE", "A-BOX", "A-SPHERE", "A-CYLINDER", "A-PLANE", "A-SKY", "A-ENTITY"]
    
    
    
    
// example for A-ENTITY
//["attr": <__NSArrayM 0x1c4648250>(
//    {
//    name = geometry;
//    value = "primitive: sphere; radius: 1.5";
//    },
//    {
//    name = light;
//    value = "type: point; color: white; intensity: 2";
//    },
//    {
//    name = material;
//    value = "color: blue; shader: flat; src: glow.jpg";
//    },
//    {
//    name = position;
//    value = "0 0 -50";
//    }
//)

class AFrame: Node {
    
    private let aframePositionScale: Float = 0.1
    private let aframeScale: Float = 0.01
    private let defaultAFrameSize: Float = 0.1
    private var position: SCNVector3
    private var rotation: SCNVector3
    
    init?(_ _data: Dictionary<String, Any>,
          _ _requestURL: String,
          _ _depth: Int) {
        
        position = SCNVector3Make(0.0, 0.0, 0.0)
        rotation = SCNVector3Make(0.0, 0.0, 0.0)
        
        super.init()
        
        self.isAFrameNode = true
        self.commonInit(_data, _requestURL, _depth)
        self.initialise()
    }
    
    private func initialise() {
        
        var radius: Float = self.defaultAFrameSize
        if let _radius = getAttribute("radius") {
            radius = Float(_radius) ?? self.defaultAFrameSize
        }
        
        var width: Float = self.defaultAFrameSize
        if let _width = getAttribute("height") {
            width = Float(_width) ?? self.defaultAFrameSize
        }
        
        var height: Float = self.defaultAFrameSize
        if let _height = getAttribute("height") {
            height = Float(_height) ?? self.defaultAFrameSize
        }
        
        switch self.nodeName {
        case "A-BOX":
            self.geometry = SCNBox(width: CGFloat(self.defaultAFrameSize),
                                   height: CGFloat(self.defaultAFrameSize),
                                   length: CGFloat(self.defaultAFrameSize),
                                   chamferRadius: CGFloat(0.0))
        case "A-SPHERE":
            self.geometry = SCNSphere(radius: CGFloat(radius * self.aframePositionScale))
        case "A-CYLINDER":
            self.geometry = SCNCylinder(radius: CGFloat(radius * self.aframePositionScale), height: CGFloat(height * self.aframePositionScale))
        case "A-PLANE":
            self.geometry = SCNPlane(width: CGFloat(width * self.aframePositionScale), height: CGFloat(height * self.aframePositionScale))
        default:
            self.geometry = SCNGeometry()
        }
        
        if let aFramePosition = self.getAttribute("position") {
            self.position = SCNVectorFromString(aFramePosition)
        }
        
        if let aFrameRotation = self.getAttribute("rotation") {
            self.rotation = SCNVectorFromString(aFrameRotation)
            self.rotation.x = self.rotation.x * .pi / 180.0
            self.rotation.y = self.rotation.y * .pi / 180.0
            self.rotation.z = self.rotation.z * .pi / 180.0
            //            print("\(self.key) \(self.rotation)")
        }
        if let _color = self.getAttribute("color") {
            self.geometry?.firstMaterial?.diffuse.contents = parseHEXStringToUIColor(_color)
        }
        self.rootNode.geometry = self.geometry
        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true
        
        self.rootNode.eulerAngles = self.rotation
        
        self.rootNode.position = SCNVector3Make( (self.x * self.scale) + (self.position.x * self.aframePositionScale),
                                                 -(self.y * self.scale) + (self.position.y * self.aframePositionScale),
                                                 -(Float(self.treeDepth)*self.scale) +  (self.position.z * self.aframePositionScale) )
    }
    
    func SCNVectorFromString(_ input: String) -> SCNVector3 {
        let split = input.split(separator: " ")
        var output = SCNVector3Make(0, 0, 0)
        if split.count == 3 {
            output.x = Float(split[0]) ?? 0.0
            output.y = Float(split[1]) ?? 0.0
            output.z = Float(split[2]) ?? 0.0
        }
        return output
    }
    
    
    private func parseHEXStringToUIColor(_ hex: String) -> UIColor {
        if hex.hasPrefix("#") {
            let a = Array(hex)
            let b = Int(UInt(String(a[1]) + String(a[2]), radix: 16)!)
            let c = Int(UInt(String(a[3]) + String(a[4]), radix: 16)!)
            let d = Int(UInt(String(a[5]) + String(a[6]), radix: 16)!)
            let output = UIColor(red: b, green: c, blue: d)
            return output
        }
        return UIColor.white
    }
}
