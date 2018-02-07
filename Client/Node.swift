//
//  Node.swift
//  Client
//
//  Created by Jordan Campbell on 7/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

private let top = 0
private let left = 1
private let right = 2
private let bottom = 3

private let wa = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(0.0))
private let wb = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(1.0))
private let wc = UIColor(red: 0, green: 0, blue: 0)

class Node {
    
    // all the necessary data for the node
    var data: JSON
    var key: String
    var children: [Node] = [Node]()
    var treeDepth: Int = 0
    var text: String = ""
    
    // AR properties
    var rootNode: SCNNode = SCNNode()
    var geometry: SCNGeometry?
    var x: Float = 0.0
    var y: Float = 0.0
    
    var totalWidth: Float = 0.0
    var totalHeight: Float = 0.0

    var borderSize: [Float] = [0.0, 0.0, 0.0, 0.0]
    var border: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    
    // display properties
    var cell: CGRect = CGRect()
    var image: UIImage?
    var computedStyle: Dictionary<String, Any> = Dictionary<String, Any>()
    let scale: Float = 0.001
    
    var fonts: [AtlasFont] = [AtlasFont]()
    var font: UIFont = UIFont()
    var defaultFont: UIFont = UIFont()
    var font_size: Float = 0.0
    var font_weight: Float = 0.0
    
