//
//  TirelessError.swift
//  Tireless
//
//  Created by Hao on 2022/5/25.
//

import Foundation

enum TirelessError: Error {
    case firebaseError
    
    var text: String {
        
        switch self {
            
        case .firebaseError: return "錯誤"
            
        }
    }
}
