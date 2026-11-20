import AppKit
import SwiftUI

@main
struct MonikerApp: App {
    init() {
        // No Dock icon: menu bar only.
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("Moniker", systemImage: "camera.viewfinder") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
