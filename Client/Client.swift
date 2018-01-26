//
//  Client.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class Client {
    
    let searchBar = SearchBar()
    let field: UITextField = UITextField()
    let rootNode: SCNNode = SCNNode()
    
    var domains: [Domain] = [Domain]()
    var currentDomain: Domain!
    
    let orb: Dodecahedron = Dodecahedron()
    
    init() {
        
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.isHidden = true
        
        orb.rootNode.isHidden = true
        
        rootNode.addChildNode(orb.rootNode)
        rootNode.addChildNode(searchBar.rootNode)
       
        rootNode.position = SCNVector3Make(0, 0, -1)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.searchBar.setText( textField.text! )
    }
    
    func request(withURL url: String) {
        
        // show loading animation
        self.orb.rootNode.isHidden = false
        self.orb.animate()
        self.searchBar.rootNode.isHidden = true
        
        // check url
        let requestURL = checkURL(url)
        print(requestURL)
        
        let parameters: Parameters = ["atlasurl": requestURL]
        let apiRequestURL = "http://90c3bbfb.ngrok.io/client"
        
        Alamofire.request("\(apiRequestURL)", method: .get, parameters: parameters)
            .responseSwiftyJSON { dataResponse in
                
                guard let response = dataResponse.value else {return}
                self.addNewDomain(response)
        }
    }
    
    func addNewDomain(_ response: JSON) {
       
        // remove any pages currently in the scene
        if let domain = self.currentDomain {
            domain.rootNode.removeFromParentNode()
        }
        
        // initialise the new domain
        self.domains.append(Domain())
        self.currentDomain = self.domains[ self.domains.count - 1 ]
        
        // add the new domain to the scene
        self.currentDomain.setData(response)
        self.rootNode.addChildNode(self.currentDomain.rootNode)
        
        self.orb.rootNode.isHidden = true
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file = URL(fileURLWithPath: documents + "/atlas-client.scn")

        if DEBUG {
            let scene = SCNScene()
            scene.rootNode.addChildNode(self.rootNode)
            scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
            print(documents)
            
            exit(EXIT_SUCCESS)
        }
        
    }
    
    
    // won't catch incorrect urls (atlas.xyz)
    // wont' catch incorrect suffixes (atlasreality.xy-a)
    // won't catch missing www (http://atlasreality.xyz)
    func checkURL(_ url: String) -> String {
                
        var output = url
        
        if url.hasPrefix("http://www.") {
            return output
        }
        
        // e.g: www.atlasreality.xyz
        if url.hasPrefix("www.") {
            output = "http://" + url
            return output
        }
        
        // e.g: http://atlasreality.xyz
        if url.hasPrefix("http://") {
            return output
        }
        
        // e.g: atlasreality.xyz
        if !url.hasPrefix("http://www.") {
            output = "http://www." + url
            return output
        }
        
        return output
    }
    
}
