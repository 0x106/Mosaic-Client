//
//  Fonts.swift
//  Client
//
//  Created by Jordan Campbell on 30/01/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import Alamofire
import SSZipArchive

class Fonts {

    func load() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentsUrl.appendingPathComponent("font.ttf")
        let destination: DownloadRequest.DownloadFileDestination = {
            _, _ in
            return (fileUrl, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        Alamofire.download("http://fonts.gstatic.com/s/roboto/v18/W5F8_SL0XFawnjxHGsZjJA.ttf", to: destination)
            .response {
                response in
                if response.destinationURL != nil {
                    let fontData = NSData(contentsOf: fileUrl)
                    let dataProvider = CGDataProvider(data: fontData!)
                    let cgFont = CGFont(dataProvider!)
                    var errorFont: Unmanaged<CFError>?
                    if CTFontManagerRegisterGraphicsFont(cgFont!, &errorFont) {
                        print("font loaded")
                    }
                }
        }
    }
    
    
//    func getFont(_ name: String) {
//
//        var documentsURL = URL(fileURLWithPath: "")
//        var zippedFile = URL(fileURLWithPath: "")
//        var unzippedURL = URL(fileURLWithPath: "")
//
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
//            zippedFile = documentsURL.appendingPathComponent("font.ttf")
//            unzippedURL = documentsURL.appendingPathComponent("font/")
//
////            do {
////                try FileManager.default.createDirectory(at: unzippedURL, withIntermediateDirectories: true, attributes: nil)
////            } catch {}
//
//            return (zippedFile, [.removePreviousFile, .createIntermediateDirectories])
//        }
//
//        Alamofire.download("http://themes.googleusercontent.com/static/fonts/anonymouspro/v3/Zhfjj_gat3waL4JSju74E-V_5zh5b-_HiooIRUBwn1A.ttf", to: destination).response { response in
//            print(response)
//
////            print("Input: \(zippedFile)")
////            print("Output: \(unzippedURL)")
////
////            let success: Bool = SSZipArchive.unzipFile(atPath: String(describing: zippedFile),
////                                                       toDestination: String(describing: unzippedURL))
////            print("Success: \(success)")
//            exit(EXIT_SUCCESS)
//        }
//
//    }
//
//    static func loadFontFromFile(fontName: String, baseFolderPath: String) -> Bool {
//
////        NSData *inData =
////        CFErrorRef error;
////        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
////        CGFontRef font = CGFontCreateWithDataProvider(provider);
////        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
////            CFStringRef errorDescription = CFErrorCopyDescription(error)
////            NSLog(@"Failed to load font: %@", errorDescription);
////            CFRelease(errorDescription);
////        }
////        CFRelease(font);
////        CFRelease(provider);
//
////        let basePath = baseFolderPath as NSString
////        let fontFilePath = basePath.appendingPathComponent(fontName)
////        let fontUrl = NSURL(fileURLWithPath: fontFilePath)
////        if let inData = NSData(contentsOf: fontUrl as URL) {
////            var error: Unmanaged<CFError>?
////            let cfdata = CFDataCreate(nil, UnsafePointer<UInt8>(inData.bytes), inData.length)
////            if let provider = CGDataProviderCreateWithCFData(cfdata) {
////                if let font = CGFontCreateWithDataProvider(provider) {
////                    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
////                        Logger.info("Failed to load font: \(error)")
////                    }
////                    return true
////                }
////            }
////        }
////        return false
//    }

    
}
