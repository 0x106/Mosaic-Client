//
//  Model.swift
//  Client
//
//  Created by Jordan Campbell on 16/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class Model {
    var filename: String = ""
    var rootNode: SCNNode = SCNNode()
    
    func loadModel(_ fname: String) {
        print("Loading model")
        if fname == "" {
            print("default model")
            if let model = SCNScene(named: "ship") {
                print("model loaded")
                self.rootNode = model.rootNode
            } else {
                print("couldn't load model")
            }
        }
    }
}
