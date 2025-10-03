//
//  DownloadService.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import Combine

class DownloadService: ObservableObject {
    @Published var activeDownloads: [ActiveDownload] = []
    @Published var logs: [String] = []
    
    private var downloadProcesses: [UUID: Process] = [:]
    private let maxConcurrentDownloads = 3
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Clean up completed downloads periodically
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.cleanupCompletedDownloads()
            }
            .store(in: &cancellables)
    }
    
    func queueDownload(
        url: String,
        title: String = "",
        mode: DownloadMode,
        videoFormat: VideoFormat? = nil,
        containerFormat: ContainerFormat? = nil,
        audioFormat: AudioFormat? = nil,
        audioQuality: AudioQuality? = nil,
        outputPath: String,
        extraArgs: [String] = []
    ) -> UUID {
        
        let download = ActiveDownload(
            url: url,
            title: title,
            mode: mode,
            videoFormat: videoFormat,
            containerFormat: containerFormat,
            audioFormat: audioFormat,
            audioQuality: audioQuality,
            outputPath: outputPath,
            extraArgs: extraArgs
        )
        
        activeDownloads.append(download)
        processDownloadQueue()
        
        return download.id
    }
    
    private func processDownloadQueue() {
        let currentDownloading = activeDownloads.filter {
            if case .downloading = $0.status { return true }
            return false
        }.count
        
        guard currentDownloading < maxConcurrentDownloads else { return }
        
        if let index = activeDownloads.firstIndex(where: {
            if case .queued = $0.status { return true }
            return false
        }) {
            startDownload(at: index)
        }
    }
    
    private func startDownload(at index: Int) {
        guard index < activeDownloads.count else { return }
        
        var download = activeDownloads[index]
        download.status = .downloading
        activeDownloads[index] = download
        
        guard let ytdlpPath = Bundle.main.path(forResource: "yt-dlp", ofType: nil) else {
            updateDownloadStatus(download.id, status: .failed("yt-dlp binary not found"))
            return
        }
        
        let process = Process()
        downloadProcesses[download.id] = process
        
        process.executableURL = URL(fileURLWithPath: ytdlpPath)
        
        // Set environment variables
        var environment = ProcessInfo.processInfo.environment
        let currentPath = environment["PATH"] ?? ""
        let additionalPaths = ["/usr/local/bin", "/opt/homebrew/bin", "/usr/bin", "/bin"]
        let newPath = (additionalPaths + [currentPath]).joined(separator: ":")
        environment["PATH"] = newPath
        environment["HOME"] = NSHomeDirectory()
        process.environment = environment
        
        let arguments = buildArguments(
            url: download.url,
            mode: download.mode,
            videoFormat: download.videoFormat,
            containerFormat: download.containerFormat,
            audioFormat: download.audioFormat,
            audioQuality: download.audioQuality,
            outputPath: download.outputPath,
            extraArgs: download.extraArgs
        )
        
        print("Executing command: \(ytdlpPath) \(arguments.joined(separator: " "))")
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        var errorOutput = ""
        
        // Handle output
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if !data.isEmpty {
                if let output = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        print("yt-dlp stdout [\(download.id.uuidString.prefix(8))]: \(output)")
                        self?.processOutput(output, for: download.id)
                    }
                }
            }
        }
        
        // Handle errors
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                if let error = String(data: data, encoding: .utf8) {
                    errorOutput += error
                    DispatchQueue.main.async {
                        print("yt-dlp stderr [\(download.id.uuidString.prefix(8))]: \(error)")
                    }
                }
            }
        }
        
        // FIXED: Proper termination handler
        process.terminationHandler = { [weak self] terminatedProcess in
            DispatchQueue.main.async {
                print("Process terminated for download \(download.id.uuidString.prefix(8)) with status: \(terminatedProcess.terminationStatus)")
                
                // Clean up handlers first
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                
                // Remove from active processes
                self?.downloadProcesses.removeValue(forKey: download.id)
                
                // Update status based on termination
                if terminatedProcess.terminationStatus == 0 {
                    print("Download \(download.id.uuidString.prefix(8)) completed successfully")
                    self?.updateDownloadStatus(download.id, status: .completed)
                } else if terminatedProcess.terminationStatus == 15 {
                    print("Download \(download.id.uuidString.prefix(8)) was cancelled")
                    self?.updateDownloadStatus(download.id, status: .cancelled)
                } else {
                    let errorMessage = errorOutput.isEmpty ?
                        "Download failed with exit code: \(terminatedProcess.terminationStatus)" :
                        errorOutput
                    print("Download \(download.id.uuidString.prefix(8)) failed: \(errorMessage)")
                    self?.updateDownloadStatus(download.id, status: .failed(errorMessage))
                }
                
                // Process next download in queue
                self?.processDownloadQueue()
            }
        }
        
        do {
            try process.run()
            print("Process started for download: \(download.id.uuidString.prefix(8))")
        } catch {
            print("Failed to start process: \(error)")
            updateDownloadStatus(download.id, status: .failed(error.localizedDescription))
            downloadProcesses.removeValue(forKey: download.id)
            processDownloadQueue()
        }
    }
    
    private func processOutput(_ output: String, for downloadId: UUID) {
        if !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            logs.append("[\(downloadId.uuidString.prefix(8))]: \(output)")
        }
        
        if let progressInfo = parseProgress(from: output),
           let index = activeDownloads.firstIndex(where: { $0.id == downloadId }) {
            var download = activeDownloads[index]
            download.progress = progressInfo
            
            // Only update if still downloading
            if case .downloading = download.status {
                activeDownloads[index] = download
            }
        }
    }
    
    private func updateDownloadStatus(_ downloadId: UUID, status: DownloadStatus) {
        if let index = activeDownloads.firstIndex(where: { $0.id == downloadId }) {
            var download = activeDownloads[index]
            download.status = status
            activeDownloads[index] = download
            
            print("Updated download \(downloadId.uuidString.prefix(8)) status to: \(status.displayText)")
        }
    }
    
    func cancelDownload(_ downloadId: UUID) {
        print("Cancelling download: \(downloadId)")
        
        if let process = downloadProcesses[downloadId] {
            if process.isRunning {
                print("Terminating running process for: \(downloadId)")
                process.terminate()
                
                // Force cleanup after delay if needed
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    if process.isRunning {
                        process.interrupt()
                    }
                    self?.downloadProcesses.removeValue(forKey: downloadId)
                }
            } else {
                downloadProcesses.removeValue(forKey: downloadId)
            }
        }
        
        updateDownloadStatus(downloadId, status: .cancelled)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.processDownloadQueue()
        }
    }
    
    func cancelAllDownloads() {
        print("Cancelling all downloads")
        
        let allProcesses = Array(downloadProcesses.keys)
        
        for downloadId in allProcesses {
            if let process = downloadProcesses[downloadId] {
                if process.isRunning {
                    print("Terminating process: \(downloadId)")
                    process.terminate()
                }
            }
            updateDownloadStatus(downloadId, status: .cancelled)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.downloadProcesses.removeAll()
            self?.processDownloadQueue()
        }
    }
    
    // ADDED: Manual cleanup method
    func removeCompletedDownloads() {
        print("Removing completed downloads from active list")
        let beforeCount = activeDownloads.count
        
        activeDownloads.removeAll { download in
            switch download.status {
            case .completed, .failed, .cancelled:
                return true
            default:
                return false
            }
        }
        
        let afterCount = activeDownloads.count
        print("Removed \(beforeCount - afterCount) completed downloads")
    }
    
    private func cleanupCompletedDownloads() {
        // Remove completed/failed downloads older than 30 minutes
        let thirtyMinutesAgo = Date().addingTimeInterval(-1800)
        let beforeCount = activeDownloads.count
        
        activeDownloads.removeAll { download in
            switch download.status {
            case .completed, .failed, .cancelled:
                return download.startTime < thirtyMinutesAgo
            default:
                return false
            }
        }
        
        let afterCount = activeDownloads.count
        if beforeCount != afterCount {
            print("Auto-cleaned \(beforeCount - afterCount) old downloads")
        }
    }
    
    private func buildArguments(
        url: String,
        mode: DownloadMode,
        videoFormat: VideoFormat?,
        containerFormat: ContainerFormat?,
        audioFormat: AudioFormat?,
        audioQuality: AudioQuality?,
        outputPath: String,
        extraArgs: [String]
    ) -> [String] {
        var args: [String] = []
        
        // Find and specify FFmpeg location explicitly
        let ffmpegPaths = [
            "/usr/local/bin/ffmpeg",
            "/opt/homebrew/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        
        for path in ffmpegPaths {
            if FileManager.default.fileExists(atPath: path) {
                args.append(contentsOf: ["--ffmpeg-location", path])
                break
            }
        }
        
        // Progress and output template
        args.append(contentsOf: [
            "--newline",
            "--progress"
        ])
        
        // Format selection
        switch mode {
        case .video:
            if let videoFormat = videoFormat {
                args.append(contentsOf: ["-f", videoFormat.rawValue])
            }
            
            if let containerFormat = containerFormat {
                args.append(contentsOf: ["--merge-output-format", containerFormat.rawValue])
            }
            
            let ext = containerFormat?.rawValue ?? "%(ext)s"
            args.append(contentsOf: ["-o", "\(outputPath)/%(title)s.\(ext)"])
            
        case .audio:
            args.append("-x")
            if let audioFormat = audioFormat {
                args.append(contentsOf: ["--audio-format", audioFormat.rawValue])
            }
            if let audioQuality = audioQuality {
                args.append(contentsOf: ["--audio-quality", audioQuality.rawValue])
            }
            
            let ext = audioFormat?.rawValue ?? "%(ext)s"
            args.append(contentsOf: ["-o", "\(outputPath)/%(title)s.\(ext)"])
        }
        
        args.append(contentsOf: extraArgs)
        args.append(url)
        
        return args
    }
    
    private func parseProgress(from output: String) -> DownloadProgress? {
        var progressInfo = DownloadProgress()
        
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("100%") || line.contains("has already been downloaded") {
                progressInfo.percentage = 1.0
                return progressInfo
            }
            
            if line.contains("[download]") && line.contains("%") {
                if let percentMatch = line.range(of: #"\d+\.?\d*%"#, options: .regularExpression) {
                    let percentString = String(line[percentMatch]).replacingOccurrences(of: "%", with: "")
                    if let percent = Double(percentString) {
                        progressInfo.percentage = percent / 100.0
                    }
                }
                
                if let speedMatch = line.range(of: #"\d+\.?\d*\w+/s"#, options: .regularExpression) {
                    progressInfo.speed = String(line[speedMatch])
                }
                
                if let etaMatch = line.range(of: #"ETA \d{2}:\d{2}"#, options: .regularExpression) {
                    progressInfo.eta = String(line[etaMatch]).replacingOccurrences(of: "ETA ", with: "")
                }
                
                if let sizeMatch = line.range(of: #"of\s+[\d.]+\w+"#, options: .regularExpression) {
                    progressInfo.totalSize = String(line[sizeMatch]).replacingOccurrences(of: "of ", with: "")
                }
            }
            
            if line.contains("Destination:") {
                let filename = line.replacingOccurrences(of: "[download] Destination: ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                progressInfo.filename = filename
            }
            
            if line.contains("[Merger] Merging formats into") {
                if let range = line.range(of: "\".*\"", options: .regularExpression) {
                    let filename = String(line[range]).replacingOccurrences(of: "\"", with: "")
                    progressInfo.filename = filename
                    progressInfo.percentage = 1.0
                }
            }
            
            if line.contains("Deleting original file") || line.contains("[ffmpeg] Merging") {
                progressInfo.percentage = 1.0
            }
        }
        
        return progressInfo
    }
    
    func debugActiveDownloads() {
        print("=== DOWNLOAD DEBUG ===")
        print("Active downloads count: \(activeDownloads.count)")
        print("Running processes count: \(downloadProcesses.count)")
        
        for download in activeDownloads {
            print("Download \(download.id.uuidString.prefix(8)): \(download.status.displayText) - \(Int(download.progress.percentage * 100))%")
            
            if let process = downloadProcesses[download.id] {
                print("  Process running: \(process.isRunning)")
            } else {
                print("  No process found")
            }
        }
        print("=====================")
    }
}

enum DownloadError: LocalizedError {
    case ytdlpNotFound
    case alreadyDownloading
    case downloadFailed(Int32)
    case downloadFailedWithMessage(String)
    case networkError
    case queueFull
    
    var errorDescription: String? {
        switch self {
        case .ytdlpNotFound:
            return "yt-dlp binary not found in app bundle"
        case .alreadyDownloading:
            return "A download is already in progress"
        case .downloadFailed(let code):
            return "Download failed with exit code: \(code)"
        case .downloadFailedWithMessage(let message):
            return message
        case .networkError:
            return "Network connection error"
        case .queueFull:
            return "Download queue is full. Please wait for some downloads to complete."
        }
    }
}
