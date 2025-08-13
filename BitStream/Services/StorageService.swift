//
//  StorageService.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import AppKit

class StorageService: ObservableObject {
    @Published var recentDownloads: [DownloadItem] = []
    @Published var lastUsedFolder: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let recentDownloadsKey = "RecentDownloads"
    private let lastFolderKey = "LastUsedFolder"
    private let maxRecentItems = 50
    
    init() {
        loadData()
    }
    
    func addDownload(_ item: DownloadItem) {
        // Remove existing item if it exists (to avoid duplicates)
        recentDownloads.removeAll { $0.url == item.url && $0.filename == item.filename }
        
        // Add new item at the beginning
        recentDownloads.insert(item, at: 0)
        
        // Keep only the most recent items
        if recentDownloads.count > maxRecentItems {
            recentDownloads = Array(recentDownloads.prefix(maxRecentItems))
        }
        
        saveRecentDownloads()
    }
    
    func removeDownload(_ item: DownloadItem) {
        recentDownloads.removeAll { $0.id == item.id }
        saveRecentDownloads()
    }
    
    func clearRecentDownloads() {
        recentDownloads.removeAll()
        saveRecentDownloads()
    }
    
    func setLastUsedFolder(_ path: String) {
        lastUsedFolder = path
        userDefaults.set(path, forKey: lastFolderKey)
    }
    
    func getLastUsedFolder() -> String {
        return lastUsedFolder.isEmpty ? getDefaultDownloadsFolder() : lastUsedFolder
    }
    
    private func getDefaultDownloadsFolder() -> String {
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        return downloadsURL?.path ?? NSHomeDirectory() + "/Downloads"
    }
    
    private func loadData() {
        // Load recent downloads
        if let data = userDefaults.data(forKey: recentDownloadsKey),
           let decoded = try? JSONDecoder().decode([DownloadItem].self, from: data) {
            recentDownloads = decoded
        }
        
        // Load last used folder
        lastUsedFolder = userDefaults.string(forKey: lastFolderKey) ?? ""
    }
    
    private func saveRecentDownloads() {
        if let encoded = try? JSONEncoder().encode(recentDownloads) {
            userDefaults.set(encoded, forKey: recentDownloadsKey)
        }
    }
    
    func openInFinder(_ item: DownloadItem) {
        if item.exists {
            NSWorkspace.shared.selectFile(item.filePath, inFileViewerRootedAtPath: "")
        }
    }
    
    func revealInFinder(_ item: DownloadItem) {
        if item.exists {
            NSWorkspace.shared.activateFileViewerSelecting([item.fileURL])
        }
    }
}
