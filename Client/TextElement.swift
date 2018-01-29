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

class Text: Element {
    
    var text: String          = ""
    
    var plane: SCNPlane       = SCNPlane()
    var label: UILabel        = UILabel()
    var image: UIImage        = UIImage()
    
    var bgLabel: UILabel      = UILabel()
    var bgImage: UIImage      = UIImage()
    var bgPlane: SCNPlane     = SCNPlane()
    
    var bgAlpha: CGFloat = CGFloat(1.0)
    var bgColor: UIColor = UIColor()
    
    var textAlpha: CGFloat = CGFloat(1.0)
    var textColor: UIColor = UIColor()
    
    var textFontSize: Float = 12.0
    
    init?(withlabel     labelText: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        super.init()
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        self.bgNode.name = self.nodeKey + "-bg"
        
        let computedStyle = computeStylesFromDict(style)
        let text = parseText(labelText)

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

        self.text = text

        self.label = UILabel(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(Float(layout["width"].doubleValue)), height: CGFloat(Float(layout["height"].doubleValue))))

        self.bgAlpha = (computedStyle["background-color"]! as! UIColor).cgColor.alpha
        self.bgColor = (computedStyle["background-color"]! as! UIColor)

        self.textAlpha = (computedStyle["color"]! as! UIColor).cgColor.alpha
        self.textColor = (computedStyle["color"]! as! UIColor)

        self.textFontSize = (computedStyle["font-size"]! as! Float)

//        self.label.textAlignment = .left // TODO: check the alignment
        self.label.font = UIFont(name: "Helvetica", size: CGFloat(self.textFontSize))
        self.label.textColor = self.textColor.withAlphaComponent(self.textAlpha)
        self.label.adjustsFontSizeToFitWidth = true
        
        self.label.text = self.text

        self.label.backgroundColor = self.bgColor.withAlphaComponent(self.bgAlpha)
        self.label.clipsToBounds = true

        let pad_left = (computedStyle["padding-left"] as! Float)
        let pad_right = (computedStyle["padding-right"] as! Float)
        let pad_top = (computedStyle["padding-top"] as! Float)
        let pad_bottom = (computedStyle["padding-bottom"] as! Float)
        
        let labelWidth = self.label.frame.width + CGFloat(pad_left) + CGFloat(pad_right)
        let labelHeight = self.label.frame.height + CGFloat(pad_top) + CGFloat(pad_bottom)
        self.bgLabel = UILabel(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: labelWidth, height: labelHeight))
        self.addBorders(computedStyle)
        
        self.plane = SCNPlane(width: CGFloat(w), height: CGFloat(h))
        self.bgPlane = SCNPlane(width: labelWidth * CGFloat(scale), height: labelHeight * CGFloat(scale))

        let x_ = x + Float(CGFloat(w) / 2)
        let y_ = y + Float(CGFloat(h) / 2)
        
        let bgx: Float = (pad_right-((pad_left+pad_right) / 2.0)) * 0.001
        let bgy: Float = (pad_top-((pad_top+pad_bottom) / 2.0)) * 0.001
    
        self.rootNode.position = SCNVector3Make(x_, y, 0.0)
        self.bgNode.position = SCNVector3Make(bgx, bgy, 0.0)
        
        let boxSize = [self.label.frame.width, self.label.frame.height, 0.1]
//        self.createBox(boxSize, self.rootNode.position, self.rootNode.eulerAngles)
        
        self.labelToImage()
    }
    
    func labelToImage() {
        self.image = UIImage.imageWithLabel(label: self.label)
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.plane
        
        self.bgImage = UIImage.imageWithLabel(label: self.bgLabel)
        self.bgPlane.firstMaterial?.diffuse.contents = self.bgImage
        self.bgNode.geometry = self.bgPlane
        
        self.rootNode.addChildNode(self.bgNode)
    }
}


extension Text {
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

extension CALayer {
    //    https://stackoverflow.com/a/30519213/7098234
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}




class AtlasUILabel: UILabel {
    
    var left: CGFloat = CGFloat(0.0)
    var top: CGFloat = CGFloat(0.0)
    var right: CGFloat = CGFloat(0.0)
    var bottom: CGFloat = CGFloat(0.0)

