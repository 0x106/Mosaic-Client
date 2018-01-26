//
//  Label.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class Label {
    
    var text: String        = ""
    var value: String       = ""
    var node: SCNNode       = SCNNode()
    var plane: SCNPlane     = SCNPlane()
    var label: UILabel      = UILabel()
    var image: UIImage      = UIImage()
    let size: Float         = 0.1
    var width: CGFloat      = CGFloat(0.2)
    var height: CGFloat     = CGFloat(0.2)
    
    var alpha: CGFloat = CGFloat(0.8)
    var red: Int = 0x38
    var green: Int = 0x86
    var blue: Int = 0x97
    
    var labelBGColour: UIColor
    var textColour: UIColor
    
    var isButton: Bool = false
    var isFieldSet: Bool = false
    
    var isHighlighted: Bool = false
    
    init(name: String, isButton: Bool) {
        
        self.isButton = isButton
        
        labelBGColour = UIColor(red: red, green: green, blue: blue).withAlphaComponent(alpha)
        textColour = UIColor(red: 255, green: 255, blue: 255).withAlphaComponent(1.0)
        
        self.text = name
        
        self.label = UILabel(frame: CGRect(x: CGFloat(self.size), y: CGFloat(self.size), width: CGFloat(100), height: CGFloat(50)))
        self.label.textAlignment = .center
        self.label.font = UIFont(name: "Helvetica", size: CGFloat(12.0))
        self.label.textColor = self.textColour
        self.label.adjustsFontSizeToFitWidth = true
        self.label.text = self.text
        
        self.label.backgroundColor = self.labelBGColour
        self.label.layer.cornerRadius = CGFloat(2)
        self.label.clipsToBounds = true
        
        self.width = CGFloat(0.2)
        self.height = CGFloat(0.1)
        
        self.node.name = String(name)
        
        self.plane = SCNPlane(width: self.width, height: self.height)
        self.labelToImage()
    }
    
    func labelToImage() {
        self.image = UIImage.imageWithLabel(label: self.label)
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.node.geometry = self.plane
    }
    
    func setTransparency(_ transparency: Double) {
        self.alpha = CGFloat(transparency)
        self.label.backgroundColor = UIColor(red: self.red, green: self.green, blue: self.blue).withAlphaComponent(self.alpha)
        labelToImage()
    }
    
    func setText(_ text: String) {
        self.value = text
        self.isFieldSet = true
        self.label.textColor = self.textColour
        self.text = text
        self.label.text = self.text
        labelToImage()
    }
    
    func setBGColour(colour: UIColor) {
        let c = colour.withAlphaComponent(alpha)
        self.label.backgroundColor = c
        self.labelBGColour = c
        labelToImage()
    }
    
    func setFaded() {
        self.alpha = 0.14
        setBGColour(colour: self.labelBGColour)
    }
    
    func setActive() {
        self.alpha = 0.85
        self.label.textColor = self.textColour
        setBGColour(colour: self.labelBGColour)
    }
    
    func setSelected() {
        self.labelBGColour = burntOrange
        setBGColour(colour: self.labelBGColour)
    }
    
}
