//
//  DownloadService.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import Combine

class DownloadService: ObservableObject {
    @Published var progress = DownloadProgress()
    @Published var isDownloading = false
    @Published var logs: [String] = []
    
    private var currentProcess: Process?
    private var cancellables = Set<AnyCancellable>()
    
    func downloadMedia(
        url: String,
        mode: DownloadMode,
        videoFormat: VideoFormat? = nil,
        containerFormat: ContainerFormat? = nil,
        audioFormat: AudioFormat? = nil,
        audioQuality: AudioQuality? = nil,
        outputPath: String,
        extraArgs: [String] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !isDownloading else {
            completion(.failure(DownloadError.alreadyDownloading))
            return
        }
        
        // Get bundled yt-dlp path
        guard let ytdlpPath = Bundle.main.path(forResource: "yt-dlp", ofType: nil) else {
            completion(.failure(DownloadError.ytdlpNotFound))
            return
        }
        
        // Debug logging (remove the permission setting code)
        print("yt-dlp path: \(ytdlpPath)")
        print("File exists: \(FileManager.default.fileExists(atPath: ytdlpPath))")
        print("Is executable: \(FileManager.default.isExecutableFile(atPath: ytdlpPath))")
        
        isDownloading = true
        progress = DownloadProgress()
        logs.removeAll()
        
        let process = Process()
        currentProcess = process
        
        process.executableURL = URL(fileURLWithPath: ytdlpPath)
        
        let arguments = buildArguments(
            url: url,
            mode: mode,
            videoFormat: videoFormat,
            containerFormat: containerFormat,
            audioFormat: audioFormat,
            audioQuality: audioQuality,
            outputPath: outputPath,
            extraArgs: extraArgs
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
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("yt-dlp stdout: \(output)")
                    self?.processOutput(output)
                }
            }
        }
        
        // Handle errors - capture error output
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty, let error = String(data: data, encoding: .utf8) {
                errorOutput += error
                DispatchQueue.main.async {
                    print("yt-dlp stderr: \(error)")
                }
            }
        }
        
        process.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.currentProcess = nil
                
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                
                if process.terminationStatus == 0 {
                    completion(.success("Download completed successfully"))
                } else {
                    print("yt-dlp failed with exit code: \(process.terminationStatus)")
                    print("Error output: \(errorOutput)")
                    let errorMessage = errorOutput.isEmpty ?
                    "Download failed with exit code: \(process.terminationStatus)" :
                    errorOutput
                    completion(.failure(DownloadError.downloadFailedWithMessage(errorMessage)))
                }
            }
        }
        
        do {
            try process.run()
        } catch {
            isDownloading = false
            currentProcess = nil
            completion(.failure(error))
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
        
        // Find FFmpeg and add it explicitly
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
            "--progress",
            "-o", "\(outputPath)/%(title)s.%(ext)s"
        ])
        
        // Format selection
        switch mode {
        case .video:
            if let videoFormat = videoFormat {
                args.append(contentsOf: ["-f", videoFormat.rawValue])
            }
            
            // Add container format for video downloads
            if let containerFormat = containerFormat {
                args.append(contentsOf: ["--merge-output-format", containerFormat.rawValue])
            }
            
        case .audio:
            args.append("-x") // Extract audio
            if let audioFormat = audioFormat {
                args.append(contentsOf: ["--audio-format", audioFormat.rawValue])
            }
            if let audioQuality = audioQuality {
                args.append(contentsOf: ["--audio-quality", audioQuality.rawValue])
            }
        }
        
        // Add extra arguments
        args.append(contentsOf: extraArgs)
        
        // Add URL last
        args.append(url)
        
        return args
    }
    
    private func processOutput(_ output: String) {
        logs.append(output)
        
        // Parse progress from yt-dlp output
        if let progressInfo = parseProgress(from: output) {
            progress = progressInfo
        }
    }
    
    private func parseProgress(from output: String) -> DownloadProgress? {
        var progressInfo = progress
        
        // Parse different types of output
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            // Parse download progress: [download]  45.2% of 123.45MiB at 1.23MiB/s ETA 00:34
            if line.contains("[download]") && line.contains("%") {
                if let percentMatch = line.range(of: #"\d+\.?\d*%"#, options: .regularExpression) {
                    let percentString = String(line[percentMatch]).replacingOccurrences(of: "%", with: "")
                    if let percent = Double(percentString) {
                        progressInfo.percentage = percent / 100.0
                    }
                }
                
                // Parse speed
                if let speedMatch = line.range(of: #"\d+\.?\d*\w+/s"#, options: .regularExpression) {
                    progressInfo.speed = String(line[speedMatch])
                }
                
                // Parse ETA
                if let etaMatch = line.range(of: #"ETA \d{2}:\d{2}"#, options: .regularExpression) {
                    progressInfo.eta = String(line[etaMatch]).replacingOccurrences(of: "ETA ", with: "")
                }
                
                // Parse total size
                if let sizeMatch = line.range(of: #"of\s+[\d.]+\w+"#, options: .regularExpression) {
                    progressInfo.totalSize = String(line[sizeMatch]).replacingOccurrences(of: "of ", with: "")
                }
            }
            
            // Parse destination/filename
            if line.contains("Destination:") {
                let filename = line.replacingOccurrences(of: "[download] Destination: ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                progressInfo.filename = filename
            }
            
            // Parse merger info (final filename)
            if line.contains("[Merger] Merging formats into") {
                if let range = line.range(of: "\".*\"", options: .regularExpression) {
                    let filename = String(line[range]).replacingOccurrences(of: "\"", with: "")
                    progressInfo.filename = filename
                }
            }
        }
        
        return progressInfo
    }
    func cancelDownload() {
        currentProcess?.terminate()
        isDownloading = false
        currentProcess = nil
    }
}

// MARK: - Download Errors
enum DownloadError: LocalizedError {
    case ytdlpNotFound
    case alreadyDownloading
    case downloadFailed(Int32)
    case downloadFailedWithMessage(String)
    case networkError
    
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
        }
    }
}
