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
    
    @State private var animatedValue: Double = 0
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with subtle gradient
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(NSColor.separatorColor).opacity(0.3),
                                Color(NSColor.separatorColor).opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 12)
                
                // Progress fill with gradient
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.purple,
                                    Color.pink
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(min(animatedValue / total, 1.0)), height: 12)
                    
                    // Shimmer effect overlay
                    if animatedValue > 0 && animatedValue < total {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 80)
                        .offset(x: shimmerOffset * geometry.size.width)
                        .mask(
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: geometry.size.width * CGFloat(min(animatedValue / total, 1.0)), height: 12)
                        )
                    }
                }
                
                // Subtle inner shadow for depth
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                    .frame(height: 12)
            }
        }
        .frame(height: 12)
        .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
        .onChange(of: value) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedValue = newValue
            }
        }
        .onAppear {
            animatedValue = value
            
            // Start shimmer animation
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 2
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        VStack(alignment: .leading, spacing: 8) {
            Text("0% - Starting")
                .font(.caption)
                .foregroundColor(.secondary)
            CustomProgressView(value: 0.0)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("30% - In Progress")
                .font(.caption)
                .foregroundColor(.secondary)
            CustomProgressView(value: 0.3)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("70% - Almost There")
                .font(.caption)
                .foregroundColor(.secondary)
            CustomProgressView(value: 0.7)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("100% - Complete")
                .font(.caption)
                .foregroundColor(.secondary)
            CustomProgressView(value: 1.0)
        }
    }
    .padding(40)
    .frame(width: 400)
    .background(Color(NSColor.windowBackgroundColor))
}
