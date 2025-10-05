//
//  RecentDownloadsView.swift
//  BitStream
//
//  Created by GICHUKI on 05/10/2025.
//

import SwiftUI

struct RecentDownloadsView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            
            //Access recentDownloads directly from viewModel
            if viewModel.recentDownloads.isEmpty {
                emptyStateView
            } else {
                downloadsListView
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
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
            
            clearAllButton
        }
    }
    
    // MARK: - Clear All Button
    private var clearAllButton: some View {
        Button(action: {
            // FIXED: Call viewModel method directly
            viewModel.clearRecentDownloads()
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
        .disabled(viewModel.recentDownloads.isEmpty)
    }
    
    // MARK: - Downloads List View
    private var downloadsListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                //Access recentDownloads directly from viewModel
                ForEach(viewModel.recentDownloads) { item in
                    RecentDownloadRow(
                        item: item,
                        //Call viewModel methods directly
                        onRevealInFinder: { viewModel.revealInFinder(item) },
                        onRemove: { viewModel.removeDownload(item) }
                    )
                }
            }
            .padding(2)
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
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
    }
}
