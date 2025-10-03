//
//  ActiveDownloadRow.swift
//  BitStream
//
//  Created by GICHUKI on 29/09/2025.
//

import SwiftUI

struct ActiveDownloadRow: View {
    let download: ActiveDownload
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with title and status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(download.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    HStack {
                        Text(download.mode.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(download.mode == .video ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                            .foregroundColor(download.mode == .video ? .blue : .green)
                            .cornerRadius(4)
                        
                        Text(download.status.displayText)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(download.status.color.opacity(0.1))
                            .foregroundColor(download.status.color)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Cancel button (only show for active downloads)
                if case .downloading = download.status {
                    Button(action: {
                        print("Cancel button tapped for download: \(download.id)")
                        onCancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Cancel download")
                } else if case .queued = download.status {
                    Button(action: {
                        print("Remove button tapped for download: \(download.id)")
                        onCancel()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Remove from queue")
                }
            }
            
            // Progress bar and details (only for downloading)
            if case .downloading = download.status {
                VStack(spacing: 6) {
                    CustomProgressView(value: download.progress.percentage)
                        .frame(height: 6)
                    
                    HStack {
                        Text("\(Int(download.progress.percentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !download.progress.speed.isEmpty {
                            Text(download.progress.speed)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !download.progress.eta.isEmpty {
                            Text("ETA: \(download.progress.eta)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !download.progress.filename.isEmpty {
                        Text(download.progress.filename)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(download.status.color.opacity(0.3), lineWidth: 1)
        )
    }
}
