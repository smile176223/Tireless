//
//  ActivityIndicatorView.swift
//  Tireless
//
//  Created by Liam on 2024/1/5.
//

import SwiftUI

public struct ActivityIndicatorView: View {

    @Binding var isVisible: Bool

    public init(isVisible: Binding<Bool>) {
        _isVisible = isVisible
    }

    public var body: some View {
        if isVisible {
            indicator
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Private
    
    private var indicator: some View {
        ZStack {
            IndicatorView(count: 5)
        }
    }
}
