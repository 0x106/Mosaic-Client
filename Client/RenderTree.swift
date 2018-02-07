//
//  RenderTree.swift
//  Client
//
//  Created by Jordan Campbell on 7/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//
//  1. Some nodes have children that aren't actually included in the snapshot.
//      This means that they are added to the render tree 
//
//
//
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
        }
    }
    
    func renderedNodes() -> [Node] {
        return nodes
    }
    
    func draw() {
        var counter: Int = 0
        for node in self.nodes {
            if node.canRender {
                if node.render() {
                    counter += 1
                }
            }
        }
        print("\(counter) nodes rendered.")
    }
}
