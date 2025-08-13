//
//  URLValidator.swift
//  BitStream
//
//  Created by GICHUKI on 14/08/2025.
//

import Foundation

struct URLValidator {
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              scheme.lowercased() == "http" || scheme.lowercased() == "https",
              let host = url.host else {
            return false
        }
        
        return AppConstants.supportedDomains.contains { domain in
            host.lowercased().contains(domain.lowercased())
        }
    }
    
    static func extractVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        // YouTube video ID extraction
        if let host = url.host, host.contains("youtube") || host.contains("youtu.be") {
            if host.contains("youtu.be") {
                return url.pathComponents.last
            } else {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                return components?.queryItems?.first(where: { $0.name == "v" })?.value
            }
        }
        
        return nil
    }
    
    static func sanitizeFilename(_ filename: String) -> String {
        let invalidChars = CharacterSet(charactersIn: "\\/:*?\"<>|")
        let sanitized = filename.components(separatedBy: invalidChars).joined(separator: "_")
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
