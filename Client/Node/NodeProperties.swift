//
//  NodeProperties.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

extension Node {
    func determineProperties() {
        
        //        guard let currentStyle = self.style else {
        //            self.canRender = false
        //            return
        //        }
        
        if self.style!.count > 1 {
            
            if let style = computeStylesFromDict() {
                self.computedStyle = style
                self.font_size = self.computedStyle["font-size"] as! Float - 3.0
                
                self.color = self.computedStyle["color"] as! UIColor
                self.backgroundColor = self.computedStyle["background-color"] as! UIColor
                self.borderColor[top] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[left] = self.computedStyle["border-left-color"] as! UIColor
                self.borderColor[right] = self.computedStyle["border-right-color"] as! UIColor
                self.borderColor[bottom] = self.computedStyle["border-bottom-color"] as! UIColor
                
                if let cf = self.config {
                    
                    self.checkConfigStyleProperties(cf)
                    
                    // does this node have a model associated with it?
                    if let filenameString = cf["filename"] as? String {
                        
                        // load the default model
                        if self.model.loadModel(filenameString) {
                            self.rootNode.addChildNode(self.model.rootNode)
                            self.forceRender = true
                        }
                    }
                    
                }
                
                if self.nodeName == "IMG" {
                    if let src = getAttribute("src") {
                        if src.hasPrefix("http") || src.hasPrefix("www") {
                            self.imageURL = src
                        } else if (src.hasPrefix("//")) {
                            
                            self.imageURL = "http:" + src
                            
                        } else {
                            self.imageURL = self.requestURL + src
                            print("No prefix: \(self.imageURL)")
                        }
                        self.loadImage()
                    }
                }
                
                let bgImage = self.computedStyle["background-image"] as! String
                if bgImage != "none" {
                    self.canDrawOverlay = false
                    if bgImage.hasPrefix("url") {
                        self.imageURL = parseHREFFromURL(bgImage)
                        if !self.imageURL.hasPrefix("data") {
                            self.loadImage()
                        }
                    }
                }
            }
            else {
                self.canRender = false
                return
            }
        } else {
            self.canRender = false
            return
        }
    }
    
