//
//  File.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import Foundation

extension Dictionary {
    func keysToCamelCase() -> Dictionary {
        let keys = Array(self.keys)
        let values = Array(self.values)
        var dict: Dictionary = [:]
        
        keys.enumerated().forEach { (index, orginalKey) in
            var key = orginalKey
            var value = values[index]
            
            if let v = value as? Dictionary,
               let vl = v.keysToCamelCase() as? Value {
                value = vl
            }
            
            if let k = key as? String,
               let ky = k.camelCased(with: "_") as? Key {
                key = ky
            }
            
            dict[key] = value
        }
        
        return dict
    }
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let jsonData = try JSONSerialization.data(withJSONObject: self)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func jsonPresentation() {
        print(json)
    }
}
