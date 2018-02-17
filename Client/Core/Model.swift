//
//  Model.swift
//  Client
//
//  Created by Jordan Campbell on 16/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import Alamofire

class Model {
    var filename: String = ""
    var rootNode: SCNNode = SCNNode()
    var hasModel: Bool = false
    let requestURL: String = "http://c9404ecc.ngrok.io/ship/"
    
    func loadModel(_ fname: String) -> Bool {
        
        if fname == "" {
            if let _model = SCNScene(named: "art.scnassets/ship.scn") {
                
                for node in _model.rootNode.childNodes {
                    self.rootNode.addChildNode(node)
                }
                
                hasModel = true
                return true
        
            } else {
                print("couldn't load model")
                return false
            }
        } else {
            self.filename = fname
            self.download()
            
            return true
        }
        
        return false
    }
    
    // at the moment this will just download from the local/tmp server
    func download() {
        
        var localFile: URL = URL(fileURLWithPath: "")
        
        let destination: Alamofire.DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            localFile = documentsURL.appendingPathComponent(self.filename)
            return (localFile, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let remoteFileRequestURL = self.requestURL + filename
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 500
        
        print(localFile)
        print(remoteFileRequestURL)
                
        manager.download(
            remoteFileRequestURL,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
        }).response(completionHandler: { (DefaultDownloadResponse) in
            
            print(self.filename)
            print(localFile)
            print(remoteFileRequestURL)
                
            //here you able to access the DefaultDownloadResponse
            if let source = SCNSceneSource(url: localFile, options: nil) {
                do {
                    let tempScene = try source.scene(options: nil)
                    for child in tempScene.rootNode.childNodes {
                        self.rootNode.addChildNode(child)
                    }
                } catch {
                    print("Model download failed (1)")
                }
            } else {
                print("Model download failed (2)")
            }
        
            self.hasModel = true
        })
    }
}
