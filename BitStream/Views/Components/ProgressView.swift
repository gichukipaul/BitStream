//
//  ProgressView.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import SwiftUI

struct CustomProgressView: View {
    let value: Double
    let total: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .foregroundColor(Color(NSColor.separatorColor))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                // Progress fill
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * CGFloat(min(value / total, 1.0)), height: 8)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.2), value: value)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomProgressView(value: 0.0)
        CustomProgressView(value: 0.3)
        CustomProgressView(value: 0.7)
        CustomProgressView(value: 1.0)
    }
    .padding()
}
