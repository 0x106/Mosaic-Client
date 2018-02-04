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

    let server: String = "http://8fb3eb69.ngrok.io"
    var serverEndpoint: String = ""
    var requestURL: String = ""
    var requestID: String = ""

    var writeData: Bool = true

    init() {

        self.serverEndpoint = "\(self.server)/client"

        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.isHidden = true

        orb.rootNode.isHidden = true
        searchBar.rootNode.isHidden = false

        rootNode.addChildNode(orb.rootNode)
        rootNode.addChildNode(searchBar.rootNode)

        rootNode.position = SCNVector3Make(0, 0, -1)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        self.searchBar.updateText( textField.text! )
    }

    func request(withURL url: String, _ refresh: Bool = false) {

        // show loading animation
        self.orb.rootNode.isHidden = false
        self.orb.animate()
        self.searchBar.rootNode.isHidden = true

        // check url
        if url == "" {
            // primitive test of the server index.hbs
            requestURL = server
            self.requestID = urlToID(requestURL)
        } else {
            requestURL = checkURL(url)
        }

        // check to see if a local cache of this url exists
        if refresh {
            self.networkRequest()
        } else {

            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let file = URL(fileURLWithPath: documents + "/\(self.requestID).json")
            let dataLoaderWorker = DispatchQueue(label: "dataLoaderWorker", qos: .userInitiated)

            dataLoaderWorker.async {
                do {
                    let data = try Data(contentsOf: file)
                    let response = try JSON(data: data)
                    self.writeData = false
                    self.addNewDomain(response)
                } catch {
                    self.networkRequest()
                }
            }
        }
    }

    private func networkRequest() {
        self.writeData = true

        let parameters: Parameters = ["atlasurl": requestURL]

        Alamofire.request("\(self.serverEndpoint)", method: .get, parameters: parameters)
            .responseSwiftyJSON { dataResponse in

                guard let response = dataResponse.value else {return}
                self.addNewDomain(response)
        }
    }

    func addNewDomain(_ response: JSON) {

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
                    } catch {
                    }
                }
            }

            // remove any pages currently in the scene
            if let domain = self.currentDomain {
                domain.rootNode.removeFromParentNode()
            }

            // initialise the new domain
            self.domains.append(Domain(self.requestURL))
            self.currentDomain = self.domains[ self.domains.count - 1 ]

            // add the new domain to the scene
            self.currentDomain.setData(response, self.requestID)
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

        if url.hasPrefix("http://www.") || url.hasPrefix("https://www.") {
            return output
        }

        // e.g: www.atlasreality.xyz
        if url.hasPrefix("www.") {
            output = "http://" + url
            return output
        }

        // e.g: http://atlasreality.xyz
        if url.hasPrefix("http://") || url.hasPrefix("https://") {

            var index = url.index(of: "/") ?? url.startIndex
            index = url.index(after: index)
            index = url.index(after: index)

            output = "https://www." + url[index..<url.endIndex]

            return output
        }

        // e.g: atlasreality.xyz
        if !url.hasPrefix("http://www.") && !url.hasPrefix("https://www.") {
            output = "http://www." + url
            return output
        }

        return output
    }

}
