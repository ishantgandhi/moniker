import AppKit
import SwiftUI

@main
struct MonikerApp: App {
    // Kept as a property so the watcher stays alive for the app's lifetime
    private let watcher: DesktopWatcher

    init() {
        // No Dock icon: menu bar only.
        NSApplication.shared.setActivationPolicy(.accessory)

        // Watch the Desktop; react only to screenshots
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        watcher = DesktopWatcher(folder: desktop) { url in
            guard isScreenshot(url) else { return }
            print("Screenshot: \(url.lastPathComponent)")
        }
        watcher.start()
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
