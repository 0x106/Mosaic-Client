//
//  Label.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

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
        self.image = renderer.image { [unowned self] context in
            
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
