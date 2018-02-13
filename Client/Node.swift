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
import AlamofireImage
import Alamofire

private let top = 0
private let left = 1
private let right = 2
private let bottom = 3

private let wa = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(0.0))
private let wb = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(1.0))
private let wc = UIColor(red: 0, green: 0, blue: 0)

private enum nodeType {
    case TEXT
    case P
    case A
    case INPUT
    case LI
    case UL
    case OL
    case DIV
    case BODY
    case TABLE
    case TR
    case TD
}

class Label {
    
    var text: String = ""
    
    // AR properties
    var rootNode: SCNNode = SCNNode()
    var geometry: SCNGeometry?
    var x: Float = 0.0
    var y: Float = 0.0
    var totalWidth: Float = 0.0
    var totalHeight: Float = 0.0
    let scale: Float = 0.001
    
    var borderSize: [Float] = [0.0, 0.0, 0.0, 0.0]
    var border: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    
    // display properties
    var cell: CGRect = CGRect()
    var nucleus: CGRect = CGRect()
    var image: UIImage?
    
    var font: UIFont = UIFont()
    var font_size: Float = 0.0
    var font_weight: Float = 0.0
    
    var color: UIColor = UIColor()
    var backgroundColor: UIColor = UIColor()
    var borderColor: [UIColor] = [UIColor(), UIColor(), UIColor(), UIColor()]
    
    var canRender: Bool = true
    var canDrawOverlay: Bool = true
    var textAlignment: String = "left"
    
    init() {
        for idx in 0...3 {
            self.border[idx] = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        for idx in 0...3 {
            self.borderColor[idx] = UIColor.white.withAlphaComponent(CGFloat(0.0))
        }
        
        self.color = UIColor.black.withAlphaComponent(CGFloat(1.0))
    }
    
    func render() -> Bool {
        
        // if the image is / will be drawn then we don't need to render anything
        if !self.canDrawOverlay {return true}
        
        let paragraphStyle = NSMutableParagraphStyle()
        if self.textAlignment == "left" { paragraphStyle.alignment = .left }
        if self.textAlignment == "center" { paragraphStyle.alignment = .center }
        
        let fontAttrs: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.font: self.font as UIFont,
             NSAttributedStringKey.paragraphStyle: paragraphStyle,
             NSAttributedStringKey.foregroundColor: self.color]
        
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
            
            if self.textAlignment == "center" {
                let stringSize = self.text.size(withAttributes: fontAttrs)
                let drawRect = CGRect(x: CGFloat((self.nucleus.width / 2.0) - (stringSize.width/2.0)),
                                      y: CGFloat((self.nucleus.height / 2.0) - (stringSize.height/2.0)),
                                      width: CGFloat(stringSize.width),
                                      height: CGFloat(stringSize.height))
                self.text.draw(with: drawRect, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
            } else {
                self.text.draw(with: self.nucleus, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
            }
            
            
        }
        
        self.geometry = SCNPlane(width: CGFloat(self.totalWidth * self.scale), height: CGFloat(self.totalHeight * self.scale))
        self.geometry?.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.geometry
        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true
        
        return true
    }
    
    func setFont(_ selectedFont: String, _ size: Float) {
        self.font = UIFont(name: selectedFont, size: CGFloat(size))!
    }
}

class Node {
    
    var key: String = ""
    var nodeValue: String = ""
    var nodeName: String = ""
    var treeDepth: Int = 0
    
    var config: Dictionary<String, Any>?
    var configID: String?

    var text: String = ""
    var href: String = ""
    var imageURL: String = ""
    var requestURL: String = ""
    var children: [String]?
    var parents: [String]?
    var attr: [ Dictionary<String, String> ]?
    var style: [ Dictionary<String, Any> ]?
    
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

    var inputField: UITextField?        //: Dictionary<String, UITextField> = Dictionary<String, UITextField>()
    
    // false if the node won't be created
    // true if it's fine to render & use this node
    var canRender: Bool = true

    // false if we shouldn't draw any properties to the image (but the node and image should exist)
    // true if we should render this node
    var canDrawOverlay: Bool = true

    var isActive: Bool = false
    
    var isButton: Bool = false
    var canReceiveUserInput: Bool = false
    
    var isAFrameNode: Bool = false
    
