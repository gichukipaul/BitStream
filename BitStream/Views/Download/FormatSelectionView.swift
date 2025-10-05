//
//  FormatSelectionView.swift
//  BitStream
//
//  Created by GICHUKI on 05/10/2025.
//

import SwiftUI

struct FormatSelectionView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                viewModel.downloadMode == .video ? "Quality & Format" : "Audio Settings",
                systemImage: viewModel.downloadMode == .video ? "film" : "music.note"
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                if viewModel.downloadMode == .video {
                    videoFormatSection
                } else {
                    audioFormatSection
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            )
        }
    }
    
    // MARK: - Video Format Section
    private var videoFormatSection: some View {
        Group {
            // Video Quality
            VStack(alignment: .leading, spacing: 6) {
                Text("Video Quality")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Video Format", selection: $viewModel.selectedVideoFormat) {
                    ForEach(VideoFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            
            // Container Format
            VStack(alignment: .leading, spacing: 6) {
                Text("Container Format")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Container Format", selection: $viewModel.selectedContainerFormat) {
                    ForEach(ContainerFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
        }
    }
    
    // MARK: - Audio Format Section
    private var audioFormatSection: some View {
        HStack(spacing: 12) {
            // Audio Format
            VStack(alignment: .leading, spacing: 6) {
                Text("Format")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Audio Format", selection: $viewModel.selectedAudioFormat) {
                    ForEach(AudioFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            .frame(maxWidth: .infinity)
            
            // Audio Quality
            VStack(alignment: .leading, spacing: 6) {
                Text("Quality")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Quality", selection: $viewModel.selectedAudioQuality) {
                    ForEach(AudioQuality.allCases) { quality in
                        Text(quality.displayName).tag(quality)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}
