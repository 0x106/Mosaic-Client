//
//  Performance.swift
//  Client
//
//  Created by Jordan Campbell on 8/02/18.
//  Copyright © 2018 Atlas Innovation. All rights reserved.
//

import Foundation
import ARKit

class PerformanceMeasure {
    
    private var counter: Dictionary<String, Int> = Dictionary<String,Int>()
    private var performance: Dictionary<String, Double> = Dictionary<String,Double>()
    private var asyncPerformance: Dictionary<String, Double> = Dictionary<String,Double>()
    
    var measurePerformance: Bool = true
    
    func measure(_ key: String, function: () -> Void) {
        
        let startTime = CACurrentMediaTime()
        function()
        let endTime = CACurrentMediaTime()
        
        let result: Double = endTime - startTime
        
        if let _ = performance[key] {
            performance[key]! += result
            counter[key]! += 1
        } else {
            performance[key] = result
            counter[key] = 1
        }
    }
    
    func start(_ _key: String) {
        let startTime = CACurrentMediaTime()
        asyncPerformance[ _key ] = startTime
    }
    
    func stop(_ _key: String) {
        let stopTime = CACurrentMediaTime()
        let startTime = asyncPerformance[ _key ]!
        
        asyncPerformance[ _key ] = stopTime - startTime
    }
    
    private func collectAsync() {
        for (key, value) in asyncPerformance {
            if key.hasPrefix("*") {
                
                let id = String(key.split(separator: "-")[0])
                
                var acc: Double = 0.0
                var count: Int = 0
                
                for (_keys, _) in asyncPerformance {
                    if _keys.hasPrefix(id) {
                        acc += asyncPerformance[_keys]!
                        count += 1
                    }
                }
                
                performance[id] = acc / Double(count)
                counter[id] = 1
            }
        }
    }
    
    func results() {
        
        self.collectAsync()
        
        self.computeStatistics()
        let sortedKeys: [String] = performance.sortedKeysByValue(isOrderedBefore: <)
        
        print("")
        print("======== Atlas Performance Results ========")
        print("")
        
        for key in sortedKeys {
            print("\(key): \(performance[key]!) [\(counter[key]!)]")
        }
        
        print("")
        print("===========================================")
        print("")
        
    }
    
    private func computeStatistics() {
        for (key, value) in performance {
            let average: Double = value / Double(counter[key]!)
            performance[key] = average
        }
    }
    
}


extension Dictionary {
    
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory (this is equivalent to Pascals answer in an generic extension)
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
}



func testAsyncPerformance() {
    
    let group = DispatchGroup()
    
    performance.measure("two loops") {
        performance.start("*innerloop-0")
        
        for idx in 0..<10 {
            
            let worker = DispatchQueue(label: "worker", qos: .userInitiated)
            worker.async {
                group.enter()
                for kdx in 0..<10000 { let sum = idx + kdx}
                group.leave()
            }
            
        }
        
        group.notify(queue: .main) {
            performance.stop("*innerloop-0")
            performance.results()
            exit()
        }
    }
    
}

