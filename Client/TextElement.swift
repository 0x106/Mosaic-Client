//
//  TextElement.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

class Text {
    
    var rootNode: SCNNode = SCNNode()
    var text: String        = ""
    var plane: SCNPlane     = SCNPlane()
    var label: UILabel      = UILabel()
    var image: UIImage      = UIImage()
    
    var bgAlpha: CGFloat = CGFloat(1.0)
    var bgColor: UIColor = UIColor()
    
    var textAlpha: CGFloat = CGFloat(1.0)
    var textColor: UIColor = UIColor()
    
    var textFontSize: Float = 12.0
    
    let scale: Float = 0.001
    
    var isButton: Bool = false
    var href: String = ""
    
    var nodeKey: String = ""
    
    init?(withlabel     labelText: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        
        let computedStyle = computeStylesFromDict(style)

        if ((computedStyle["background-color"]! as! UIColor).cgColor.alpha == CGFloat(0.0) && (computedStyle["color"]! as! UIColor).cgColor.alpha == CGFloat(0.0))
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
            return nil
        }

        let x = Float(layout["x"].doubleValue) * scale
        let y = -Float(layout["y"].doubleValue) * scale
        let w = Float(layout["width"].doubleValue) * scale
        let h = Float(layout["height"].doubleValue) * scale

        self.text = labelText

        self.label = UILabel(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(Float(layout["width"].doubleValue)), height: CGFloat(Float(layout["height"].doubleValue))))

        self.bgAlpha = (computedStyle["background-color"]! as! UIColor).cgColor.alpha
        self.bgColor = (computedStyle["background-color"]! as! UIColor)

        self.textAlpha = (computedStyle["color"]! as! UIColor).cgColor.alpha
        self.textColor = (computedStyle["color"]! as! UIColor)

        self.textFontSize = (computedStyle["font-size"]! as! Float)

        self.label.textAlignment = .left // TODO: check the alignment
        self.label.font = UIFont(name: "Helvetica", size: CGFloat(self.textFontSize))
        self.label.textColor = self.textColor.withAlphaComponent(self.textAlpha)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.text = self.text

        self.label.backgroundColor = self.bgColor.withAlphaComponent(self.bgAlpha)
        self.label.clipsToBounds = true

        self.plane = SCNPlane(width: CGFloat(w), height: CGFloat(h))

        let x_ = x + Float(CGFloat(w) / 2)
        let y_ = y + Float(CGFloat(h) / 2)

        self.rootNode.position = SCNVector3Make(x_, y, 0.0)

        self.labelToImage()
    }
    
    func labelToImage() {
        self.image = UIImage.imageWithLabel(label: self.label)
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.plane
    }
}
