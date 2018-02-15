//
//  NodeGlobals.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

let top = 0
let left = 1
let right = 2
let bottom = 3

let wa = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(0.0))
let wb = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(CGFloat(1.0))
let wc = UIColor(red: 0, green: 0, blue: 0)

enum nodeType {
    case TEXT
    case P
    case A
    case INPUT
    case LI
    case UL
    case OL
    case DIV
    case BODY
    case TABLE
    case TR
    case TD
}
