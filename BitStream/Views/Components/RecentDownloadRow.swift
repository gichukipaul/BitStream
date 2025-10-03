//
//  RecentDownloadRow.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import SwiftUI

// MARK: - Recent Download Row
struct RecentDownloadRow: View {
    let item: DownloadItem
    let onRevealInFinder: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // File info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack {
                    Text(item.mode)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text(item.format)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(item.downloadDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: {
                    print("Reveal in Finder tapped for: \(item.title)")
                    onRevealInFinder()
                }) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Reveal in Finder")
                .disabled(!item.exists)
                
                Button(action: {
                    print("Remove tapped for: \(item.title)")
                    onRemove()
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Remove from list")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .opacity(item.exists ? 1.0 : 0.5)
    }
}

#Preview("Recent Download Row") {
    RecentDownloadRow(
        item: DownloadItem(
            url: "https://youtube.com/watch?v=example",
            title: "Sample Video Title - This is a long title to test truncation",
            filename: "sample_video.mp4",
            filePath: "/Users/username/Downloads/sample_video.mp4",
            downloadDate: Date(),
            mode: "Video",
            format: "1080p MP4"
        ),
        onRevealInFinder: { print("Reveal in Finder") },
        onRemove: { print("Remove item") }
    )
    .padding()
    .frame(width: 400)
}
