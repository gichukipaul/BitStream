//
//  DownloadViewModel.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import Combine
import AppKit

class DownloadViewModel: ObservableObject {
    @Published var videoURL: String = ""
    @Published var downloadMode: DownloadMode = .video
    @Published var selectedVideoFormat: VideoFormat = .video_1080
    @Published var selectedContainerFormat: ContainerFormat = .mkv
    @Published var selectedAudioFormat: AudioFormat = .mp3
    @Published var selectedAudioQuality: AudioQuality = .high
    @Published var outputPath: String = ""
    @Published var extraArguments: String = ""
    
    @Published var statusMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var processedCompletions: Set<UUID> = []
    private let downloadService = DownloadService()
    private let networkService = NetworkService()
    private let storageService = StorageService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        outputPath = storageService.getLastUsedFolder()
    }
    
    private func setupBindings() {
        networkService.$isConnected
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.statusMessage = "No internet connection"
                } else {
                    self?.statusMessage = ""
                }
            }
            .store(in: &cancellables)
        
        // Monitor active downloads for completed items - FIXED LOGIC
        downloadService.$activeDownloads
            .sink { [weak self] downloads in
                for download in downloads {
                    if case .completed = download.status {
                        // Check if we haven't already processed this completion - FIXED
                        if !(self?.processedCompletions.contains(download.id) ?? true) {
                            self?.addToRecentDownloads(download)
                            self?.processedCompletions.insert(download.id)
                        }
                    }
                }
                
                // Auto-cleanup completed downloads after 10 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self?.cleanupCompletedDownloads()
                }
            }
            .store(in: &cancellables)
    }
    
    var hasActiveDownloads: Bool {
        return !downloadService.activeDownloads.filter {
            switch $0.status {
            case .queued, .downloading: return true
            default: return false
            }
        }.isEmpty
    }
    
    var downloadingCount: Int {
        return downloadService.activeDownloads.filter {
            if case .downloading = $0.status { return true }
            return false
        }.count
    }
    
    var queuedCount: Int {
        return downloadService.activeDownloads.filter {
            if case .queued = $0.status { return true }
            return false
        }.count
    }
    
    func startDownload() {
        Task { @MainActor in
            guard !videoURL.isEmpty else {
                showError("Please enter a valid URL")
                return
            }
            
            guard !outputPath.isEmpty else {
                showError("Please select an output folder")
                return
            }
            
            let isConnected = await networkService.checkConnection()
            guard isConnected else {
                showError("No internet connection. Please check your network and try again.")
                return
            }
            
            let extraArgs = parseExtraArguments()
            
            let downloadId = downloadService.queueDownload(
                url: videoURL,
                title: extractTitleFromURL(videoURL),
                mode: downloadMode,
                videoFormat: downloadMode == .video ? selectedVideoFormat : nil,
                containerFormat: downloadMode == .video ? selectedContainerFormat : nil,
                audioFormat: downloadMode == .audio ? selectedAudioFormat : nil,
                audioQuality: downloadMode == .audio ? selectedAudioQuality : nil,
                outputPath: outputPath,
                extraArgs: extraArgs
            )
            
            statusMessage = "Download queued"
            videoURL = ""
        }
    }
    
    func cancelDownload(_ downloadId: UUID) {
        downloadService.cancelDownload(downloadId)
    }
    
    func cancelAllDownloads() {
        downloadService.cancelAllDownloads()
    }
    
    func cleanupCompletedDownloads() {
        downloadService.removeCompletedDownloads()
    }
    
    func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Download Folder"
        
        if let window = NSApplication.shared.keyWindow {
            panel.beginSheetModal(for: window) { [weak self] response in
                if response == .OK, let url = panel.url {
                    self?.outputPath = url.path
                    self?.storageService.setLastUsedFolder(url.path)
                }
            }
        }
    }
    
    private func addToRecentDownloads(_ download: ActiveDownload) {
        let finalFilename = download.progress.filename.isEmpty ?
            "\(download.displayTitle).\(download.containerFormat?.rawValue ?? "mkv")" :
            download.progress.filename
        
        let downloadItem = DownloadItem(
            url: download.url,
            title: finalFilename,
            filename: finalFilename,
            filePath: "\(download.outputPath)/\(finalFilename)",
            downloadDate: Date(),
            mode: download.mode.rawValue,
            format: download.mode == .video ?
                "\(download.videoFormat?.displayName ?? "Unknown") → \(download.containerFormat?.displayName ?? "Unknown")" :
                "\(download.audioFormat?.displayName ?? "Unknown") (\(download.audioQuality?.displayName ?? "Unknown"))"
        )
        
        print("Adding to recent downloads: \(finalFilename)")
        storageService.addDownload(downloadItem)
    }
    
    private func extractTitleFromURL(_ url: String) -> String {
        if let videoID = URLValidator.extractVideoID(from: url) {
            return "Video_\(videoID)"
        }
        return "Download_\(Date().timeIntervalSince1970)"
    }
    
    private func parseExtraArguments() -> [String] {
        return extraArguments
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Service Access
    var downloadServicePublisher: DownloadService {
        return downloadService
    }
    
    var storageServicePublisher: StorageService {
        return storageService
    }
    
    func debugDownloads() {
        downloadService.debugActiveDownloads()
    }
}
