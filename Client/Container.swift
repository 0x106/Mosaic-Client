//
//  Container.swift
//  Client
//
//  Created by Jordan Campbell on 29/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

class Label: Container {
    
    init(_ text: String, _ isButton: Bool) {
        super.init()
    }
    
}

class Container {
    
    var width: Float = 0.0
    var height: Float = 0.0
    
    var nucleus: CGRect   = CGRect()
    var padding: [Float] = [0.0, 0.0, 0.0, 0.0]
    var borders: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    var cell: CGRect = CGRect()
    
    var nucleus_height:         Float = 0.0
    var nucleus_width:          Float = 0.0
    var x:                      Float = 0.0
    var y:                      Float = 0.0
    
    var border_top_width:       Float = 0.0
    var padding_top:            Float = 0.0
    
    var border_bottom_width:    Float = 0.0
    var padding_bottom:         Float = 0.0
    
    var border_left_width:      Float = 0.0
    var padding_left:           Float = 0.0
    
    var border_right_width:     Float = 0.0
    var padding_right:          Float = 0.0
    
    var total_height:           Float = 0.0
    var total_width:            Float = 0.0
    
    var font_size:              Float = 0.0
    
    var border_color:           UIColor = UIColor()
    var background_color:       UIColor = UIColor()
    var font_color:             UIColor = UIColor()
    
    var text: String = ""
    
    var isButton: Bool = false
    var href: String = ""
    
    var rootNode: SCNNode = SCNNode()
    var nodeKey: String = ""
    var image: UIImage = UIImage()
    var plane: SCNPlane = SCNPlane()
    let scale: Float = 0.001
    
    let top     = 0
    let bottom  = 1
    let left    = 2
    let right   = 3
    
    init(){}

    init?(withlabel     labelText: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        let computedStyle = computeStylesFromDict(style)
        
        if ( (computedStyle["background-image"] as! String != "none") && (computedStyle["background-color"]! as! UIColor).cgColor.alpha == CGFloat(0.0) && (computedStyle["color"]! as! UIColor).cgColor.alpha == CGFloat(0.0))
            || ((computedStyle["font-size"]! as! Float) < 10.0) || (layout["x"].doubleValue < 0) || (layout["y"].doubleValue < 0) {
            return nil
        }
        
        self.text = labelText
        
        // check if this is a link - if so then make this a button and add the href that it points to.
        let parentType = parent["nodeName"]
        if parentType == "A" {
            for (_, attrValue) in parent["attr"] {
                if attrValue["name"] == "href" {
                    self.isButton = true
                    self.href = attrValue["value"].stringValue
                }
            }
        }
        
        self.nucleus_height          = Float(layout["height"].doubleValue)
        self.nucleus_width           = Float(layout["width"].doubleValue)
        self.x                       = Float(layout["x"].doubleValue)
        self.y                       = Float(layout["y"].doubleValue)
        self.border_top_width        = computedStyle["border-top-width"] as! Float
        self.padding_top             = computedStyle["padding-top"] as! Float
        self.border_bottom_width     = computedStyle["border-bottom-width"] as! Float
        self.padding_bottom          = computedStyle["padding-bottom"] as! Float
        self.border_left_width       = computedStyle["border-left-width"] as! Float
        self.padding_left            = computedStyle["padding-left"] as! Float
        self.border_right_width      = computedStyle["border-right-width"] as! Float
        self.padding_right           = computedStyle["padding-right"] as! Float
        self.total_height            = nucleus_height + padding_top + padding_bottom + border_bottom_width + border_top_width
        self.total_width             = nucleus_width + border_left_width + padding_left + border_right_width + padding_right
        self.font_size               = computedStyle["font-size"] as! Float - 2.0
        
        self.border_color            = (computedStyle["border-color"] as! UIColor)
        self.background_color        = (computedStyle["background-color"] as! UIColor)
        self.font_color              = (computedStyle["color"] as! UIColor)
        
        self.determineLayout()
    }
    
    func draw() {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(self.total_width), height: CGFloat(self.total_height)))
        self.image = renderer.image { context in
            
            self.background_color.setFill()
            context.fill(self.cell)
            
            self.border_color.setFill()
            context.fill(self.borders[top])
            context.fill(self.borders[bottom])
            context.fill(self.borders[left])
            context.fill(self.borders[right])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let font = UIFont(name: "HelveticaNeue-thin", size: CGFloat(self.font_size))
            
            let attrs = [NSAttributedStringKey.font: font!,
                         NSAttributedStringKey.paragraphStyle: paragraphStyle]
//                         NSAttributedStringKey.strokeColor: self.font_color]
            
            let message = self.text
            message.draw(with: self.nucleus, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        
        self.plane = SCNPlane(width: CGFloat(self.total_width * self.scale), height: CGFloat(self.total_height * self.scale))
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.plane
        
        self.rootNode.position = SCNVector3Make((  self.x + (self.total_width/2.0))*self.scale,
                                                ( -self.y - (self.total_height/2.0))*self.scale,
                                                -1)
        
        print("x: \(self.x)")
        print("y: \(self.y)")
        print(self.rootNode.position)
        print("===========================")
    }
    
    func determineLayout() {
        self.cell = CGRect(x: CGFloat(0.0),
                           y: CGFloat(0.0),
                           width: CGFloat(self.total_width),
                           height: CGFloat(self.total_height))
        
        self.nucleus = CGRect(x: CGFloat(self.border_left_width + self.padding_left),
                              y: CGFloat(self.border_top_width + self.padding_top),
                              width: CGFloat(self.nucleus_width),
                              height: CGFloat(self.nucleus_height))
        
        self.borders[bottom] = CGRect(x: CGFloat(0.0),
                                      y: CGFloat(self.border_top_width + self.padding_top + self.nucleus_height + self.padding_bottom),
                                      width: CGFloat(self.total_width),
                                      height: CGFloat(self.border_bottom_width))
        
        self.borders[top] = CGRect(x: CGFloat(0.0),
                                   y: CGFloat(0.0),
                                   width: CGFloat(self.total_width),
                                   height: CGFloat(self.border_top_width))
        
        self.borders[left] = CGRect(x: CGFloat(0.0),
                                    y: CGFloat(0.0),
                                    width: CGFloat(self.border_left_width),
                                    height: CGFloat(self.total_height))
        
        self.borders[right] = CGRect(x: CGFloat(self.border_left_width + self.nucleus_width + self.padding_left + self.padding_right),
                                     y: CGFloat(0.0),
                                     width: CGFloat(self.border_right_width),
                                     height: CGFloat(self.total_height))
        
        print(self.nodeKey, self.cell)
        for b in self.borders {
            print(b)
        }
        
    }

}








// end
