//
//  Client.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit
import SwiftyJSON
import SocketIO

var globalRequestID: String = ""

class Client {

    let searchBar = SearchBar()
    let field: UITextField = UITextField()
    let rootNode: SCNNode = SCNNode()

    var domains: [Domain] = [Domain]()
    var currentDomain: Domain!

    let orb: Dodecahedron = Dodecahedron()

    let server: String = "http://a2ea58e1.ngrok.io"
    var serverEndpoint: String = ""
    var requestURL: String = ""
    var requestID: String = ""
//    let defaultSearchURL: String = "http://google.co.nz"
//    let defaultSearchURL: String = "https://medium.com/swlh/the-road-to-consumer-augmented-reality-4ff502a7a1b6"
    let defaultSearchURL: String = "https://af03ee4a.ngrok.io"
//    let defaultSearchURL: String = "https://www.oipolloi.com/collections/new-stuff"
//    let defaultSearchURL: String = "http://stuff.co.nz"
//    let defaultSearchURL: String = "http://arvrgarage.nz"
//    let defaultSearchURL: String = "http://atlasreality.xyz"
//    let defaultSearchURL: String = "http://afore.vc"

    var writeData: Bool = true
    
    var manager: SocketManager
    var socket: SocketIOClient
    var connected: Bool = false
    var sceneData: [Dictionary<String, Any>] = [Dictionary<String, Any>]()
    
    let renderGroup = DispatchGroup()

    init() {
        manager = SocketManager(socketURL: URL(string: self.server)!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {[weak self] data, ack in
            print("socket connected")
            self?.connected = true
            self?.rootNode.addChildNode((self?.searchBar.rootNode)!)
        }
    
        socket.on("config") {response, ack in
            
            guard let data = response[0] as? Dictionary<String, Any> else { return }
            ack.with("config recvd", "")
            
            print("received config")
            if let data = response[0] as? Dictionary<String, Any> {
                self?.currentDomain.configManager.setup( (self?.requestURL)!, data )
            }
        }
        
        socket.on("renderTreeStart") {[weak self] data, ack in
            if !(self?.orb.rootNode.isHidden)! {
                self?.orb.rootNode.isHidden = true
            }
        }

        socket.on("node") {[weak self] data, ack in
//            let nodeWorker = DispatchQueue(label: "nodeWorker", qos: .userInitiated)
            let nodeWorker = DispatchQueue(label: "nodeWorker", qos: .utility)
            nodeWorker.async {
                if let nodeData = data[0] as? Dictionary<String, Any> {
                    if let key = nodeData["key"] as? String {
                        self?.currentDomain.addNodeAsync( nodeData )
                    }
                }
            }
        }
        
        socket.on("renderTreeComplete") {[weak self] data, ack in
            print("All render tree nodes sent")
            self?.currentDomain.allDataSent = true
//            self?.currentDomain.process()
        }
    
        socket.connect()
    
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.isHidden = true
        field.autocapitalizationType = UITextAutocapitalizationType.none;

        orb.rootNode.isHidden = true
        searchBar.rootNode.isHidden = false

        rootNode.addChildNode(orb.rootNode)
        rootNode.position = SCNVector3Make(0, 0, -1)

    }
    
    func initDomain() {
        // remove any pages currently in the scene (still keep a reference to them)
        if let domain = self.currentDomain {
            domain.rootNode.removeFromParentNode()
        }
    
        self.domains.append(Domain(self.requestURL))
        self.currentDomain = self.domains[ self.domains.count - 1 ]
        self.rootNode.addChildNode(self.currentDomain.rootNode)
        
    }
    
    func send_msg(_ message: String) {
        print("Sending message: \(message)")
        socket.emit("msg", message)
    }
    
    func clientRequest() {
        print("Sending URL: \(self.requestURL)")
        initDomain()
        
        socket.emit("url", self.requestURL)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        self.searchBar.updateText( textField.text! )
    }

    func request(withURL url: String, _ refresh: Bool = false) {

        // show loading animation
        self.orb.rootNode.isHidden = false
        self.orb.animate()
        self.searchBar.rootNode.isHidden = true

        if url == "" {
            requestURL = server
            self.requestID = urlToID(requestURL)
        } else {
            requestURL = checkURL(url)
        }
        
        globalRequestID = requestID

        // check to see if a local cache of this url exists
        if refresh {
            self.clientRequest()
        } else {

            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let file = URL(fileURLWithPath: documents + "/\(self.requestID).json")
            let dataLoaderWorker = DispatchQueue(label: "dataLoaderWorker", qos: .userInitiated)

            dataLoaderWorker.async {
                do {
                    let data = try Data(contentsOf: file)
                    print("Reading data from local file.")
                    let response = try JSON(data: data)
                    self.writeData = false
                    self.addNewDomain(response)
                } catch {
                    self.clientRequest()
                }
            }
        }
    }
    func addNewDomain(_ response: JSON) {

        print("Adding domain.")
        
        // UI work always done on main thread
        DispatchQueue.main.async { [unowned self] in

            if self.writeData { 
                let dataWriterWorker = DispatchQueue(label: "dataWriterWorker", qos: .userInitiated)
                dataWriterWorker.async {
                    do {
                        let data = try response.rawData()
                        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let file = URL(fileURLWithPath: documents + "/\(self.requestID).json")
                        try data.write(to: file)
                        print("Wrote request data to file.")
                    } catch {
                        print("Couldn't write to file: \(self.requestID).json")
                    }
                }
            }

            // remove any pages currently in the scene (still keep a reference to them)
            if let domain = self.currentDomain {
                domain.rootNode.removeFromParentNode()
            }

            // initialise the new domain
            self.domains.append(Domain(self.requestURL))
            self.currentDomain = self.domains[ self.domains.count - 1 ]

            // add the new domain to the scene            
//            self.currentDomain.constructRenderTree(response, self.requestID)
            
            self.rootNode.addChildNode(self.currentDomain.rootNode)

            self.orb.rootNode.isHidden = true
        }

    }


    // won't catch incorrect urls (atlas.xyz)
    // wont' catch incorrect suffixes (atlasreality.xy-a)
    // won't catch missing www (http://atlasreality.xyz)
    func checkURL(_ _url: String) -> String {

        let url = _url.lowercased()

        var output = url
        self.requestID = urlToID(url)

        // http://www.atlasreality.xyz -> http://www.atlasreality.xyz
        if url.hasPrefix("http://www.") || url.hasPrefix("https://www.") {
            return output
        }

        // e.g: www.atlasreality.xyz -> http://www.atlasreality.xyz
        if url.hasPrefix("www.") {
            output = "http://" + url
            return output
        }

        // e.g: http://atlasreality.xyz
        if url.hasPrefix("http://") || url.hasPrefix("https://") {

//            var index = url.index(of: "/") ?? url.startIndex
//            index = url.index(after: index)
//            index = url.index(after: index)
//
//            output = "https://www." + url[index..<url.endIndex]
            return output
        }

        // e.g: atlasreality.xyz -> http://www.atlasreality.xyz
        if !url.hasPrefix("http://www.") && !url.hasPrefix("https://www.") {
            output = "http://www." + url
            return output
        }

        return output
    }

}
