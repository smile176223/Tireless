//
//  UIColor+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/4/19.
//

import UIKit

private enum TirelessColor: String {

    case themeBG
    
    case themeBGSecond
    
    case themeYellow
    
}

extension UIColor {

    static let themeBG = tirelessColor(.themeBG)
    
    static let themeBGSecond = tirelessColor(.themeBGSecond)
    
    static let themeYellow = tirelessColor(.themeYellow)
    
    private static func tirelessColor(_ color: TirelessColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }
}