    init() {}
    
    init?(_ _data: Dictionary<String, Any>,
          _ _requestURL: String,
          _ _depth: Int) {
        
        self.commonInit(_data, _requestURL, _depth)
        
        self.text = checkText(self.nodeValue)
        let _ = self.setup()
        return
    }
    
    func commonInit(_ _data: Dictionary<String, Any>,
                    _ _requestURL: String,
                    _ _depth: Int) {
        self.key = _data["key"] as! String
        self.nodeName = _data["nodeName"] as! String
        self.nodeValue = _data["nodeValue"] as! String
        self.rootNode.name = self.key
        self.treeDepth = _depth
        self.requestURL = _requestURL
//        self.children = _data["nodeChildren"] as! [String]
//        self.parents = _data["pkey"] as! [String]
        
        if let _attr = _data["attr"] as? [Dictionary<String, String>] {
            self.attr = _attr
        }
        if let _style = _data["nodeStyle"] as? [Dictionary<String, Any>] {
            self.style = _style
        }
        
        self.treeDepth = _data["depth"] as! Int
        
        var tempLayout = _data["nodeLayout"] as! Dictionary<String, Any>
        self.x = tempLayout["x"] as! Float
        self.y = tempLayout["y"] as! Float
        self.totalWidth = tempLayout["width"] as! Float
        self.totalHeight = tempLayout["height"] as! Float
        
        print("Node: \(self.key)")
        
        if let id = self.getConfigID() {
            print("Config id: \(id)")
            self.configID = id
            if let retrievedConfig = getConfigVar(forKey: id) {
                print("Config: \(retrievedConfig)")
                self.config = retrievedConfig
                if let isVisible = self.config!["isVisible"] as? Bool {
                    if !isVisible { self.canRender = false }
                }
            }
        }
    }
    
    func setup() -> Bool {
        
        self.determineType()
        if !self.canRender {
            if self.nodeName == "IMG" {
                print("Cannot render IMG due to: type")
            }
            return false
        }
    
        self.determineProperties()
        if !self.canRender {
            if self.nodeName == "IMG" {
                print("Cannot render IMG due to: property")
            }
            return false
        }
    
        self.hasStyle()
        if !self.canRender {
            if self.nodeName == "IMG" {
                print("Cannot render IMG due to: style")
            }
            return false
        }
        
        self.determineLayout()
        if !self.canRender {
            if self.nodeName == "IMG" {
                print("Cannot render IMG due to: layout")
            }
            return false
        }
        
        self.determineFont()

        return true
    }
    
    func render() -> Bool {
        
        // if the image is / will be drawn then we don't need to render anything
        if !self.canDrawOverlay || self.isAFrameNode {return true}
        
        self.applyConfig()
        
        if self.nodeName == "#text" {

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let fontAttrs: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: self.font as UIFont,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle,
                 NSAttributedStringKey.foregroundColor: self.color]

            let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(self.totalWidth), height: CGFloat(self.totalHeight)))
            self.image = renderer.image { context in
                self.text.draw(with: self.cell, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
            }
            
        } else if self.canReceiveUserInput {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let fontAttrs: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: self.font as UIFont,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle,
                 NSAttributedStringKey.foregroundColor: self.color]
            
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
                
