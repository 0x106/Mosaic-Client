//
//  SearchBar.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class SearchBar: Container {
    
    var value: String       = ""
    var label: UILabel      = UILabel()
    let size: Float         = 0.1
    
    var alpha: CGFloat = CGFloat(0.8)
    
    var labelBGColour: UIColor = UIColor(red: 240, green: 240, blue: 240).withAlphaComponent(0.5)
    var textColour: UIColor = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(1.0)
    
    var isFieldSet: Bool = false
    var isHighlighted: Bool = false
    var button: Label = Label("Search", true)
    
    override init() {
        
        super.init()
        
        self.text = ""
        self.nucleus = CGRect(x: 0.0, y: 0.0, width: CGFloat(500), height: CGFloat(50))
        
        self.label.textAlignment = .left
        self.label.font = UIFont(name: "Arial", size: CGFloat(22.0))
        self.label.textColor = self.textColour
        self.label.adjustsFontSizeToFitWidth = true
        self.label.text = self.text
        
        self.label.backgroundColor = self.labelBGColour
        self.label.layer.borderColor = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(0.1).cgColor
        self.label.layer.borderWidth = CGFloat(2.0)
        self.label.layer.cornerRadius = CGFloat(2)
        self.label.clipsToBounds = true
        
        self.width = 0.67
        self.height = 0.1
        
        self.rootNode.name = "searchBarNode"
        self.rootNode.geometry?.firstMaterial?.isDoubleSided = true
        
        self.plane = SCNPlane(width: CGFloat(self.width), height: CGFloat(self.height))
//        self.labelToImage()
        
        button.rootNode.name = "searchBarButtonNode"
        button.rootNode.position = SCNVector3Make(0, -0.2, 0)
        self.rootNode.addChildNode(button.rootNode)
    }
    
    func labelToImage() {
        self.image = UIImage.imageWithLabel(label: self.label)
        self.plane.firstMaterial?.diffuse.contents = self.image
        self.rootNode.geometry = self.plane
    }
    
    func setTransparency(_ transparency: Double) {
        self.alpha = CGFloat(transparency)
        self.label.backgroundColor = UIColor(red: 240, green: 240, blue: 240).withAlphaComponent(self.alpha)
//        labelToImage()
    }
    
    func setText(_ text: String) {
        self.value = text
        self.isFieldSet = true
        self.label.textColor = self.textColour
        self.text = text
        self.label.text = self.text
//        labelToImage()
    }
    
    func setBGColour(colour: UIColor) {
        let c = colour.withAlphaComponent(alpha)
        self.label.backgroundColor = c
        self.labelBGColour = c
//        labelToImage()
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
