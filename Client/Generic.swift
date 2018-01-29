//
//  Generic.swift
//  Client
//
//  Created by Jordan Campbell on 29/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

class Element {
    
    let scale: Float = 0.001
    
    var isButton: Bool = false
    var href: String = ""
    
    var nodeKey: String = ""
    
    var rootNode: SCNNode     = SCNNode()
    var bgNode: SCNNode       = SCNNode()
    var boxNode: SCNNode      = SCNNode()
    
    var boxGeometry: SCNBox   = SCNBox()
    
    init() {}
    
    func createBox(_ size: [CGFloat], _ position: SCNVector3, _ orientation: SCNVector3) {
        self.boxGeometry.height = size[1]
        self.boxGeometry.width = size[0]
        self.boxGeometry.length = size[2]
        
        self.boxGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        self.boxGeometry.firstMaterial?.transparency = CGFloat(0.4)
        
        self.boxNode.geometry = boxGeometry
        self.boxNode.position = SCNVector3Make(position.x, position.y, position.z - (Float(size[2]) / 2.0))
        self.boxNode.eulerAngles = orientation
        
        self.rootNode.addChildNode(self.boxNode)
    }
}


class Generic: Element {
    
    var bgLabel: UILabel      = UILabel()
    var bgImage: UIImage      = UIImage()
    var bgPlane: SCNPlane     = SCNPlane()
    
    var bgAlpha: CGFloat = CGFloat(1.0)
    var bgColor: UIColor = UIColor()
    
    init?(withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        super.init()
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        self.bgNode.name = self.nodeKey + "-bg"
        
        let computedStyle = computeStylesFromDict(style)
        
        if ( (computedStyle["background-image"] as! String != "none") && (computedStyle["background-color"]! as! UIColor).cgColor.alpha == CGFloat(0.0) && (computedStyle["color"]! as! UIColor).cgColor.alpha == CGFloat(0.0))
            || ((computedStyle["font-size"]! as! Float) < 10.0) || (layout["x"].doubleValue < 0) || (layout["y"].doubleValue < 0) {
            return nil
        }
        
        let parentType = parent["nodeName"]
        
        if parentType == "A" {
            for (_, attrValue) in parent["attr"] {
                if attrValue["name"] == "href" {
                    self.isButton = true
                    self.href = attrValue["value"].stringValue
                }
            }
        } else {
            //            return nil
        }
        
        let x = Float(layout["x"].doubleValue) * scale
        let y = -Float(layout["y"].doubleValue) * scale
        let w = Float(layout["width"].doubleValue) * scale
        let h = Float(layout["height"].doubleValue) * scale
    
        let pad_left = (computedStyle["padding-left"] as! Float)
        let pad_right = (computedStyle["padding-right"] as! Float)
        let pad_top = (computedStyle["padding-top"] as! Float)
        let pad_bottom = (computedStyle["padding-bottom"] as! Float)
        
        let labelWidth = CGFloat(Float(layout["width"].doubleValue)) + CGFloat(pad_left) + CGFloat(pad_right)
        let labelHeight = CGFloat(Float(layout["height"].doubleValue)) + CGFloat(pad_top) + CGFloat(pad_bottom)
    
        self.bgLabel = UILabel(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: labelWidth, height: labelHeight))
        
        self.bgAlpha = (computedStyle["background-color"]! as! UIColor).cgColor.alpha
        self.bgColor = (computedStyle["background-color"]! as! UIColor)
        
        self.bgLabel.backgroundColor = self.bgColor.withAlphaComponent(self.bgAlpha)
        self.bgLabel.clipsToBounds = true
        
        self.addBorders(computedStyle)
        
        self.bgPlane = SCNPlane(width: labelWidth * CGFloat(scale), height: labelHeight * CGFloat(scale))
        
        let x_ = x + Float(CGFloat(w) / 2)
        let y_ = y + Float(CGFloat(h) / 2)
        
        let bgx: Float = (pad_right-((pad_left+pad_right) / 2.0)) * 0.001
        let bgy: Float = (pad_top-((pad_top+pad_bottom) / 2.0)) * 0.001
        
        self.rootNode.position = SCNVector3Make(x_, y, 0.0)
        self.bgNode.position = SCNVector3Make(bgx, bgy, 0.0)
        
        self.labelToImage()
    }
    
    func labelToImage() {

        self.bgImage = UIImage.imageWithLabel(label: self.bgLabel)
        self.bgPlane.firstMaterial?.diffuse.contents = self.bgImage
        self.bgNode.geometry = self.bgPlane
        
        self.rootNode.addChildNode(self.bgNode)
    }

    func addBorders(_ style: [String:Any]) {
        
        if (style["border-left-width"] as! Float) > 0 {
            let color = style["border-left-color"] as! UIColor
            let width = style["border-left-width"] as! Float
            self.bgLabel.layer.addBorder(edge: .left, color: color, thickness: CGFloat(width))
        }
        
        if (style["border-top-width"] as! Float) > 0 {
            let color = style["border-top-color"] as! UIColor
            let width = style["border-top-width"] as! Float
            self.bgLabel.layer.addBorder(edge: .top, color: color, thickness: CGFloat(width))
        }
        
        if (style["border-right-width"] as! Float) > 0 {
            let color = style["border-right-color"] as! UIColor
            let width = style["border-right-width"] as! Float
            self.bgLabel.layer.addBorder(edge: .right, color: color, thickness: CGFloat(width))
        }
        
        if (style["border-bottom-width"] as! Float) > 0 {
            let color = style["border-bottom-color"] as! UIColor
            let width = style["border-bottom-width"] as! Float
            self.bgLabel.layer.addBorder(edge: .bottom, color: color, thickness: CGFloat(width))
        }
        
    }
}
