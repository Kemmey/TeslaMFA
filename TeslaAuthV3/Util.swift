//
//  Util.swift
//  TeslaAuthV3
//
//  Created by Kim Hansen on 02/11/2020.
//

import Foundation
import CryptoKit


let kTeslaClientID = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384"
let kTeslaSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"

extension String {
    
    var sha256:String {
           get {
            let inputData = Data(self.utf8)
            let hashed = SHA256.hash(data: inputData)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
           }
       }
    
    func base64EncodedString() -> String {
        let inputData = Data(self.utf8)
        return inputData.base64EncodedString()
    }
}
