//
//  ImageElement.swift
//  Client
//
//  Created by Jordan Campbell on 28/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON
import Alamofire
import AlamofireImage


// <img> tags
// div background-image
// element background-image
class Image: Container {
    
    var label: UILabel        = UILabel()
    var image: UIImage!
    
    var bgLabel: UILabel      = UILabel()
    var bgImage: UIImage      = UIImage()
    var bgPlane: SCNPlane     = SCNPlane()
    
    var bgAlpha: CGFloat = CGFloat(1.0)
    var bgColor: UIColor = UIColor()
    
    var textAlpha: CGFloat = CGFloat(1.0)
    var textColor: UIColor = UIColor()
    
    var textFontSize: Float = 12.0
    
    init?(withValue     value: String,
          withKey       key: String,
          withlayout    layout: JSON,
          withStyle     style: JSON,
          withParent    parent: JSON) {
        
        super.init()
        
        let computedStyle = computeStylesFromDict(style)
        if value.hasPrefix("url") {
            self.href = parseHREFFromURL(value)
        }
        
//        self.downloadImage()
        
        let x = Float(layout["x"].doubleValue) * scale
        let y = -Float(layout["y"].doubleValue) * scale
        self.width = Float(layout["width"].doubleValue) * scale
        self.height = Float(layout["height"].doubleValue) * scale
        
        self.plane = SCNPlane(width: CGFloat(self.width), height: CGFloat(self.height))
        
        self.plane.firstMaterial?.diffuse.contents = UIColor.magenta
        self.rootNode.geometry = self.plane
        self.rootNode.position = SCNVector3Make(x, y, 0.0)
        
        print(self.rootNode.position)
    }
    
    func downloadImage() {
        Alamofire.request(self.href).responseImage { response in
            if let image = response.result.value {
                
                self.image = image
                self.plane.firstMaterial?.diffuse.contents = self.image
                print("image added")
            }
        }
    }
    
}
