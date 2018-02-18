//
//  NodeUtils.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import Alamofire

extension Node {
    
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
    func checkText(_ value: String) -> String {
        let checkOnlyWhiteSpaceNewLines: String = String(value).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        if checkOnlyWhiteSpaceNewLines == "" {
            return ""
        }
        
        let trim: String = String(value).trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trim
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
    
    func parseAnimation() {
        
    }
}
