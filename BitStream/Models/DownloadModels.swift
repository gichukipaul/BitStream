//
//  DownloadModels.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Download Types
enum DownloadMode: String, CaseIterable {
    case video = "Video"
    case audio = "Audio"
}

enum VideoFormat: String, CaseIterable, Identifiable {
    case best = "best"
    case worst = "worst"
    case video_1080 = "bv[height<=1080]+ba"
    case video_720 = "bv[height<=720]+ba"
    case video_480 = "bv[height<=480]+ba"
    case video_1440 = "bv[height<=1440]+ba"
    case video_2160 = "bv[height<=2160]+ba"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .best: return "Best Available"
        case .worst: return "Worst Available"
        case .video_1080: return "1080p (Best Video + Audio)"
        case .video_720: return "720p (Best Video + Audio)"
        case .video_480: return "480p (Best Video + Audio)"
        case .video_1440: return "1440p (Best Video + Audio)"
        case .video_2160: return "4K/2160p (Best Video + Audio)"
        }
    }
}

enum ContainerFormat: String, CaseIterable, Identifiable {
    case mkv = "mkv"
    case mp4 = "mp4"
    case webm = "webm"
    case avi = "avi"
    case mov = "mov"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .mkv: return "MKV (Matroska)"
        case .mp4: return "MP4"
        case .webm: return "WebM"
        case .avi: return "AVI"
        case .mov: return "MOV (QuickTime)"
        }
    }
}

enum AudioFormat: String, CaseIterable, Identifiable {
    case mp3 = "mp3"
    case m4a = "m4a"
    case opus = "opus"
    case flac = "flac"
    case wav = "wav"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .mp3: return "MP3"
        case .m4a: return "M4A"
        case .opus: return "Opus"
        case .flac: return "FLAC"
        case .wav: return "WAV"
        }
    }
}

enum AudioQuality: String, CaseIterable, Identifiable {
    case best = "0"
    case high = "2"
    case medium = "5"
    case low = "9"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .best: return "Best"
        case .high: return "High (320kbps)"
        case .medium: return "Medium (128kbps)"
        case .low: return "Low (64kbps)"
        }
    }
}

// MARK: - Download Progress
struct DownloadProgress {
    var percentage: Double = 0.0
    var speed: String = ""
    var eta: String = ""
    var totalSize: String = ""
    var downloadedSize: String = ""
    var filename: String = ""
}

// MARK: - Active Download
struct ActiveDownload: Identifiable {
    let id = UUID()
    let url: String
    let title: String
    let mode: DownloadMode
    let videoFormat: VideoFormat?
    let containerFormat: ContainerFormat?
    let audioFormat: AudioFormat?
    let audioQuality: AudioQuality?
    let outputPath: String
    let extraArgs: [String]
    var progress: DownloadProgress = DownloadProgress()
    var status: DownloadStatus = .queued
    let startTime: Date = Date()
    
    var displayTitle: String {
        return title.isEmpty ? "Download \(id.uuidString.prefix(8))" : title
    }
}

enum DownloadStatus {
    case queued
    case downloading
    case completed
    case failed(String)
    case cancelled
    
    var displayText: String {
        switch self {
        case .queued: return "Queued"
        case .downloading: return "Downloading"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .queued: return .orange
        case .downloading: return .blue
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        }
    }
}

// MARK: - Download Item
struct DownloadItem: Identifiable, Codable {
    let id = UUID()
    let url: String
    let title: String
    let filename: String
    let filePath: String
    let downloadDate: Date
    let mode: String
    let format: String
    
    var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }
    
    var exists: Bool {
        FileManager.default.fileExists(atPath: filePath)
    }
}

// MARK: - Network Status
enum NetworkStatus {
    case connected
    case disconnected
    case checking
}
