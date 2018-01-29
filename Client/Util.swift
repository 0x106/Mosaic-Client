//
//  Styling.swift
//  Client
//
//  Created by Jordan Campbell on 16/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

let DEBUG = true

// default to [0.0, 1.0]
func randomFloat() -> Float {
    return (Float(arc4random()) / 0xFFFFFFFF)
}

func randomFloat(min: Float, max: Float) -> Float {
    return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
}

func randomPosition() -> SCNVector3 {
    
    let x = randomFloat(min: -2.0, max: 2.0)
    let y = randomFloat(min: -2.0, max: 2.0)
    let z = Float(-1.0) // keep everything on the plane for now
    
    let position = SCNVector3Make(x, y, z)
    
    return position
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    class func imageWithTextView(textView: UITextView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(textView.bounds.size, false, 0.0)
        textView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

let burntOrange = UIColor(red: 0xF5, green: 0x5D, blue: 0x3E)
let palatinatePurple = UIColor(red: 0x68, green: 0x2D, blue: 0x63)
let tealBlue = UIColor(red: 0x38, green: 0x86, blue: 0x97)
let zeroColor = UIColor(red: 0x00, green: 0x00, blue: 0x00).withAlphaComponent(CGFloat(0.0))

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
        output = UIColor(red: Int(values[0])!, green: Int(values[1])!, blue: Int(values[2])!).withAlphaComponent(CGFloat(Float(values[3])!))
    } else if input.hasPrefix("rgb") {
        output = UIColor(red: Int(values[0])!, green: Int(values[1])!, blue: Int(values[2])!).withAlphaComponent(CGFloat(1.0))
    } else {
    }
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

func parseResponseToDict(_ input: Data) -> [String : NSDictionary]? {
    do {
        let output = try JSONSerialization.jsonObject(with: input, options: []) as? [String : NSDictionary]
        return output
    } catch let error {
        print("ERROR: ", error)
    }
    return [:]
}

func computeStylesFromDict(_ style: JSON) -> Dictionary<String, Any> {
    var computedStyle: Dictionary<String, Any> = [:]
    
    for (_, property) in style {
                
        let propertyName = property["name"].stringValue
        let propertyValue = property["value"].stringValue

        if propertyName.hasSuffix("color") {
            computedStyle[propertyName] = parseColorString(propertyValue)
        } else if propertyName.hasSuffix("width") || propertyName.hasSuffix("size") || propertyName.hasPrefix("padding") {
            computedStyle[propertyName] = parseSizeString(propertyValue)
        } else {    // presumably anything that makes it in here has a string propertyvalue (or at least a known type)
            computedStyle[propertyName] = propertyValue
        }
    }
    
    return computedStyle
}

//func stripNewLine(_ input: String) -> String {
//
//}
//
//func stripSpace(_ input: String) -> String {
//
//}

func parseText(_ input: String) -> String {
    let text = input.replacingOccurrences(of: "\n", with: "")

//    let text = input
//
//    if text.hasPrefix("\n") {
//        text = .replacingOccurrences(of: "\n", with: "")
//    }
    
    return text
}

func parseHREFFromURL(_ url: String) -> String {
    var startIndex = url.index(of: "(") ?? url.endIndex
    startIndex = url.index(after: startIndex)
    startIndex = url.index(after: startIndex)
    
    var endIndex = url.index(of: ")") ?? url.endIndex
    endIndex = url.index(before: endIndex)
    
    let output = url[startIndex..<endIndex]
    return String(output)
}

func distance(_ p1: SCNVector3, _ p2: SCNVector3) -> Double {
    return Double(sqrt( pow((p1.x - p2.x), 2.0) + pow((p1.y - p2.y), 2.0) + pow((p1.z - p2.z), 2.0) ))
}


//extension code starts
// https://stackoverflow.com/a/42941966/7098234
func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
        return SCNVector3(0.0, 0.0, 0.0)
    }
    
    return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
    
}

// https://stackoverflow.com/a/42941966/7098234
extension SCNNode {
    
    func buildLineInTwoPointsWithRotation(from  startPoint: SCNVector3,
                                          to    endPoint: SCNVector3,
                                          radius: CGFloat,
                                          lengthOffset: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: (l - lengthOffset))
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}


func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(newSize)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.width) )
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

