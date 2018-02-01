//
//  ViewController.swift
//  Client
//
//  Created by Jordan Campbell on 25/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftyJSON

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let client = Client()
    let trackingStatus = false
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addButton()
//        client.request(withURL: "", true)
//        client.request(withURL: "https://www.google.co.nz/search?q=augmented+reality&oq=augmented+reality&aqs=chrome..69i57j69i60l3j0j69i59.5831j0j1&sourceid=chrome&ie=UTF-8")
        DEBUG = false
//        playground()
    }

    func setup() {
        
        // don't run the AR session in debug mode
        if !DEBUG {
            self.sceneView.scene.rootNode.addChildNode(client.rootNode)
            self.sceneView.addSubview(client.field)
        }
    }
    
    @objc public func buttonPress() {
        //        client.request(withURL: "")
//        client.request(withURL: "")
        //        client.request(withURL: "atlasreality.xyz")
//        client.request(withURL: "https://www.google.co.nz/search?q=augmented+reality&oq=augmented+reality&aqs=chrome..69i57j69i60l3j0j69i59.5831j0j1&sourceid=chrome&ie=UTF-8")
                client.request(withURL: "https://news.ycombinator.com/newest", false)
        //        client.request(withURL: "https://afore.vc/")
        //        client.request(withURL: "http://www.dell.com/nz/p")
        //        client.request(withURL: "https://ueno.co/")b
        //        client.request(withURL: "http://hookbang.com/")
        //        client.request(withURL: "unsplash.com")
        //        client.request(withURL: "https://developers.google.com/web/fundamentals/performance/critical-rendering-path/render-blocking-css")
        //        client.request(withURL: "http://www.google.co.nz/search?q=augmented+reality&oq=augmented+reality&aqs=chrome..69i57j69i60l3j69i59l2.3040j0j1&sourceid=chrome&ie=UTF-8")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: self.sceneView) {
            if let hit = self.sceneView.hitTest(touchLocation, options: nil).first {
                guard let nodeName = hit.node.name else {
                    return
                }
                if nodeName == "searchBarNode" {
                    client.field.becomeFirstResponder()
                } else if nodeName == "searchBarButtonNode" {
                    guard let search = client.field.text else { return }
                    client.field.resignFirstResponder()
                    client.request(withURL: search)
                } else {
                    
                    // will fail if we haven't got a domain yet
                    guard let currentDomain = client.currentDomain else {return}
                    
                    guard let tappedNode = currentDomain.getNode(withKey: nodeName) else {return}
                    if tappedNode.isButton {
                        client.request(withURL: tappedNode.href)
                    }
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if self.trackingStatus == false {
            if let state = self.sceneView.session.currentFrame?.camera.trackingState {
                switch(state) {
                case .normal:
                    self.setup()
                case .notAvailable:
                    break
                case .limited(let _):
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        if !DEBUG { // don't run the AR session in debug mode
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func playground() {
        
        let rootNode = SCNNode()
        
        let nucleus_height: Float = 400
        let nucleus_width: Float = 512
        
        let border_top_width: Float = 12
        let padding_top: Float = 100
  
        let border_bottom_width: Float = 6
        let padding_bottom: Float = 20
        
        let border_left_width: Float = 10
        let padding_left: Float = 20
        
        let border_right_width: Float = 12
        let padding_right: Float = 1
        
        let total_height: Float = border_top_width + padding_top + nucleus_height + border_bottom_width + padding_bottom
        let total_width: Float = nucleus_width + border_left_width + padding_left + border_right_width + padding_right
        
        let cell = CGRect(x: CGFloat(0.0),
                             y: CGFloat(0.0),
                             width: CGFloat(total_width),
                             height: CGFloat(total_height))
        
        let nucleus = CGRect(x: CGFloat(border_left_width + padding_left),
                             y: CGFloat(border_top_width + padding_top),
                             width: CGFloat(nucleus_width),
                             height: CGFloat(nucleus_height))
        
        let bottom = CGRect(x: CGFloat(0.0),
                            y: CGFloat(border_top_width + padding_top + nucleus_height + padding_bottom),
                            width: CGFloat(total_width),
                            height: CGFloat(border_bottom_width))
        
        let top = CGRect(x: CGFloat(0.0),
                            y: CGFloat(0.0),
                            width: CGFloat(total_width),
                            height: CGFloat(border_top_width))
        
        let left = CGRect(x: CGFloat(0.0),
                         y: CGFloat(0.0),
                         width: CGFloat(border_left_width),
                         height: CGFloat(total_height))
        
        let right = CGRect(x: CGFloat(border_left_width + nucleus_width + padding_left + padding_right),
                         y: CGFloat(0.0),
                         width: CGFloat(border_right_width),
                         height: CGFloat(total_height))

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(total_width), height: CGFloat(total_height)))
        let img = renderer.image { context in
            
            UIColor.red.setFill()
            context.fill(cell)
        
            UIColor.green.setFill()
            context.fill(bottom)
            
            UIColor.blue.setFill()
            context.fill(top)
            
            UIColor.black.setFill()
            context.fill(left)
            
            UIColor.yellow.setFill()
            context.fill(right)
            
            UIColor.magenta.setFill()
            context.fill(nucleus)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Thin", size: 50)!, NSAttributedStringKey.paragraphStyle: paragraphStyle]
            let string = "“The life of a poet lies not merely in the finite language-dance of expression but in the nearly infinite combinations of perception and memory combined with the sensitivity to what is perceived and remembered.”"
            string.draw(with: nucleus, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        
        let plane = SCNPlane(width: CGFloat(0.1), height: CGFloat(0.1))
        plane.firstMaterial?.diffuse.contents = img
        rootNode.geometry = plane
        
        rootNode.position = SCNVector3Make(0,0,-1)
        
        self.sceneView.scene.rootNode.addChildNode(rootNode)
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file = URL(fileURLWithPath: documents + "/atlas-client.scn")
        
        sceneView.scene.write(to: file, options: nil, delegate: nil, progressHandler: nil)
        
        print(documents)
        exit(EXIT_SUCCESS)
    }
    
    func toImage(_ input: UITextView) -> SCNPlane {
        let image = UIImage.imageWithTextView(textView: input)
        let plane = SCNPlane(width: CGFloat(0.1), height: CGFloat(0.1))
        plane.firstMaterial?.diffuse.contents = image
        return plane
    }
    
}


extension ViewController {
    func addButton() {
        let bx = CGFloat((self.sceneView.bounds.maxX/2) - 24)
        let by = CGFloat(self.sceneView.bounds.maxY - 80)
        button.frame = CGRect(x: bx, y: by, width: CGFloat(48), height: CGFloat(48))
        button.backgroundColor = .clear
        let buttonIcon = UIImage(named: "add")
        button.setImage(buttonIcon, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.5)
        button.addTarget(self, action: #selector(buttonPress), for: .touchUpInside)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        self.sceneView.addSubview(button)
    }
}





