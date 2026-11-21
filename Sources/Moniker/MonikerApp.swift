import AppKit
import SwiftUI

@main
struct MonikerApp: App {
    // Kept as a property so the watcher stays alive for the app's lifetime
    private let watcher: DesktopWatcher

    // Default: watch ~/Desktop (SwiftUI requires a no-argument init)
    init() {
        self.init(folder: FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0])
    }

    // The folder to watch is passed in
    init(folder: URL) {
        // No Dock icon: menu bar only.
        NSApplication.shared.setActivationPolicy(.accessory)

        // React only to screenshots
        watcher = DesktopWatcher(folder: folder) { url in
            guard isScreenshot(url) else { return }
            print("Screenshot: \(url.lastPathComponent)")
            // Wait in the background so the main thread isn't blocked
            Task {
                // Continue only once the file is fully saved
                guard await waitUntilReady(url) else { return }
                print("Ready: \(url.lastPathComponent)")
            }
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
