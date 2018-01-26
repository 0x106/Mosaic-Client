//
//  Dodecahedron.swift
//  Client
//
//  Created by Jordan Campbell on 20/12/17.
//  Copyright © 2017 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class Dodecahedron {
    
    var vertices : [SCNNode] = [SCNNode]()
    var edges: [SCNNode] = [SCNNode]()
    var phi: Float = 0.0
    let N = 20
    let scale: Float = 0.0125
    
    let rootNode = SCNNode()
    
    var colour: UIColor
    
    let sphereRadius = CGFloat(0.002)
    let lineRadius = CGFloat(0.001)
    
    var radius: Float
    
    let root_x_offset: Float = 0.0
    
    init() {
        
        self.phi = (1.0 + sqrt(5.0)) / 2.0
        //        self.colour = UIColor(red: 0x95, green: 0x7D, blue: 0x95)
        self.colour = palatinatePurple //        68 2D 63 - palatinate purple
        self.rootNode.name = "dodecahedronRoot"
        
        self.radius = self.scale
        self.radius *= (sqrt(3.0) / 4.0)
        self.radius *= (1.0 + sqrt(5.0))
        
        let boundingSphere = SCNSphere(radius: CGFloat(self.radius + (0.2 * self.radius)))
        boundingSphere.firstMaterial?.transparency = CGFloat(0.0)
        let boundingNode = SCNNode(geometry: boundingSphere)
        boundingNode.name = "dodecBoundingNode"
        
        self.rootNode.addChildNode(boundingNode)
        
        for i in 0 ... N-1 {
            vertices.append(SCNNode())
            let sphere = addSphere()
            vertices[i].geometry = sphere
            vertices[i].name = "dodecahedronVertexNode" + String(i)
            //            edges.append(vertices[i])
            self.rootNode.addChildNode(vertices[i])
        }
        
        
        // https://en.wikipedia.org/wiki/Regular_dodecahedron#Facet-defining_equations
        //orange
        vertices[0].position = SCNVector3Make(1.0 * scale, 1.0 * scale, 1.0 * scale)
        vertices[1].position = SCNVector3Make(1.0 * scale, 1.0 * scale, -1.0 * scale)
        vertices[2].position = SCNVector3Make(1.0 * scale, -1.0 * scale, 1.0 * scale)
        vertices[3].position = SCNVector3Make(1.0 * scale, -1.0 * scale, -1.0 * scale)
        vertices[4].position = SCNVector3Make(-1.0 * scale, 1.0 * scale, 1.0 * scale)
        vertices[5].position = SCNVector3Make(-1.0 * scale, 1.0 * scale, -1.0 * scale)
        vertices[6].position = SCNVector3Make(-1.0 * scale, -1.0 * scale, 1.0 * scale)
        vertices[7].position = SCNVector3Make(-1.0 * scale, -1.0 * scale, -1.0 * scale)
        
        // pink
        vertices[8].position = SCNVector3Make(  phi * scale,  (1.0 / phi) * scale, 0)
        vertices[9].position = SCNVector3Make(  phi * scale, -(1.0 / phi) * scale, 0)
        vertices[10].position = SCNVector3Make(-phi * scale,  (1.0 / phi) * scale, 0)
        vertices[11].position = SCNVector3Make(-phi * scale, -(1.0 / phi) * scale, 0)
        
        // green
        vertices[12].position = SCNVector3Make(0,  phi * scale,  (1.0 / phi) * scale)
        vertices[13].position = SCNVector3Make(0,  phi * scale, -(1.0 / phi) * scale)
        vertices[14].position = SCNVector3Make(0, -phi * scale,  (1.0 / phi) * scale)
        vertices[15].position = SCNVector3Make(0, -phi * scale, -(1.0 / phi) * scale)
        
        // blue
        vertices[16].position = SCNVector3Make( (1.0 / phi) * scale, 0,  phi * scale)
        vertices[17].position = SCNVector3Make(-(1.0 / phi) * scale, 0,  phi * scale)
        vertices[18].position = SCNVector3Make( (1.0 / phi) * scale, 0, -phi * scale)
        vertices[19].position = SCNVector3Make(-(1.0 / phi) * scale, 0, -phi * scale)
        
        addLines()
        
        rootNode.isHidden = true
        rootNode.position = SCNVector3Make(-Float(root_x_offset / 2.0), 0, -0.28 + 1.0)
//        rootNode.position = SCNVector3Make(-Float(root_x_offset / 2.0), 0, -1.0)
    }
    
    func addSphere() -> SCNSphere {
        
        let sphere = SCNSphere(radius: sphereRadius)
        sphere.firstMaterial?.diffuse.contents = self.colour//UIColor.magenta
        
        return sphere
        
    }
    
    func addLines() {
        
        edges.append(line(vertices[14].position, vertices[2].position))
        edges.append(line(vertices[14].position, vertices[6].position))
        edges.append(line(vertices[14].position, vertices[15].position))
        
        edges.append(line(vertices[15].position, vertices[3].position))
        edges.append(line(vertices[15].position, vertices[7].position))
        
        edges.append(line(vertices[19].position, vertices[5].position))
        edges.append(line(vertices[19].position, vertices[7].position))
        edges.append(line(vertices[19].position, vertices[18].position))
        
        edges.append(line(vertices[18].position, vertices[1].position))
        edges.append(line(vertices[18].position, vertices[3].position))
        
        edges.append(line(vertices[11].position, vertices[6].position))
        edges.append(line(vertices[11].position, vertices[7].position))
        edges.append(line(vertices[11].position, vertices[10].position))
        
        edges.append(line(vertices[10].position, vertices[4].position))
        edges.append(line(vertices[10].position, vertices[5].position))
        
        edges.append(line(vertices[17].position, vertices[4].position))
        edges.append(line(vertices[17].position, vertices[6].position))
        edges.append(line(vertices[17].position, vertices[16].position))
        
        edges.append(line(vertices[16].position, vertices[0].position))
        edges.append(line(vertices[16].position, vertices[2].position))
        
        edges.append(line(vertices[13].position, vertices[1].position))
        edges.append(line(vertices[13].position, vertices[5].position))
        edges.append(line(vertices[13].position, vertices[12].position))
        
        edges.append(line(vertices[12].position, vertices[0].position))
        edges.append(line(vertices[12].position, vertices[4].position))
        
        edges.append(line(vertices[9].position, vertices[2].position))
        edges.append(line(vertices[9].position, vertices[3].position))
        edges.append(line(vertices[9].position, vertices[8].position))
        
        edges.append(line(vertices[8].position, vertices[0].position))
        edges.append(line(vertices[8].position, vertices[1].position))
        
        edges[0].name = "dodecahedronEdgeNode14-2"
        edges[1].name = "dodecahedronEdgeNode14-6"
        edges[2].name = "dodecahedronEdgeNode14-15"
        
        edges[3].name = "dodecahedronEdgeNode15-3"
        edges[4].name = "dodecahedronEdgeNode15-7"
        
        edges[5].name = "dodecahedronEdgeNode19-5"
        edges[6].name = "dodecahedronEdgeNode19-7"
        edges[7].name = "dodecahedronEdgeNode19-18"
        
        edges[8].name = "dodecahedronEdgeNode18-1"
        edges[9].name = "dodecahedronEdgeNode18-3"
        
        edges[10].name = "dodecahedronEdgeNode11-6"
        edges[11].name = "dodecahedronEdgeNode11-7"
        edges[12].name = "dodecahedronEdgeNode11-10"
        
        edges[13].name = "dodecahedronEdgeNode10-4"
        edges[14].name = "dodecahedronEdgeNode10-5"
        
        edges[15].name = "dodecahedronEdgeNode17-4"
        edges[16].name = "dodecahedronEdgeNode17-6"
        edges[17].name = "dodecahedronEdgeNode17-16"
        
        edges[18].name = "dodecahedronEdgeNode16-0"
        edges[19].name = "dodecahedronEdgeNode16-2"
        
        edges[20].name = "dodecahedronEdgeNode13-1"
        edges[21].name = "dodecahedronEdgeNode13-5"
        edges[22].name = "dodecahedronEdgeNode13-12"
        
        edges[23].name = "dodecahedronEdgeNode12-0"
        edges[24].name = "dodecahedronEdgeNode12-4"
        
        edges[25].name = "dodecahedronEdgeNode9-2"
        edges[26].name = "dodecahedronEdgeNode9-3"
        edges[27].name = "dodecahedronEdgeNode9-8"
        
        edges[28].name = "dodecahedronEdgeNode8-0"
        edges[29].name = "dodecahedronEdgeNode8-1"
        
        for edge in edges {
            self.rootNode.addChildNode(edge)
        }
        
    }
    
    func line(_ p1: SCNVector3, _ p2: SCNVector3) -> SCNNode {
        let node = SCNNode()
        //        node.buildLineInTwoPointsWithRotation(from: p1, to: p2, radius: 0.005, lengthOffset: 0.01, color: self.colour)
        node.buildLineInTwoPointsWithRotation(from: p1, to: p2, radius: lineRadius, lengthOffset: 0.0, color: self.colour) // no length offset
        return node
    }
    
    func animate() {
        let rotation = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)
        rootNode.runAction(SCNAction.repeatForever(rotation))
    }
    
}





// end