                self.text.draw(with: self.cell, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
            }
            
        } else {

            // TODO: Rounded corners
            // https://stackoverflow.com/questions/30368739/how-to-draw-a-simple-rounded-rect-in-swift-rounded-corners

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

        self.geometry = SCNPlane(width: CGFloat(self.totalWidth * self.scale), height: CGFloat(self.totalHeight * self.scale))
        self.geometry?.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.geometry
        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true

        return true
    }
    
    func applyConfig() {
        // if there was config applied to this node
        if let cf = self.config {
            
            // if the background-color property was changed
            if let bgColor = cf["background-color"] as? [Int] {
                self.backgroundColor = UIColor(red: bgColor[0], green: bgColor[1], blue: bgColor[2])
            }
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
    
    func _print() {
        print( "Node [\(self.treeDepth)]: \(self.key)" )
    }
    
    func getAttribute(_ query: String) -> String? {
        
        guard let attributes = self.attr else {return nil}
        for attribute in attributes {
            if query == attribute["name"] { return attribute["value"] }
        }
        return nil
    }
    
    func getFontAttribute(_ query: String) -> Dictionary<String, Any>? {
        guard let attributes = self.style else {return nil}
        for attribute in attributes {
            if query == (attribute["name"] as! String) {
                return attribute["value"] as? Dictionary<String, Any>
            }
        }
        return nil
    }
    
    func getConfigID() -> String? {
        guard let attributes = self.attr else {return nil}
        for attribute in attributes {
            if let attrExists = attribute["name"]?.hasPrefix("-data-atlas") {
                if attrExists {
                    let result = attribute["name"]?.replacingOccurrences(of: "-data-atlas", with: "")
                    return result
                }
            }
        }
        return nil
    }
    
    // if the original string is ONLY composed of whitespace and new lines then return an empty string,
    // otherwise return the original
    private func checkText(_ value: String) -> String {
        
//        .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let checkOnlyWhiteSpaceNewLines: String = String(value).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        if checkOnlyWhiteSpaceNewLines == "" {
            return ""
        }
        
        let trim: String = String(value).trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trim
    }
    
    private func hasStyle() {
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
    
    func determineProperties() {
        
        guard let currentStyle = self.style else {
            self.canRender = false
            return
        }
        
        if currentStyle.count > 1 {
            
            if let style = computeStylesFromDict() {
                self.computedStyle = style
                self.font_size = self.computedStyle["font-size"] as! Float - 2.0

                self.color = self.computedStyle["color"] as! UIColor
                
                if let cf = self.config {
                    if let bgColor = cf["background-color"] as? [Int] {
                        self.backgroundColor = UIColor(red: bgColor[0], green: bgColor[1], blue: bgColor[2])
                    } else {self.backgroundColor = self.computedStyle["background-color"] as! UIColor}
                } else {self.backgroundColor = self.computedStyle["background-color"] as! UIColor}
                
                self.borderColor[top] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[left] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[right] = self.computedStyle["border-top-color"] as! UIColor
                self.borderColor[bottom] = self.computedStyle["border-top-color"] as! UIColor
                if self.nodeName == "IMG" {
                    self.canDrawOverlay = false
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
    
    func determineLayout() {

        if self.x < 0 || self.y < 0 {
            self.canRender = false
            return
        }
        
        if (self.totalWidth == 0 || self.totalHeight == 0 || self.totalWidth > 1000 || self.totalHeight > 1000) {
            self.canRender = false
            return
        }

        self.rootNode.position = SCNVector3Make(   (self.x + (self.totalWidth/2.0)) * self.scale,
                                                   -(self.y + (self.totalHeight/2.0)) * self.scale,
                                                   -Float(6 - self.treeDepth)*self.scale)
        
        if let cf = self.config {
            if let position = cf["position"] as? SCNVector3 {
                self.rootNode.position.x += position.x * self.scale
                self.rootNode.position.y += position.y * self.scale
                self.rootNode.position.z += position.z * self.scale
            }
            
            if let rotation = cf["rotation"] as? SCNVector3 {
                self.rootNode.eulerAngles.x += rotation.x
                self.rootNode.eulerAngles.y += rotation.y
                self.rootNode.eulerAngles.z += rotation.z
            }
            
            if let scale = cf["scale"] as? SCNVector3 {
                self.rootNode.scale.x = scale.x
                self.rootNode.scale.y = scale.y
                self.rootNode.scale.z = scale.z
            }
        }
        
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
    }
    
    func loadImage() {
        if self.imageURL != "" {
        
            self.geometry = SCNPlane(width: CGFloat(self.totalWidth*self.scale), height: CGFloat(self.totalHeight*self.scale))
            self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(CGFloat(0.2)) // temporary placeholder

            DataRequest.addAcceptableImageContentTypes(["image/jpg"])
            Alamofire.request(self.imageURL).responseImage { response in
                if let image = response.result.value {
                    self.image = image
                    self.geometry?.firstMaterial?.diffuse.contents = self.image
                }
            }

            // indicates that we'll load something into the image so don't render anything to it
            self.canDrawOverlay = false
            self.geometry?.firstMaterial?.isDoubleSided = true
            self.rootNode.geometry = self.geometry
        }
    }
    
    func parseColorString(_ input: String) -> UIColor {
        // default color
        var output: UIColor = palatinatePurple
        
        let text = input.replacingOccurrences(of: ",", with: "")
        
        let startIndex = text.index(of: "(") ?? input.endIndex
        let endIndex = text.index(of: ")") ?? input.endIndex
        
        let pre = (text[startIndex..<endIndex])
        let desc = pre.suffix(pre.count-1)
        
        let values = desc.split(separator: " ")
        
        if input.hasPrefix("rgba") {
            //        print("-----> \(values)")
            output = UIColor(red: Int(values[0])!, green: Int(values[1])!, blue: Int(values[2])!).withAlphaComponent(CGFloat(Float(values[3])!))
        } else if input.hasPrefix("rgb") {
            output = UIColor(red: Int(values[0])!, green: Int(values[1])!, blue: Int(values[2])!).withAlphaComponent(CGFloat(1.0))
        } else {
        }
        
        //    print("Computed color: \(output)")
        return output
    }
    
    // e.g. "2px" --> 2.0
    func parseSizeString(_ input: String) -> Float {
        if input.hasSuffix("px") {
            let index = input.index(of: "p") ?? input.startIndex
            let output: Float = Float(input.prefix(upTo: index)) ?? 0.0
            return output
        }
        return 0.0
    }
    
    func computeStylesFromDict() -> Dictionary<String, Any>? {
        var computedStyle: Dictionary<String, Any> = [:]
        guard let currentStyle = self.style else {return nil}
        for item in currentStyle {

            let propertyName = item["name"] as! String
            
            if propertyName != "googleFonts" {
                let propertyValue = item["value"] as! String

                if propertyName.hasSuffix("color") {
                    computedStyle[propertyName] = self.parseColorString(propertyValue)
                } else if propertyName.hasSuffix("width") || propertyName.hasSuffix("size") || propertyName.hasPrefix("padding") {
                    computedStyle[propertyName] = self.parseSizeString(propertyValue)
                } else {    // presumably anything that makes it in here has a string propertyvalue (or at least a known type)
                    computedStyle[propertyName] = propertyValue
                }
            }
        }
        
        if computedStyle.isEmpty {return nil}
        return computedStyle
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
    
    func setActive() {
        
        let scaleChange: Float = 1.1
        let motionChange: Float = 0.4
        let duration: Double = 0.6
        if self.isActive {
            
            let forwardVector = SCNVector3Make(0, 0, -motionChange)
            
            let motion = SCNAction.move(by: forwardVector, duration: duration)
            let scale = SCNAction.scale(by: CGFloat(1.0 / scaleChange), duration: duration)
            
            self.rootNode.runAction(SCNAction.group([motion, scale]))
            
            self.isActive = false
            
        } else {
            let forwardVector = SCNVector3Make(0, 0, motionChange)
            
            let motion = SCNAction.move(by: forwardVector, duration: duration)
            let scale = SCNAction.scale(by: CGFloat(scaleChange), duration: duration)
            
            self.rootNode.runAction(SCNAction.group([motion, scale]))
            self.isActive = true
        }
    }
    
    @objc func updateUserInput(_ textField: UITextField) {
        self.text = textField.text!
        print("Updated node text: \(self.text)")
        let _ = self.render()
    }
    
    func addNewTextField(_ key: String) -> UITextField? {
        self.inputField = UITextField()
        self.inputField!.addTarget(self, action: #selector( self.updateUserInput(_:) ), for: .editingChanged)
        self.inputField!.autocapitalizationType = UITextAutocapitalizationType.none;
        self.inputField!.becomeFirstResponder()
        return self.inputField
    }
    
    func removeTextField(_ key: String) {
        guard let field = self.inputField else {return}
        field.resignFirstResponder()
        self.inputField = nil
    }
    
}

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
    
    override init?(_ _data: Dictionary<String, Any>,
                  _ _requestURL: String,
                  _ _depth: Int) {
        
        position = SCNVector3Make(0.0, 0.0, 0.0)
        rotation = SCNVector3Make(0.0, 0.0, 0.0)
        
        super.init()
        
        self.isAFrameNode = true
        
        self.commonInit(_data, _requestURL, _depth)
        
        self.initialise()
        
        print(_data)
        
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
            print("\(self.key) \(self.rotation)")
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





