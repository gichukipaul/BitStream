//
//  MainView.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = DownloadViewModel()
    
    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.windowBackgroundColor).opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            HStack(spacing: 24) {
                // Left Panel - Download Configuration
                DownloadConfigurationView(viewModel: viewModel)
                    .frame(maxWidth: 420)
                
                // Vertical divider with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                // Right Panel - Progress and Recent Downloads
                VStack(spacing: 20) {
                    DownloadProgressView(viewModel: viewModel)
                    RecentDownloadsView(viewModel: viewModel)
                }
                .frame(minWidth: 500)
            }
            .padding(24)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    MainView()
        .frame(width: 1000, height: 600)
}
