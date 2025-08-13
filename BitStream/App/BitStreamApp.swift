//
//  BitStreamApp.swift
//  BitStream
//
//  Created by GICHUKI on 05/04/2025.
//

import SwiftUI

@main
struct BitStreamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Clear Recent Downloads") {
                    // Handle clearing recent downloads
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }
    }
}
