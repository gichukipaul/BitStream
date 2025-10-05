//
//  RecentDownloadRow.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import SwiftUI

struct RecentDownloadRow: View {
    let item: DownloadItem
    let onRevealInFinder: () -> Void
    let onRemove: () -> Void
    
    @State private var isHoveringRow = false
    @State private var isHoveringReveal = false
    @State private var isHoveringRemove = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon based on file type
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: item.mode == "Video" ? [.blue.opacity(0.2), .purple.opacity(0.2)] : [.pink.opacity(0.2), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.mode == "Video" ? "film.fill" : "music.note")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: item.mode == "Video" ? [.blue, .purple] : [.pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // File info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Mode badge
                    HStack(spacing: 4) {
                        Image(systemName: item.mode == "Video" ? "video.fill" : "waveform")
                            .font(.system(size: 9))
                        Text(item.mode)
                            .font(.system(size: 10))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                item.mode == "Video"
                                ? Color.blue.opacity(0.15)
                                : Color.pink.opacity(0.15)
                            )
                    )
                    .foregroundColor(item.mode == "Video" ? .blue : .pink)
                    
                    // Format badge
                    Text(item.format)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(NSColor.separatorColor).opacity(0.3))
                        )
                    
                    Spacer()
                    
                    // Date
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(item.downloadDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 8)
            
            // Action buttons
            HStack(spacing: 6) {
                // Reveal in Finder button
                Button(action: onRevealInFinder) {
                    ZStack {
                        Circle()
                            .fill(isHoveringReveal ? Color.blue.opacity(0.15) : Color.clear)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "folder.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isHoveringReveal ? .blue : .secondary)
                    }
                }
                .buttonStyle(.plain)
                .help("Reveal in Finder")
                .disabled(!item.exists)
                .opacity(item.exists ? 1.0 : 0.5)
                .scaleEffect(isHoveringReveal && item.exists ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHoveringReveal)
                .onHover { hovering in
                    isHoveringReveal = hovering
                }
                
                // Remove button
                Button(action: onRemove) {
                    ZStack {
                        Circle()
                            .fill(isHoveringRemove ? Color.red.opacity(0.15) : Color.clear)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isHoveringRemove ? .red : .secondary)
                    }
                }
                .buttonStyle(.plain)
                .help("Remove from list")
                .scaleEffect(isHoveringRemove ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHoveringRemove)
                .onHover { hovering in
                    isHoveringRemove = hovering
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(
                    color: Color.black.opacity(isHoveringRow ? 0.08 : 0.04),
                    radius: isHoveringRow ? 8 : 4,
                    x: 0,
                    y: isHoveringRow ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: isHoveringRow ? [.blue.opacity(0.2), .purple.opacity(0.2)] : [.clear, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHoveringRow ? 1 : 0
                )
        )
        .opacity(item.exists ? 1.0 : 0.6)
        .scaleEffect(isHoveringRow ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHoveringRow)
        .onHover { hovering in
            isHoveringRow = hovering
        }
    }
}

#Preview("Recent Download Row - Video") {
    VStack(spacing: 12) {
        RecentDownloadRow(
            item: DownloadItem(
                url: "https://youtube.com/watch?v=example",
                title: "Amazing Tutorial: Learn SwiftUI in 2024",
                filename: "tutorial_video.mp4",
                filePath: "/Users/username/Downloads/tutorial_video.mp4",
                downloadDate: Date(),
                mode: "Video",
                format: "1080p MP4"
            ),
            onRevealInFinder: { print("Reveal in Finder") },
            onRemove: { print("Remove item") }
        )
        
        RecentDownloadRow(
            item: DownloadItem(
                url: "https://youtube.com/watch?v=example2",
                title: "Relaxing Music for Studying",
                filename: "study_music.mp3",
                filePath: "/Users/username/Downloads/study_music.mp3",
                downloadDate: Date().addingTimeInterval(-3600),
                mode: "Audio",
                format: "320kbps MP3"
            ),
            onRevealInFinder: { print("Reveal in Finder") },
            onRemove: { print("Remove item") }
        )
    }
    .padding()
    .frame(width: 500)
}