    func checkConfigStyleProperties(_ cf: Dictionary<String, Any>) {
        if let bgColorString = cf["background-color"] as? String {
            let bgColorValues = extractValuesFromCSV(bgColorString)
            if bgColorValues.count == 3 {
                self.backgroundColor = UIColor(red: Int(bgColorValues[0]), green: Int(bgColorValues[1]), blue: Int(bgColorValues[2]))
            } else if bgColorValues.count == 4 {
                self.backgroundColor = UIColor(red: Int(bgColorValues[0]), green: Int(bgColorValues[1]), blue: Int(bgColorValues[2])).withAlphaComponent(CGFloat(bgColorValues[3]))
            } else {}
        }
        
        if let colorString = cf["color"] as? String {
            let colorValues = extractValuesFromCSV(colorString)
            if colorValues.count == 3 {
                self.color = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2]))
            } else if colorValues.count == 4 {
                self.color = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2])).withAlphaComponent(CGFloat(colorValues[3]))
            } else {}
        }
        
        if let borderTopColorString = cf["border-top-color"] as? String {
            let colorValues = extractValuesFromCSV(borderTopColorString)
            if colorValues.count == 3 {
                self.borderColor[top] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2]))
            } else if colorValues.count == 4 {
                self.borderColor[top] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2])).withAlphaComponent(CGFloat(colorValues[3]))
            } else {}
        }
        
        if let borderLeftColorString = cf["border-left-color"] as? String {
            let colorValues = extractValuesFromCSV(borderLeftColorString)
            if colorValues.count == 3 {
                self.borderColor[left] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2]))
            } else if colorValues.count == 4 {
                self.borderColor[left] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2])).withAlphaComponent(CGFloat(colorValues[3]))
            } else {}
        }
        
        if let borderRightColorString = cf["border-right-color"] as? String {
            let colorValues = extractValuesFromCSV(borderRightColorString)
            if colorValues.count == 3 {
                self.borderColor[right] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2]))
            } else if colorValues.count == 4 {
                self.borderColor[right] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2])).withAlphaComponent(CGFloat(colorValues[3]))
            } else {}
        }
        
        if let borderBottomColorString = cf["border-bottom-color"] as? String {
            let colorValues = extractValuesFromCSV(borderBottomColorString)
            if colorValues.count == 3 {
                self.borderColor[bottom] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2]))
            } else if colorValues.count == 4 {
                self.borderColor[bottom] = UIColor(red: Int(colorValues[0]), green: Int(colorValues[1]), blue: Int(colorValues[2])).withAlphaComponent(CGFloat(colorValues[3]))
            } else {}
        }
    }
    
    // screen for nodes that we won't render
    // Perform type specific behaviour (i.e extract href from A tags)
    func determineType() {
        if self.nodeName == "#document"
            || self.nodeName == "HTML"
            || self.nodeName == "IFRAME"
            || self.nodeName == "BODY"
            || (self.nodeName == "#text" && self.text == ""){
            self.canRender = false
            return
        }
        
        if self.nodeName == "A" {
            self.isButton = true
            
            // get the href
            if let hyperlink = getAttribute("href") {
                self.isButton = true
                self.href = hyperlink
            }
        }
        
        if self.nodeName == "INPUT" {
            self.canReceiveUserInput = true
            
            // this is the only non-text node that has its text value set.
            // TODO / BUG: If there is a default value on the input then it
            //              is plausible that this is already included as a
            //              #text node and would then be rendered twice.
            self.text = checkText(self.nodeValue)
        }
    }
    
    func hasStyle() {
        if !(self.nodeName == "IMG") && self.computedStyle["background-image"] as! String == "none"
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
    
    func determineLayout() {
        
        if self.x < 0 || self.y < 0 {
            self.canRender = false
            return
        }
        
        if (self.totalWidth == 0 || self.totalHeight == 0 || self.totalWidth > 5000 || self.totalHeight > 5000) {
            self.canRender = false
            return
        }
        
        // if the node is a div + model then don't shift
        // if self.nodeName == "DIV" && self.model.hasModel {
        // } else {
        self.rootNode.position = SCNVector3Make(   (self.x + (self.totalWidth/2.0)) * self.scale,
                                                   -(self.y + (self.totalHeight/2.0)) * self.scale,
                                                   -Float(6 - self.treeDepth)*self.scale)
        // }
        
        self.borderSize[top] = computedStyle["border-top-width"] as! Float
        self.borderSize[left] = computedStyle["border-left-width"] as! Float
        self.borderSize[right] = computedStyle["border-right-width"] as! Float
        self.borderSize[bottom] = computedStyle["border-bottom-width"] as! Float
        
        if let cf = self.config {
            self.checkConfigLayout(cf)
        }
        
        // if the border size is _bigger_
        //      - grow the height/width by the difference
        //      - keep the origin in the same place
        //      - effect: keeps inner edge fixed
        //      - should be same for _smaller_
        
        self.cell = CGRect( x: CGFloat(0.0),
                            y: CGFloat(0.0),
                            width: CGFloat(self.totalWidth),
                            height: CGFloat(self.totalHeight))
        
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
    }
    
    func checkConfigLayout(_ cf: Dictionary<String, Any>) {
        if let positionString = cf["position"] as? String {
            let position = extractValuesFromCSV(positionString)
            self.rootNode.position.x += position[0] * self.scale
            self.rootNode.position.y += position[1] * self.scale
            self.rootNode.position.z += position[2] * self.scale
        }
        
        if let rotationString = cf["rotation"] as? String {
            let rotation = extractValuesFromCSV(rotationString)
            self.rootNode.eulerAngles.x += rotation[0]
            self.rootNode.eulerAngles.y += rotation[1]
            self.rootNode.eulerAngles.z += rotation[2]
        }
        
        if let scaleString = cf["scale"] as? String {
            let scale = extractValuesFromCSV(scaleString)
            self.rootNode.scale.x = scale[0]
            self.rootNode.scale.y = scale[1]
            self.rootNode.scale.z = scale[2]
        }
        
        if let borderTopSizeString = cf["border-top-width"] as? String {
            let value = extractValuesFromCSV(borderTopSizeString)[0]
            self.totalHeight += value - self.borderSize[top]
            if self.totalHeight < 0.0 {
                self.totalHeight = 0.0
            }
            self.borderSize[top] = value
        }
        
        if let borderLeftSizeString = cf["border-left-width"] as? String {
            let value = extractValuesFromCSV(borderLeftSizeString)[0]
            self.totalWidth += value - self.borderSize[left]
            if self.totalWidth < 0.0 {
                self.totalWidth = 0.0
            }
            self.borderSize[left] = value
        }
        
        if let borderRightSizeString = cf["border-right-width"] as? String {
            let value = extractValuesFromCSV(borderRightSizeString)[0]
            self.totalWidth += value - self.borderSize[right]
            if self.totalWidth < 0.0 {
                self.totalWidth = 0.0
            }
            self.borderSize[right] = value
        }
        
        if let borderBottomSizeString = cf["border-bottom-width"] as? String {
            let value = extractValuesFromCSV(borderBottomSizeString)[0]
            self.totalHeight += value - self.borderSize[bottom]
            if self.totalHeight < 0.0 {
                self.totalHeight = 0.0
            }
            self.borderSize[bottom] = value
        }
    }
    
    func determineFont() {
        
        let font_list = (self.computedStyle["font-family"] as! String).replacingOccurrences(of: ",", with: "").split(separator: " ")
        let googleFonts = self.getFontAttribute("googleFonts")
        
        for ft in font_list {
            if var gf = googleFonts![String(ft)] {
                var googft = gf as! Dictionary<String, String>
                self.fonts.append( AtlasFont(String(ft), googft["url"]!, googft["weight"]!, self.font_size) )
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
}
