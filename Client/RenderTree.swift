//
//  RenderTree.swift
//  Client
//
//  Created by Jordan Campbell on 7/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON

class RenderTree {
    
    var ptr: Int = 0
    var nodes: [Node] = [Node]()
    var hasNextNode: Bool = false
    
    func push(_ _node: Node) {
        self.nodes.append(_node)
        self.hasNextNode = true
    }
    
    func next() -> Node {
        self.ptr += 1
        
        if self.ptr == self.nodes.count {
            self.hasNextNode = false
        }
        
        return self.nodes[ self.ptr - 1 ]
    }
    
    func _print() {
        for node in self.nodes {
            node._print()
            for child in node.children {
                child._print()
            }
            print("=======================")
        }
    }
    
    func draw() {
        for node in self.nodes {
            node.render()
        }
    }
}
