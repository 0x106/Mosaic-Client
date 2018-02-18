//
//  NodeRender.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation

import ARKit

extension Node {
    
    func render() -> Bool {
        if !nodeIsVisible() {
            return false
        }
        
        // if the image is / will be drawn then we don't need to render anything
        if !self.canDrawOverlay || self.isAFrameNode {
            return true
        }
        
        if self.nodeName == "#text" {
            let _ = self.renderText()
        } else if self.canReceiveUserInput {
            let _ = self.renderInput()
        } else {
            let _ = self.renderComponent()
        }
        
        self.geometry = SCNPlane(width: CGFloat(self.totalWidth * self.scale), height: CGFloat(self.totalHeight * self.scale))
        self.geometry?.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.geometry
        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true
        
        return true
    }
    
    func renderText() -> Bool {
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
        
        return true
    }
    
    func renderInput() -> Bool {
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
        return true
    }
    
    func renderComponent() -> Bool {
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
        return true
    }
    
    
    func nodeIsVisible() -> Bool {
        
        if self.forceRender {
            return true
        }
        
        if self.canRender {
            return true
        }
        
        return false
    }
    
}
