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
        
        isDownloading = true
        progress = DownloadProgress()
        logs.removeAll()
        
        let process = Process()
        currentProcess = process
        
        process.executableURL = URL(fileURLWithPath: ytdlpPath)
        
        var arguments = buildArguments(
            url: url,
            mode: mode,
            videoFormat: videoFormat,
            audioFormat: audioFormat,
            audioQuality: audioQuality,
            outputPath: outputPath,
            extraArgs: extraArgs
        )
        
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Handle output
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.processOutput(output)
                }
            }
        }
        
        // Handle errors
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if !data.isEmpty, let error = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.processOutput(error)
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
                    completion(.failure(DownloadError.downloadFailed(process.terminationStatus)))
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
        audioFormat: AudioFormat?,
        audioQuality: AudioQuality?,
        outputPath: String,
        extraArgs: [String]
    ) -> [String] {
        var args: [String] = []
        
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
                if videoFormat != .best && videoFormat != .worst {
                    args.append(contentsOf: ["--merge-output-format", "mp4"])
                }
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
        
        // Parse percentage: [download]  45.2% of 123.45MiB at 1.23MiB/s ETA 00:34
        let patterns = [
            #"\[download\]\s+(\d+\.?\d*)%"#, // Percentage
            #"of\s+([\d.]+\w+)"#, // Total size
            #"at\s+([\d.]+\w+/s)"#, // Speed
            #"ETA\s+(\d{2}:\d{2})"# // ETA
        ]
        
        for (index, pattern) in patterns.enumerated() {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
               let range = Range(match.range(at: 1), in: output) {
                
                let value = String(output[range])
                
                switch index {
                case 0: // Percentage
                    if let percent = Double(value) {
                        progressInfo.percentage = percent / 100.0
                    }
                case 1: // Total size
                    progressInfo.totalSize = value
                case 2: // Speed
                    progressInfo.speed = value
                case 3: // ETA
                    progressInfo.eta = value
                default:
                    break
                }
            }
        }
        
        // Parse filename
        if output.contains("Destination:") {
            let components = output.components(separatedBy: "Destination: ")
            if components.count > 1 {
                progressInfo.filename = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
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
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .ytdlpNotFound:
            return "yt-dlp binary not found in app bundle"
        case .alreadyDownloading:
            return "A download is already in progress"
        case .downloadFailed(let code):
            return "Download failed with exit code: \(code)"
        case .networkError:
            return "Network connection error"
        }
    }
}
