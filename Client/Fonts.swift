//
//  Fonts.swift
//  Client
//
//  Created by Jordan Campbell on 30/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import Alamofire

class AtlasFont {
    var name: String = ""
    var url: String = ""
    var file: String = ""
    var weight: String = ""
    var fileURL: URL = URL(fileURLWithPath: "")
    var fontDescriptor: String = ""
    var font: UIFont = UIFont()
    var isAvailable: Bool = false
    var size: Float = 0.0
    
    init(_ key: String, _ value: String, _ weight: String, _ size: Float) {
        self.name = key
        self.url = value
        self.weight = weight
        self.size = size
        if !(self.url == "") {
            self.load(self.url)
        } else {
            self.fontDescriptor = self.name
        }
        
        self.set()
    }
    
    func load(_ fontURL: String) {
        
        print("Loading Google Font with: name = \(self.name), url = \(self.url) and weight = \(self.weight)")
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsUrl.appendingPathComponent("\(self.name)-\(self.weight).ttf")
        
        if let fontData = NSData(contentsOf: self.fileURL) {
            print("Retrieving font from local file.")
            self.create(fontData)
        } else {
            
            print("Retrieving font from url.")
            
            let destination: DownloadRequest.DownloadFileDestination = {
                _, _ in
                return (self.fileURL, [.createIntermediateDirectories, .removePreviousFile])
            }
            
            Alamofire.download(fontURL, to: destination)
                .response {
                    response in
                    if response.destinationURL != nil {
                        if let fontData = NSData(contentsOf: self.fileURL) {
                            self.create(fontData)
                        }
                    }
            }
        }
    }
    
    private func create(_ fontData: NSData) {
        let dataProvider = CGDataProvider(data: fontData)
        let cgFont = CGFont(dataProvider!)
        var errorFont: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont!, &errorFont) {} else {}

        var fontNameArray = ((cgFont?.fullName)! as String).split(separator: " ")
        if fontNameArray.count == 2 {
            self.fontDescriptor = fontNameArray[0] + "-" + (fontNameArray[1].lowercased())
        } else if fontNameArray.count == 1 {
            self.fontDescriptor = String(fontNameArray[0])
        } else {
            
        }
    }
    
    private func set() {
        self.isAvailable = true
        guard let tmpFont = UIFont(name: self.fontDescriptor, size: CGFloat(self.size)) else {
            self.isAvailable = false
            return
        }
        
        self.font = tmpFont
    }
}
