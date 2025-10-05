//
//  DownloadProgressView.swift
//  BitStream
//
//  Created by GICHUKI on 05/10/2025.
//

import SwiftUI

struct DownloadProgressView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            
            if viewModel.isDownloading {
                activeDownloadView
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
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
                activeStatusBadge
            }
        }
    }
    
    // MARK: - Active Status Badge
    private var activeStatusBadge: some View {
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
    
    // MARK: - Active Download View
    private var activeDownloadView: some View {
        VStack(spacing: 16) {
            // Enhanced Progress Bar
            VStack(spacing: 8) {
                CustomProgressView(value: viewModel.downloadProgress.percentage)
                progressDetailsRow
            }
            
            if !viewModel.downloadProgress.filename.isEmpty {
                filenameRow
            }
            
            if !viewModel.downloadProgress.totalSize.isEmpty {
                sizeDetailsRow
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Progress Details Row
    private var progressDetailsRow: some View {
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
    
    // MARK: - Filename Row
    private var filenameRow: some View {
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
    
    // MARK: - Size Details Row
    private var sizeDetailsRow: some View {
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
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
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
