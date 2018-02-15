//
//  NodeUserInterface.swift
//  Client
//
//  Created by Jordan Campbell on 15/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

extension Node {
    func setActive() {
        
        let scaleChange: Float = 1.1
        let motionChange: Float = 0.4
        let duration: Double = 0.6
        if self.isActive {
            
            let forwardVector = SCNVector3Make(0, 0, -motionChange)
            
            let motion = SCNAction.move(by: forwardVector, duration: duration)
            let scale = SCNAction.scale(by: CGFloat(1.0 / scaleChange), duration: duration)
            
            self.rootNode.runAction(SCNAction.group([motion, scale]))
            
            self.isActive = false
            
        } else {
            let forwardVector = SCNVector3Make(0, 0, motionChange)
            
            let motion = SCNAction.move(by: forwardVector, duration: duration)
            let scale = SCNAction.scale(by: CGFloat(scaleChange), duration: duration)
            
            self.rootNode.runAction(SCNAction.group([motion, scale]))
            self.isActive = true
        }
    }

    @objc func updateUserInput(_ textField: UITextField) {
        self.text = textField.text!
        print("Updated node text: \(self.text)")
        let _ = self.render()
    }

    func addNewTextField(_ key: String) -> UITextField? {
        self.inputField = UITextField()
        self.inputField!.addTarget(self, action: #selector( self.updateUserInput(_:) ), for: .editingChanged)
        self.inputField!.autocapitalizationType = UITextAutocapitalizationType.none;
        self.inputField!.becomeFirstResponder()
        return self.inputField
    }

    func removeTextField(_ key: String) {
        guard let field = self.inputField else {return}
        field.resignFirstResponder()
        self.inputField = nil
    }
}
