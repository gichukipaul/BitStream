//
//  AppConstants.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation

struct AppConstants {
    static let appName = "BitStream"
    static let appVersion = "1.0.0"
    static let maxRecentDownloads = 50
    static let defaultTimeout: TimeInterval = 30
    
    // yt-dlp related
    static let ytdlpBinaryName = "yt-dlp"
    static let ytdlpGitHubURL = "https://github.com/yt-dlp/yt-dlp"
    
    // Supported URLs (for validation)
    static let supportedDomains = [
        "youtube.com", "youtu.be", "vimeo.com", "dailymotion.com",
        "twitch.tv", "soundcloud.com", "bandcamp.com", "instagram.com",
        "twitter.com", "tiktok.com", "facebook.com"
    ]
    
    // File size limits (in bytes)
    static let maxDownloadSize: Int64 = 10 * 1024 * 1024 * 1024 // 10GB
    
    // Progress update intervals
    static let progressUpdateInterval: TimeInterval = 0.5
}
