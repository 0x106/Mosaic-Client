//
//  SearchBar.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class SearchBar {

    var currentUserInput: String = ""

    var label: Label = Label()
    var button: Label = Label()
    var toggle: Bool = true
    var rootNode: SCNNode = SCNNode()
    var cursorTimer: Timer!
    var text = ""

    init() {

        self.label.text = ""
        self.text = ""
        label.cell = CGRect(x: 0.0, y: 0.0, width: CGFloat(750), height: CGFloat(100))
        label.nucleus = CGRect(x: 20.0, y: 35, width: CGFloat(750), height: CGFloat(50))
        label.totalWidth = Float(label.cell.width)
        label.totalHeight = Float(label.cell.height)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        label.setFont("Arial", 30.0)
        label.rootNode.name = "searchBarNode"
        label.render()

        self.button.text = "Go Go Gizmo"
        button.cell = CGRect(x: 0.0, y: 0.0, width: CGFloat(400), height: CGFloat(100))
        button.nucleus = CGRect(x: 0.0, y: 0.0, width: CGFloat(400), height: CGFloat(100))
        button.totalWidth = Float(button.cell.width)
        button.totalHeight = Float(button.cell.height)
        button.backgroundColor = tealBlue
        button.color = UIColor.white.withAlphaComponent(0.4)
        button.setFont("Arial", 36.0)
        button.textAlignment = "center"
        button.render()

        button.rootNode.name = "searchBarButtonNode"
        button.rootNode.position = SCNVector3Make(0, -0.2, 0)

        self.rootNode.addChildNode(label.rootNode)
        self.rootNode.addChildNode(button.rootNode)
        
        self.rootNode.position = SCNVector3Make(0, 0, -0.4)
        
        cursorTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(cursorBlink), userInfo: nil, repeats: true)

        print("Search bar initialised")
    }

    func updateText(_ text: String) {
        self.label.text = text
        self.text = text
        self.label.render()
        
    }

    @objc func cursorBlink() {
        if toggle {
            self.label.text = self.text + "|"
            toggle = false
        } else {
            self.label.text = self.text
            toggle = true
        }
        self.label.render()
    }
    
}

