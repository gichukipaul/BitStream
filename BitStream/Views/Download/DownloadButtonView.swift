//
//  DownloadButtonView.swift
//  BitStream
//
//  Created by GICHUKI on 05/10/2025.
//

import SwiftUI

struct DownloadButtonView: View {
    @ObservedObject var viewModel: DownloadViewModel
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                if viewModel.isDownloading {
                    viewModel.cancelDownload()
                } else {
                    viewModel.startDownload()
                }
            }) {
                HStack(spacing: 10) {
                    if viewModel.isDownloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                        Text("Cancel Download")
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                        Text("Start Download")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(GradientButtonStyle(isEnabled: !viewModel.videoURL.isEmpty && !viewModel.outputPath.isEmpty))
            .disabled(viewModel.videoURL.isEmpty || viewModel.outputPath.isEmpty)
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
            
            if !viewModel.statusMessage.isEmpty {
                statusMessageView
            }
        }
    }
    
    private var statusMessageView: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
            Text(viewModel.statusMessage)
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}
