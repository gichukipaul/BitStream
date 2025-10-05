//
//  DownloadConfigurationView.swift
//  BitStream
//
//  Created by GICHUKI on 05/10/2025.
//

import SwiftUI

struct DownloadConfigurationView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            urlInputSection
            modeToggleSection
            FormatSelectionView(viewModel: viewModel)
            outputFolderSection
            extraArgumentsSection
            DownloadButtonView(viewModel: viewModel)
            Spacer()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
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
    }
    
    // MARK: - URL Input Section
    private var urlInputSection: some View {
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
    }
    
    // MARK: - Mode Toggle Section
    private var modeToggleSection: some View {
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
    }
    
    // MARK: - Output Folder Section
    private var outputFolderSection: some View {
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
    }
    
    // MARK: - Extra Arguments Section
    private var extraArgumentsSection: some View {
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
    }
}
