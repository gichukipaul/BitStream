//
//  MainView.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = DownloadViewModel()
    @State private var isHoveringDownloadButton = false
    
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
                VStack(alignment: .leading, spacing: 20) {
                    downloadConfigurationSection
                    Spacer()
                }
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
                    progressSection
                    recentDownloadsSection
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
    
    // MARK: - Download Configuration Section
    private var downloadConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with icon
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Download Configuration")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // URL Input Card
            VStack(alignment: .leading, spacing: 8) {
                Label("Media URL", systemImage: "link")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("https://youtube.com/watch?v=...", text: $viewModel.videoURL)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.videoURL.isEmpty ? Color.clear : Color.blue.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Mode Toggle Card
            VStack(alignment: .leading, spacing: 8) {
                Label("Download Mode", systemImage: "square.stack.3d.down.right")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Picker("Mode", selection: $viewModel.downloadMode) {
                    ForEach(DownloadMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                )
            }
            
            // Format Selection
            formatSelectionView
            
            // Output Folder Card
            VStack(alignment: .leading, spacing: 8) {
                Label("Download Folder", systemImage: "folder.badge.plus")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(viewModel.outputPath.isEmpty ? "No folder selected" : URL(fileURLWithPath: viewModel.outputPath).lastPathComponent)
                        .foregroundColor(viewModel.outputPath.isEmpty ? .secondary : .primary)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: { viewModel.selectOutputFolder() }) {
                        Text("Browse")
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                )
            }
            
            // Extra Arguments Card
            VStack(alignment: .leading, spacing: 8) {
                Label("Extra Arguments", systemImage: "terminal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("--subtitle-lang en --embed-thumbnail", text: $viewModel.extraArguments)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    )
            }
            
            // Download Button
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
                .scaleEffect(isHoveringDownloadButton ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHoveringDownloadButton)
                .onHover { hovering in
                    isHoveringDownloadButton = hovering
                }
                
                if !viewModel.statusMessage.isEmpty {
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
        }
    }
    
    // MARK: - Format Selection View
    private var formatSelectionView: some View {
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
                } else {
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
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            )
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Download Progress")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.isDownloading {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                            .scaleEffect(1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                value: viewModel.isDownloading
                            )
                        Text("Active")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                    )
                }
            }
            
            if viewModel.isDownloading {
                VStack(spacing: 16) {
                    // Enhanced Progress Bar
                    VStack(spacing: 8) {
                        CustomProgressView(value: viewModel.downloadProgress.percentage)
                        
                        HStack {
                            Text("\(Int(viewModel.downloadProgress.percentage * 100))%")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Spacer()
                            
                            if !viewModel.downloadProgress.speed.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "speedometer")
                                        .font(.caption)
                                    Text(viewModel.downloadProgress.speed)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                            }
                            
                            if !viewModel.downloadProgress.eta.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                    Text(viewModel.downloadProgress.eta)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if !viewModel.downloadProgress.filename.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                            Text(viewModel.downloadProgress.filename)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .truncationMode(.middle)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !viewModel.downloadProgress.totalSize.isEmpty {
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(viewModel.downloadProgress.downloadedSize.isEmpty ? "—" : viewModel.downloadProgress.downloadedSize)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "externaldrive.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text(viewModel.downloadProgress.totalSize)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No active downloads")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                )
            }
        }
    }
    
    // MARK: - Recent Downloads Section
    private var recentDownloadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Recent Downloads")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.storageServicePublisher.clearRecentDownloads()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text("Clear All")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(viewModel.storageServicePublisher.recentDownloads.isEmpty)
            }
            
            if viewModel.storageServicePublisher.recentDownloads.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No recent downloads")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.storageServicePublisher.recentDownloads) { item in
                            RecentDownloadRow(
                                item: item,
                                onRevealInFinder: { viewModel.storageServicePublisher.revealInFinder(item) },
                                onRemove: { viewModel.storageServicePublisher.removeDownload(item) }
                            )
                        }
                    }
                    .padding(2)
                }
                .frame(maxHeight: 300)
            }
        }
    }
}

// MARK: - Gradient Button Style
struct GradientButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.purple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(configuration.isPressed ? 0.8 : 1.0)
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
            )
            .cornerRadius(12)
            .shadow(
                color: isEnabled ? Color.blue.opacity(0.3) : Color.clear,
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    MainView()
        .frame(width: 1000, height: 600)
}
