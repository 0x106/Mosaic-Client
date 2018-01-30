//
//  Fonts.swift
//  Client
//
//  Created by Jordan Campbell on 30/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import Alamofire

class Fonts {
    
    func getFont(_ name: String) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("font.zip")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download("https://fonts.google.com/download?family=Source%20Sans%20Pro", to: destination).response { response in
            print(response)
//            if response.error == nil, let imagePath = response.destinationURL?.path {
//                let image = UIImage(contentsOfFile: imagePath)
//            }
        }
        
    }
    
}
