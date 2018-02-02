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
    
    var label: Container = Container()
    var button: Container = Container()
    
    var rootNode: SCNNode = SCNNode()

    init() {

        label.cell = CGRect(x: 0.0, y: 0.0, width: CGFloat(500), height: CGFloat(50))
        label.nucleus = CGRect(x: 0.0, y: 0.0, width: CGFloat(500), height: CGFloat(50))
        label.background_color = UIColor.white.withAlphaComponent(0.4)
        label.color = tealBlue
        label.draw()

        self.button.text = "Search"
        button.cell = CGRect(x: 0.0, y: 0.0, width: CGFloat(500), height: CGFloat(50))
        button.nucleus = CGRect(x: 0.0, y: 0.0, width: CGFloat(500), height: CGFloat(50))
        button.background_color = UIColor.white.withAlphaComponent(0.4)
        button.color = tealBlue
        button.draw()
        
        button.rootNode.name = "searchBarButtonNode"
        button.rootNode.position = SCNVector3Make(0, -0.2, 0)
        
        self.rootNode.addChildNode(label.rootNode)
        self.rootNode.addChildNode(button.rootNode)
    }

    func updateText(_ text: String) {
        self.label.text = text
        self.label.draw()
    }

}

