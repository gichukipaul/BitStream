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
        HStack(spacing: 20) {
            // Left Panel - Download Configuration
            VStack(alignment: .leading, spacing: 16) {
                downloadConfigurationSection
                Spacer()
            }
            .frame(maxWidth: 400)
            
            Divider()
            
            // Right Panel - Progress and Recent Downloads
            VStack(spacing: 16) {
                progressSection
                recentDownloadsSection
            }
            .frame(minWidth: 500)
        }
        .padding()
        .frame(minWidth: 1000, minHeight: 600)
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Download Configuration Section
    private var downloadConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Download Configuration")
                .font(.headline)
                .foregroundColor(.primary)
            
            // URL Input
            VStack(alignment: .leading, spacing: 4) {
                Text("Media URL")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("https://youtube.com/watch?v=...", text: $viewModel.videoURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Mode Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Download Mode")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Mode", selection: $viewModel.downloadMode) {
                    ForEach(DownloadMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Format Selection
            formatSelectionView
            
            // Output Folder
            VStack(alignment: .leading, spacing: 8) {
                Text("Download Folder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(viewModel.outputPath.isEmpty ? "No folder selected" : URL(fileURLWithPath: viewModel.outputPath).lastPathComponent)
                        .foregroundColor(viewModel.outputPath.isEmpty ? .secondary : .primary)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Browse...") {
                        viewModel.selectOutputFolder()
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
            }
            
            // Extra Arguments
            VStack(alignment: .leading, spacing: 4) {
                Text("Extra Arguments (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("--subtitle-lang en --embed-thumbnail", text: $viewModel.extraArguments)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Download Button
            VStack {
                Button(action: {
                    viewModel.startDownload()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Queue")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(viewModel.videoURL.isEmpty || viewModel.outputPath.isEmpty)
                
                // Queue Status
                if viewModel.hasActiveDownloads {
                    HStack {
                        Text("Downloading: \(viewModel.downloadingCount)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Queued: \(viewModel.queuedCount)")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button("Cancel All") {
                            viewModel.cancelAllDownloads()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .font(.caption)
                    }
                }
                
                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // MARK: - Format Selection View
    private var formatSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.downloadMode == .video {
                Text("Video Quality")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Video Format", selection: $viewModel.selectedVideoFormat) {
                    ForEach(VideoFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Text("Container Format")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Container Format", selection: $viewModel.selectedContainerFormat) {
                    ForEach(ContainerFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
            } else {
                Text("Audio Format & Quality")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Picker("Audio Format", selection: $viewModel.selectedAudioFormat) {
                        ForEach(AudioFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    Picker("Quality", selection: $viewModel.selectedAudioQuality) {
                        ForEach(AudioQuality.allCases) { quality in
                            Text(quality.displayName).tag(quality)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Downloads")
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.downloadServicePublisher.activeDownloads.isEmpty {
                Text("No active downloads")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.downloadServicePublisher.activeDownloads) { download in
                            ActiveDownloadRow(
                                download: download,
                                onCancel: { viewModel.cancelDownload(download.id) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
    }
    
    // MARK: - Recent Downloads Section
    private var recentDownloadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Downloads")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Clear All") {
                    viewModel.storageServicePublisher.clearRecentDownloads()
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(viewModel.storageServicePublisher.recentDownloads.isEmpty)
            }
            
            if viewModel.storageServicePublisher.recentDownloads.isEmpty {
                Text("No recent downloads")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.storageServicePublisher.recentDownloads) { item in
                            RecentDownloadRow(
                                item: item,
                                onRevealInFinder: { viewModel.storageServicePublisher.revealInFinder(item) },
                                onRemove: { viewModel.storageServicePublisher.removeDownload(item) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }
}

#Preview {
    MainView()
        .frame(width: 1000, height: 600)
}