    var color: UIColor = UIColor()
    var backgroundColor: UIColor = UIColor()
    var borderColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor()]
    
    var canRender: Bool = true
    
    init(_ _key: String,
         _ _data: JSON,
         _ _depth: Int) {
        
        self.data = _data
        self.key = _key
        self.rootNode.name = self.key
        self.treeDepth = _depth
    
        self.text = checkText(self.data["nodeValue"].stringValue)
        
    }
    
    private func checkText(_ value: String) -> String {
        var copy: String = String(value).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        if copy == "" {
            return copy
        }
        return value
    }
    
    private func hasStyle() {
        if self.computedStyle["background-image"] as! String == "none"
            && (self.backgroundColor.isEqual( wa ) || self.backgroundColor.isEqual( wb ) || self.backgroundColor.isEqual( wc ))
            && (self.borderColor[top].isEqual( wa ) || self.borderColor[top].isEqual( wb ) || self.borderColor[top].isEqual( wc ) || self.computedStyle["border-top-style"] as! String == "none")
            && (self.borderColor[left].isEqual( wa ) || self.borderColor[left].isEqual( wb ) || self.borderColor[left].isEqual( wc ) || self.computedStyle["border-left-style"] as! String == "none")
            && (self.borderColor[right].isEqual( wa ) || self.borderColor[right].isEqual( wb ) || self.borderColor[right].isEqual( wc ) || self.computedStyle["border-right-style"] as! String == "none")
            && (self.borderColor[bottom].isEqual( wa ) || self.borderColor[bottom].isEqual( wb ) || self.borderColor[bottom].isEqual( wc ) || self.computedStyle["border-bottom-style"] as! String == "none")
            && self.text == "" {
            self.canRender = false
            return
        }
    }
    
    func determineProperties() {
        // do this on a separate thread
        if self.data["nodeStyle"].exists() {
            if let style = computeStylesFromDict(self.data["nodeStyle"]) {
                
                self.computedStyle = style
                
                self.font_size = self.computedStyle["font-size"] as! Float - 2.0
                
                self.totalWidth = Float(self.data["nodeLayout"]["width"].doubleValue)
                self.totalHeight = Float(self.data["nodeLayout"]["height"].doubleValue)
                
                self.color = self.computedStyle["color"] as! UIColor
                self.backgroundColor = self.computedStyle["background-color"] as! UIColor
                
                self.borderColor[top] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[left] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[right] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[bottom] = self.computedStyle["border-top-color"] as! UIColor
            } else {
                self.canRender = false
                return
            }
        } else {
            self.canRender = false
            return
        }
    }
    
    func determineLayout() {
        
        let x = Float(self.data["nodeLayout"]["x"].doubleValue)
        let y = Float(self.data["nodeLayout"]["y"].doubleValue)
     
        if x <= 0 || y <= 0 {
            self.canRender = false
            return
        }
    
        self.rootNode.position = SCNVector3Make(   (x + (self.totalWidth/2.0)) * self.scale,
                                                   -(y + (self.totalHeight/2.0)) * self.scale,
                                                   -Float(6 - self.treeDepth)*self.scale)
        
        self.borderSize[top] = computedStyle["border-top-width"] as! Float
        self.borderSize[left] = computedStyle["border-left-width"] as! Float
        self.borderSize[right] = computedStyle["border-right-width"] as! Float
        self.borderSize[bottom] = computedStyle["border-bottom-width"] as! Float
        
        self.border[top] = CGRect(x: CGFloat(0.0),
                                  y: CGFloat(0.0),
                                  width: CGFloat(self.totalWidth),
                                  height: CGFloat(self.borderSize[top]))
        self.border[left] = CGRect(x: CGFloat(0.0),
                                  y: CGFloat(0.0),
                                  width: CGFloat(self.borderSize[left]),
                                  height: CGFloat(self.totalHeight))
        self.border[right] = CGRect(x: CGFloat(self.totalWidth - self.borderSize[right]),
                                  y: CGFloat(0.0),
                                  width: CGFloat(self.borderSize[right]),
                                  height: CGFloat(self.totalHeight))
        self.border[bottom] = CGRect(x: CGFloat(0.0),
                                  y: CGFloat(self.totalHeight - self.borderSize[bottom]),
                                  width: CGFloat(self.totalWidth),
                                  height: CGFloat(self.borderSize[bottom]))
        
        self.cell = CGRect(x: CGFloat(0.0),
                           y: CGFloat(0.0),
                           width: CGFloat(self.totalWidth),
                           height: CGFloat(self.totalHeight))
    }
    
    func determineType() {
        if self.data["nodeName"] == "#document"
            || self.data["nodeName"] == "HTML"
            || self.data["nodeName"] == "IFRAME"
            || self.data["nodeName"] == "BODY" {
            self.canRender = false
            return
        }
    }
    
    func determineFont() {
        
        let font_list = (self.computedStyle["font-family"] as! String).replacingOccurrences(of: ",", with: "").split(separator: " ")
        let googleFonts = getAttribute(self.data["nodeStyle"], "googleFonts")

        for ft in font_list {
            if var gf = hasAttribute(googleFonts!, String(ft)) {
                self.fonts.append( AtlasFont(String(ft), gf["url"].stringValue, gf["weight"].stringValue, self.font_size) )
            } else {
                self.fonts.append( AtlasFont(String(ft), "", "", self.font_size) )
            }
        }

        // find the font or use whatever is passed in as the default
        self.setFont("HelveticaNeue", 10.0)
    }
    
    func setFont(_ selectedFont: String, _ size: Float) {
        
        if selectedFont != "" {
            self.defaultFont = UIFont(name: selectedFont, size: CGFloat(size))!
        }
        
        var fontIsSet: Bool = false
        for possibleFont in self.fonts {
            if possibleFont.isAvailable {
                self.font = possibleFont.font
                fontIsSet = true
                break
            }
        }
        if !fontIsSet { self.font = self.defaultFont }
    }
    
    func render() -> Bool {
        
        determineType()             ;if !self.canRender {return false}
        determineProperties()       ;if !self.canRender {return false}
        hasStyle()                  ;if !self.canRender {return false}
        determineLayout()           
        determineFont()
        
        if self.data["nodeName"] == "#text" {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let fontAttrs: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: self.font as UIFont,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle,
                 NSAttributedStringKey.foregroundColor: self.color]//,
            //   NSAttributedStringKey.kern: self.characterSpacing]
                    
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(self.totalWidth), height: CGFloat(self.totalHeight)))
            self.image = renderer.image { context in
                self.text.draw(with: self.cell, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
            }
            
        } else {
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(self.totalWidth), height: CGFloat(self.totalHeight)))
            self.image = renderer.image { context in
                
                self.backgroundColor.setFill()
                context.fill(self.cell)
                
                self.borderColor[top].setFill()
                context.fill(self.border[top])
                
                self.borderColor[left].setFill()
                context.fill(self.border[left])
                
                self.borderColor[right].setFill()
                context.fill(self.border[right])
                
                self.borderColor[bottom].setFill()
                context.fill(self.border[bottom])
            }
        }
        
//        self.geometry = SCNPlane(width: CGFloat(self.totalWidth * self.scale), height: CGFloat(self.totalHeight * self.scale))
//        self.geometry?.firstMaterial?.diffuse.contents = self.image
//        self.rootNode.geometry = self.geometry
//        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true
//        
        return true
    }
    
    func childrenKeys() -> JSON {
        return self.data["nodeChildren"]
    }
    
    func _print() {
//        if self.key.hasPrefix("#text") {
        print( "Node [\(self.treeDepth)]: \(self.key)" )
//        }
    }
    
    func addChild(_ _child: Node) {
//        self.children.append(_child)
    }
    
    func determineComputedStyles() {
        
    }
}
