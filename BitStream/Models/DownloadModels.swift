//
//  DownloadModels.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation

// MARK: - Download Types
enum DownloadMode: String, CaseIterable {
    case video = "Video"
    case audio = "Audio"
}

enum VideoFormat: String, CaseIterable, Identifiable {
    case best = "best"
    case worst = "worst"
    case mp4_1080 = "bv[height<=1080]+ba"
    case mp4_720 = "bv[height<=720]+ba"
    case mp4_480 = "bv[height<=480]+ba"
    case webm = "bv[ext=webm]+ba[ext=webm]"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .best: return "Best Quality"
        case .worst: return "Worst Quality"
        case .mp4_1080: return "1080p MP4"
        case .mp4_720: return "720p MP4"
        case .mp4_480: return "480p MP4"
        case .webm: return "WebM"
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
