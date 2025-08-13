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
    @Published var selectedVideoFormat: VideoFormat = .mp4_1080
    @Published var selectedAudioFormat: AudioFormat = .mp3
    @Published var selectedAudioQuality: AudioQuality = .high
    @Published var outputPath: String = ""
    @Published var extraArguments: String = ""
    
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: DownloadProgress = DownloadProgress()
    @Published var statusMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let downloadService = DownloadService()
    private let networkService = NetworkService()
    private let storageService = StorageService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        outputPath = storageService.getLastUsedFolder()
    }
    
    private func setupBindings() {
        downloadService.$isDownloading
            .assign(to: \.isDownloading, on: self)
            .store(in: &cancellables)
        
        downloadService.$progress
            .assign(to: \.downloadProgress, on: self)
            .store(in: &cancellables)
        
        networkService.$isConnected
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.statusMessage = "No internet connection"
                } else {
                    self?.statusMessage = ""
                }
            }
            .store(in: &cancellables)
    }
    
    func startDownload() {
        Task { @MainActor in
            // Validate inputs
            guard !videoURL.isEmpty else {
                showError("Please enter a valid URL")
                return
            }
            
            guard !outputPath.isEmpty else {
                showError("Please select an output folder")
                return
            }
            
            // Check network connection
            let isConnected = await networkService.checkConnection()
            guard isConnected else {
                showError("No internet connection. Please check your network and try again.")
                return
            }
            
            statusMessage = "Starting download..."
            
            let extraArgs = parseExtraArguments()
            
            downloadService.downloadMedia(
                url: videoURL,
                mode: downloadMode,
                videoFormat: downloadMode == .video ? selectedVideoFormat : nil,
                audioFormat: downloadMode == .audio ? selectedAudioFormat : nil,
                audioQuality: downloadMode == .audio ? selectedAudioQuality : nil,
                outputPath: outputPath,
                extraArgs: extraArgs
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleDownloadResult(result)
                }
            }
        }
    }
    
    func cancelDownload() {
        downloadService.cancelDownload()
        statusMessage = "Download cancelled"
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
    
    private func parseExtraArguments() -> [String] {
        return extraArguments
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
    }
    
    private func handleDownloadResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let message):
            statusMessage = message
            
            // Create download item for recent downloads
            let downloadItem = DownloadItem(
                url: videoURL,
                title: downloadProgress.filename.isEmpty ? "Downloaded Media" : downloadProgress.filename,
                filename: downloadProgress.filename,
                filePath: outputPath + "/" + downloadProgress.filename,
                downloadDate: Date(),
                mode: downloadMode.rawValue,
                format: downloadMode == .video ? selectedVideoFormat.displayName : selectedAudioFormat.displayName
            )
            
            storageService.addDownload(downloadItem)
            
        case .failure(let error):
            showError(error.localizedDescription)
            statusMessage = "Download failed"
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Storage Service Access
    var storageServicePublisher: StorageService {
        return storageService
    }
}
