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
import Alamofire
import AlamofireImage

class Container {
    
    var cell: CGRect = CGRect()
    var nucleus: CGRect   = CGRect()
    var borders: [CGRect] = [CGRect(), CGRect(), CGRect(), CGRect()]
    
    var nucleus_height:         Float = 0.0
    var nucleus_width:          Float = 0.0
    var x:                      Float = 0.0
    var y:                      Float = 0.0
    var z:                      Float = 0.0
    
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
    var font_weight:            Float = 0.0
    
    var border_color:           UIColor = UIColor()
    var background_color:       UIColor = UIColor()
    var color:             UIColor = UIColor()
    
    var fonts:                  [AtlasFont] = [AtlasFont]()
    var font:                   UIFont = UIFont()
    var text: String = ""
    
    var isButton: Bool = false
    var href: String = ""
    
    var imageURL: String = ""
    var canDraw: Bool = true
    var isRendered: Bool = false
    var isBase64: Bool = false
    
    var rootNode: SCNNode = SCNNode()
    var nodeKey: String = ""
    var image: UIImage = UIImage()
    var plane: SCNPlane = SCNPlane()
    let scale: Float = 0.001
    
    let top     = 0
    let bottom  = 1
    let left    = 2
    let right   = 3
    
    init(){
        self.border_color = UIColor.white.withAlphaComponent(0.0)
        self.background_color = UIColor.white.withAlphaComponent(0.0)
        self.color = UIColor.white.withAlphaComponent(0.0)
    }
    
    init(_ text: String, _ isButton: Bool) {
    }

    init?(withName      containerType: String,
          withlabel     labelText: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        self.nodeKey = key
        self.rootNode.name = self.nodeKey
        let computedStyle = computeStylesFromDict(style)
        
        self.text = labelText
        
        // check if this is a link - if so then make this a button and add the href that it points to.
        self.extractLink(parent)
        
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
        self.color                   = (computedStyle["color"] as! UIColor)
        
        if let bgImage = getAttribute(style, "background-image"), bgImage.stringValue != "none" {
            self.canDraw = false // don't try and draw over top of images
            if bgImage.stringValue.hasPrefix("url") {
                self.imageURL = parseHREFFromURL(bgImage.stringValue)
                self.loadImage()
                
                self.plane = SCNPlane(width: CGFloat(self.nucleus_width*self.scale), height: CGFloat(self.nucleus_height*self.scale))
                self.plane.firstMaterial?.isDoubleSided = true
                self.rootNode.geometry = self.plane
                self.z = -1.01 - (Float(indexFromKey(key)) * self.scale * 0.1) + randomFloat(min: -0.01, max: 0.0)
            }
            
        } else {
            if self.text == "" {
                self.z = -1.01 - (Float(indexFromKey(key)) * self.scale * 0.1) + randomFloat(min: -0.01, max: 0.0)
            } else {
                self.z = -1
            }
            
            self.computeFonts(style)
        }
        
        self.determineLayout()
        self.rootNode.position = SCNVector3Make((   self.x + (self.total_width/2.0))*self.scale,
                                                (  -self.y - (self.total_height/2.0))*self.scale,
                                                self.z)
        
        // we 'hide' any nodes until they have been drawn etc
//        self.rootNode.isHidden = true
        self.rootNode.geometry?.firstMaterial?.transparency = CGFloat(0.2)
    }
    
    func draw() {
        
        // don't draw on image containers
        if !self.canDraw {
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attrs = [NSAttributedStringKey.font: self.font as UIFont,
                     NSAttributedStringKey.paragraphStyle: paragraphStyle,
                     NSAttributedStringKey.foregroundColor: self.color]
        
        let message = self.text
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(self.total_width), height: CGFloat(self.total_height)))
        self.image = renderer.image { context in

            self.background_color.setFill()
            context.fill(self.cell)

            self.border_color.setFill()
            for border in self.borders {
                context.fill(border)
            }

            message.draw(with: self.nucleus, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }

        self.plane = SCNPlane(width: CGFloat(self.total_width * self.scale), height: CGFloat(self.total_height * self.scale))
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.plane.firstMaterial?.isDoubleSided = true
        self.rootNode.geometry = self.plane
        self.rootNode.geometry?.firstMaterial?.transparency = CGFloat(1.0)
//        self.rootNode.isHidden = false
        self.isRendered = true
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
    
    }
    
    func loadImage() {
        if self.imageURL != "" {
            Alamofire.request(self.imageURL).responseImage { response in
                if let image = response.result.value {
                    self.image = image
                    self.plane.firstMaterial?.diffuse.contents = self.image
                    print("image added")
                }
            }
        }
    }
    
    func computeFonts(_ style: JSON) {
        let font_list = getAttribute(style, "font-family")?.stringValue.replacingOccurrences(of: ",", with: "").split(separator: " ")
        let googleFonts = getAttribute(style, "googleFonts")
        
        for ft in font_list! {
            if var gf = hasAttribute(googleFonts!, String(ft)) {
                self.fonts.append( AtlasFont(String(ft), gf["url"].stringValue, gf["weight"].stringValue, self.font_size) )
            } else {
                self.fonts.append( AtlasFont(String(ft), "", "", self.font_size) )
            }
        }
        
        var fontIsSet: Bool = false
        for possibleFont in self.fonts {
            if possibleFont.isAvailable {
                self.font = possibleFont.font
                fontIsSet = true
                break
            }
        }
        
        // if it doesn't use the Google Fonts API and if the specified fonts don't exist on iOS.
        if !fontIsSet { self.font = UIFont(name: "HelveticaNeue", size: CGFloat(self.font_size))! }
    }
    
    private func makeSphere(_ textSize: Float) -> SCNSphere {
        let sphere = SCNSphere(radius: CGFloat(textSize * self.scale))
        sphere.firstMaterial?.diffuse.contents = UIColor.magenta
        sphere.firstMaterial?.transparency = CGFloat(0.4)
        return sphere
    }
    
    func extractLink(_ parent: JSON) {
        let parentType = parent["nodeName"]
        if parentType == "A" {
            for (_, attrValue) in parent["attr"] {
                if attrValue["name"] == "href" {
                    self.isButton = true
                    self.href = attrValue["value"].stringValue
                }
            }
        }
    }

}



// end

//if bgImage.stringValue.contains("base64") || bgImage.stringValue.contains("data:") {
//    //                    print(bgImage.stringValue)
//    //                    let result = bgImage.stringValue.sliceWithin(from: ",", to: "\"")
//    //                    if let decodedData = Data(base64Encoded: result!, options: .ignoreUnknownCharacters) {
//    //                        if let image = UIImage(data: decodedData) {
//    //                            self.image = image
//    //                            self.plane.firstMaterial?.diffuse.contents = self.image
//    //                            print("image added")
//    //                            print("success")
//    //                        }
//    //                    }
//} else {
//}