    // https://stackoverflow.com/a/5155382/7098234
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    func setValues(_ left: CGFloat, _ top: CGFloat, _ right: CGFloat, _ bottom: CGFloat) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
}


































class TextBlock: Element {
    
    var text: String          = ""
    
    var label: UITextView     = UITextView()
    var plane: SCNPlane       = SCNPlane()
    var image: UIImage        = UIImage()
    
    var bgLabel: UITextView      = UITextView()
    var bgImage: UIImage      = UIImage()
    var bgPlane: SCNPlane     = SCNPlane()
    
    var bgAlpha: CGFloat = CGFloat(1.0)
    var bgColor: UIColor = UIColor()
    
    var textAlpha: CGFloat = CGFloat(1.0)
    var textColor: UIColor = UIColor()
    var textFontSize: Float = 12.0
    
    init?(withlabel     labelText: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        super.init()
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        self.bgNode.name = self.nodeKey + "-bg"
        
        let computedStyle = computeStylesFromDict(style)
        let text = parseText(labelText)
        
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
        }
        
        var x = Float(layout["x"].doubleValue) * scale / 4.0
        var y = -Float(layout["y"].doubleValue) * scale / 4.0
        var w = Float(layout["width"].doubleValue) * scale
        var h = Float(layout["height"].doubleValue) * scale
        
        self.text = text
        self.label = UITextView(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(Float(layout["width"].doubleValue) * 4.0), height: CGFloat(Float(layout["height"].doubleValue) * 4.0)))
        
        self.textAlpha = (computedStyle["color"]! as! UIColor).cgColor.alpha
        self.textColor = (computedStyle["color"]! as! UIColor)
        self.textFontSize = (computedStyle["font-size"]! as! Float)
        self.label.font = UIFont(name: "Helvetica", size: CGFloat(self.textFontSize))
        self.label.textColor = self.textColor.withAlphaComponent(self.textAlpha)
        
        self.label.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.5))
        
        self.label.text = self.text
        self.label.clipsToBounds = true
    
        self.plane = SCNPlane(width: CGFloat(w), height: CGFloat(h))
        
        x = x + Float(CGFloat(w) / 2.0)
        y = y - Float(CGFloat(h) / 2.0)
        
        self.rootNode.position = SCNVector3Make(x, y, 0.0)
        
        self.bgAlpha = (computedStyle["background-color"]! as! UIColor).cgColor.alpha
        self.bgColor = (computedStyle["background-color"]! as! UIColor)
        
        let pad_left = (computedStyle["padding-left"] as! Float) / 4.0
        let pad_right = (computedStyle["padding-right"] as! Float) / 4.0
        let pad_top = (computedStyle["padding-top"] as! Float) / 4.0
        let pad_bottom = (computedStyle["padding-bottom"] as! Float) / 4.0
        
        let labelWidth = self.label.frame.width + CGFloat(pad_left) + CGFloat(pad_right)
        let labelHeight = self.label.frame.height + CGFloat(pad_top) + CGFloat(pad_bottom)
        
        self.bgLabel = UITextView(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: labelWidth, height: labelHeight))
        self.addBorders(computedStyle)
        self.bgPlane = SCNPlane(width: labelWidth / 8.0 * CGFloat(scale), height: labelHeight / 8.0 * CGFloat(scale))
        
        var bgx: Float = ((pad_right-((pad_left+pad_right) / 2.0)) * 0.001) - Float(CGFloat(w/4.0) / 2.0)
        var bgy: Float = ((pad_top-((pad_top+pad_bottom) / 2.0)) * 0.001) + Float(CGFloat(h/4.0) / 2.0)
        
//        bgx = bgx + (Float(labelWidth) / 2.0 * scale)
//        bgy = bgy - (Float(labelHeight) / 2.0 * scale)
        
        self.bgNode.position = SCNVector3Make(bgx, bgy, -0.0005)
        print(self.bgNode.position)
        self.labelToImage()
    }
    
    func labelToImage() {
        self.image = UIImage.imageWithTextView(textView: self.label)
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.plane
        
        self.bgImage = UIImage.imageWithTextView(textView: self.bgLabel)
        self.bgPlane.firstMaterial?.diffuse.contents = self.bgImage
        self.bgNode.geometry = self.bgPlane
        
        self.rootNode.addChildNode(self.bgNode)
    }
}



extension TextBlock {
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









// end
