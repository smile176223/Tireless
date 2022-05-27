//
//  Lottie+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/5/18.
//

import Foundation

enum Lottie {
    case countDownGo

    case progressBar

    case detectDone

    case loading

    case squat

    case plank

    case pushup
    
    var name: String {
        
        switch self {
            
        case .countDownGo: return "CountDownGo"
            
        case .progressBar: return "ProgressBar"
            
        case .detectDone: return "DetectDone"
            
        case .loading: return "Loading"
            
        case .squat: return "Squat"
            
        case .plank: return "Plank"
            
        case .pushup: return "Pushup"
            
        }
    }
}
