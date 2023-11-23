//
//  View+Extension.swift
//  Tireless
//
//  Created by Liam on 2023/11/23.
//

import SwiftUI

extension View {
    public func hideKeyboardOnTap() -> some View {
        onTapGesture {
            let resign = #selector(UIResponder.resignFirstResponder)
            UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
        }
    }
}
