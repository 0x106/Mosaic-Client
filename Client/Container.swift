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
    var centre_x: Float = 0.0
    var centre_y: Float = 0.0
    
    var nucleus: CGRect   = CGRect()
    var padding: [Float] = [0.0, 0.0, 0.0, 0.0]
    var borders: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    var corners: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    var cell: CGRect = CGRect()
    
    var text: String = ""
    
    var isButton: Bool = false
    var href: String = ""
    
    var rootNode: SCNNode = SCNNode()
    var nodeKey: String = ""
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
        
        let nucleus_height:         Float = Float(layout["height"].doubleValue)
        let nucleus_width:          Float = Float(layout["width"].doubleValue)
        
        let border_top_width:       Float = computedStyle["border-top-width"] as! Float
        let padding_top:            Float = computedStyle["padding-top"] as! Float
        
        let border_bottom_width:    Float = computedStyle["border-bottom-width"] as! Float
        let padding_bottom:         Float = computedStyle["padding-bottom"] as! Float
        
        let border_left_width:      Float = computedStyle["border-left-width"] as! Float
        let padding_left:           Float = computedStyle["padding-left"] as! Float
        
        let border_right_width:     Float = computedStyle["border-right-width"] as! Float
        let padding_right:          Float = computedStyle["padding-right"] as! Float
        
        let total_height:           Float = border_top_width + padding_top + nucleus_height + border_bottom_width + padding_bottom
        let total_width:            Float = nucleus_width + border_left_width + padding_left + border_right_width + padding_right
        
        let font_size: Float = computedStyle["font-size"] as! Float - 2.0
        
        self.cell = CGRect(x: CGFloat(0.0),
                           y: CGFloat(0.0),
                           width: CGFloat(total_width),
                           height: CGFloat(total_height))
        
        self.nucleus = CGRect(x: CGFloat(border_left_width + padding_left),
                             y: CGFloat(border_top_width + padding_top),
                             width: CGFloat(nucleus_width),
                             height: CGFloat(nucleus_height))
        
        self.borders[bottom] = CGRect(x: CGFloat(0.0),
                            y: CGFloat(border_top_width + padding_top + nucleus_height + padding_bottom),
                            width: CGFloat(total_width),
                            height: CGFloat(border_bottom_width))
        
        self.borders[top] = CGRect(x: CGFloat(0.0),
                         y: CGFloat(0.0),
                         width: CGFloat(total_width),
                         height: CGFloat(border_top_width))
        
        self.borders[left] = CGRect(x: CGFloat(0.0),
                          y: CGFloat(0.0),
                          width: CGFloat(border_left_width),
                          height: CGFloat(total_height))
        
        self.borders[right] = CGRect(x: CGFloat(border_left_width + nucleus_width + padding_left + padding_right),
                           y: CGFloat(0.0),
                           width: CGFloat(border_right_width),
                           height: CGFloat(total_height))
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(total_width), height: CGFloat(total_height)))
        let img = renderer.image { context in
            
            UIColor.red.setFill()
            context.fill(self.borders[top])
//
            UIColor.green.setFill()
            context.fill(self.borders[bottom])

            UIColor.blue.setFill()
            context.fill(self.borders[left])

            UIColor.magenta.setFill()
            context.fill(self.borders[right])
            
//            UIColor.magenta.withAlphaComponent(0.4).setFill()
//            context.fill(self.nucleus)
//
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-thin", size: CGFloat(font_size))!, NSAttributedStringKey.paragraphStyle: paragraphStyle]
            let message = self.text
            message.draw(with: self.nucleus, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        
        self.plane = SCNPlane(width: CGFloat(total_width * self.scale), height: CGFloat(total_height * self.scale))
        self.plane.firstMaterial?.diffuse.contents = img
        self.rootNode.geometry = self.plane
        
        self.rootNode.position = SCNVector3Make((Float(layout["x"].doubleValue) + (total_width/2.0))*self.scale,
                                                (-Float(layout["y"].doubleValue) - (total_height/2.0))*self.scale,
                                                -1)
        
        print("Key: \(self.nodeKey)")
        print("Text: \(self.text)")
        print("totalWidth: \(total_width), \(total_width * self.scale)")
        print("totalheight: \(total_height), \(total_height * self.scale)")
        print("Nucleus: \(self.nucleus)")
        print("Border left: \(self.self.borders[left])")
        print("Border right: \(self.self.borders[right])")
        print("Border top: \(self.self.borders[top])")
        print("Border bottom: \(self.self.borders[bottom])")
        print("Position: \(self.rootNode.position)")
        print("===========================================")
        
    }

}








// end
