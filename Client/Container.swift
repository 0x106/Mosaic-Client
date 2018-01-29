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
        
        var totalWidth = (computedStyle["border-left-width"] as! Float)
            totalWidth += (computedStyle["border-right-width"] as! Float)
            totalWidth += (computedStyle["padding-left"] as! Float)
            totalWidth += (computedStyle["padding-right"] as! Float)
            totalWidth += Float(layout["width"].doubleValue)
        
        var totalHeight = (computedStyle["border-top-width"] as! Float)
            totalHeight += (computedStyle["border-bottom-width"] as! Float)
            totalHeight += (computedStyle["padding-top"] as! Float)
            totalHeight += (computedStyle["padding-bottom"] as! Float)
            totalHeight += Float(layout["height"].doubleValue)
        
        print("totalWidth: \(totalWidth), \(totalWidth * self.scale)")
        print("totalheight: \(totalHeight), \(totalHeight * self.scale)")
        
        self.cell = CGRect(x: CGFloat(0.0),
                          y: CGFloat(0.0),
                          width: CGFloat(totalWidth),
                          height: CGFloat(totalHeight))
        
        self.nucleus = CGRect(x: CGFloat((computedStyle["border-left-width"] as! Float) + (computedStyle["padding-left"] as! Float)),
                              y: CGFloat((computedStyle["border-bottom-width"] as! Float) + (computedStyle["padding-bottom"] as! Float)),
                              width: CGFloat(Float(layout["width"].doubleValue)),
                              height: CGFloat(Float(layout["height"].doubleValue)))
        
        self.borders[bottom] = CGRect(x: CGFloat(computedStyle["border-left-width"] as! Float),
                                      y: CGFloat(0.0),
                                      width: CGFloat(Float(layout["width"].doubleValue) + (computedStyle["padding-left"] as! Float) + (computedStyle["padding-right"] as! Float)),
                                      height: CGFloat(computedStyle["border-bottom-width"] as! Float))
        
        self.borders[top] = CGRect(x: CGFloat(computedStyle["border-left-width"] as! Float),
                                      y: self.nucleus.maxY + CGFloat(computedStyle["padding-top"] as! Float),
                                      width: CGFloat(Float(layout["width"].doubleValue) + (computedStyle["padding-left"] as! Float) + (computedStyle["padding-right"] as! Float)),
                                      height: CGFloat(computedStyle["border-top-width"] as! Float))
        
        self.borders[left] = CGRect(x: CGFloat(0.0),
                                    y: CGFloat(computedStyle["border-bottom-width"] as! Float),
                                    width: CGFloat(computedStyle["border-left-width"] as! Float),
                                    height: CGFloat(Float(layout["height"].doubleValue) + (computedStyle["padding-top"] as! Float) + (computedStyle["padding-bottom"] as! Float)))

        
        self.borders[right] = CGRect(x: self.nucleus.maxX + CGFloat((computedStyle["padding-right"] as! Float) + (computedStyle["padding-left"] as! Float)),
                                     y: CGFloat(computedStyle["border-bottom-width"] as! Float),
                                     width: CGFloat(computedStyle["border-right-width"] as! Float),
                                     height: CGFloat(Float(layout["height"].doubleValue) + (computedStyle["padding-top"] as! Float) + (computedStyle["padding-bottom"] as! Float)))
        
        print("Nucleus: \(self.nucleus)")
        print("Border left: \(self.self.borders[left])")
        print("Border right: \(self.self.borders[right])")
        print("Border top: \(self.self.borders[top])")
        print("Border bottom: \(self.self.borders[bottom])")
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(totalWidth), height: CGFloat(totalHeight)))
        let img = renderer.image { context in
            
            UIColor.red.setFill()
            context.fill(self.borders[top])
            
            UIColor.green.setFill()
            context.fill(self.borders[bottom])
//
            UIColor.blue.setFill()
            context.fill(self.borders[left])

            UIColor.magenta.setFill()
            context.fill(self.borders[right])
            
            UIColor.orange.setFill()
            context.fill(self.nucleus)
            
//            UIColor.cyan.setFill()
//            context.fill(self.cell)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Thin", size: CGFloat(computedStyle["font-size"] as! Float))!, NSAttributedStringKey.paragraphStyle: paragraphStyle]
            let string = self.text
            string.draw(with: self.nucleus, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        
        self.plane = SCNPlane(width: CGFloat(totalWidth * self.scale), height: CGFloat(totalHeight * self.scale))
        self.plane.firstMaterial?.diffuse.contents = img
        self.rootNode.geometry = self.plane
        
//        self.rootNode.position = SCNVector3Make((Float(layout["x"].doubleValue) + (totalWidth/2.0))*self.scale,
//                                                (-Float(layout["y"].doubleValue) - (totalHeight/2.0))*self.scale,
//                                                -1)
        
        self.rootNode.position = SCNVector3Make(0, 0, -1)
        
    }

}











//= CGRect(x: CGFloat(),
//y: CGFloat(),
//width: CGFloat(),
//height: CGFloat())





// end
