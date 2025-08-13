//
//  NetworkService.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation
import Network
import Combine

class NetworkService: ObservableObject {
    @Published var isConnected: Bool = true
    @Published var status: NetworkStatus = .checking
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.status = path.status == .satisfied ? .connected : .disconnected
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    func checkConnection() async -> Bool {
        return await withCheckedContinuation { continuation in
            let testURL = URL(string: "https://www.google.com")!
            let task = URLSession.shared.dataTask(with: testURL) { _, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    continuation.resume(returning: httpResponse.statusCode == 200)
                } else {
                    continuation.resume(returning: false)
                }
            }
            task.resume()
            
            // Timeout after 5 seconds
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                task.cancel()
                continuation.resume(returning: false)
            }
        }
    }
}
