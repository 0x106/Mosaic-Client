//
//  Socket.swift
//  Client
//
//  Created by Jordan Campbell on 9/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import SocketIO
import ARKit


class AtlasSocket {
    
    var manager: SocketManager
    var socket: SocketIOClient
    var connected: Bool = false
    
    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {[weak self] data, ack in
            print("socket connected")
            self?.connected = true
        }
        
        //        socket.onAny {
        //            print("Got event: \($0.event), with items: \($0.items!)")
        //        }
        
        socket.on("renderTree") { data, ack in
            performance.stop("*request-0")
            print(data)
            performance.results()
        }
        
        socket.on("node") { data, ack in
            print("Received new node data.")
            //            performance.stop("*request-0")
            //            print(data)
            //            performance.results()
        }
        
        socket.on("response") { data, ack in
            print("message received")
            
            self.send_msg("Neuromancer")
            performance.start("*request-0")
            self.send_url("http://stuff.co.nz")
        }
        
        socket.connect()
    }
    
    func send_msg(_ message: String) {
        print("Sending message: \(message)")
        socket.emit("msg", message)
    }
    
    func send_url(_ url: String) {
        print("Sending URL: \(url)")
        socket.emit("url", url)
    }
}
