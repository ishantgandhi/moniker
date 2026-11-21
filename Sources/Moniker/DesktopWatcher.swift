import Foundation

class DesktopWatcher {
    private let folder: URL
    private let onNewFile: (URL) -> Void
    private var knownNames = Set<String>()
    private var source: DispatchSourceFileSystemObject?

    init(folder: URL, onNewFile: @escaping (URL) -> Void){
        self.folder = folder
        self.onNewFile = onNewFile
    }
    func start() {
        // Do nothing if already watching
        guard source == nil else { return }

        // 1. Snapshot current file names
        // Save every file name currently in the folder as the baseline
        knownNames = Set((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [])

        // 2. Listen for changes to the folder
        // Open the folder just to receive events (no read/write access)
        let fd = open(folder.path, O_EVTONLY)
        // Give up if the folder couldn't be opened
        guard fd >= 0 else { return }
        // Create a watcher that fires when the folder's contents change
        let src = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: .main)
        // On each change, look for files that weren't in the snapshot
        src.setEventHandler { [weak self] in self?.checkForNewFiles() }
        // When the watcher stops, close the folder handle
        src.setCancelHandler { close(fd) }
        // Start delivering events
        src.resume()
        // Keep the watcher alive and remember we're running
        source = src
    }
    func stop() {
        // Stop the watcher (its cancel handler closes the folder handle)
        source?.cancel()
        // Clear it so start() can be called again
        source = nil
    }
    private func checkForNewFiles(){
        // List the folder's current file names
        let current = Set((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [])
        // Keep only names that weren't in the snapshot
        let added = current.subtracting(knownNames)
        // Update the snapshot (also drops names of deleted files)
        knownNames = current
        // Report each new file to the caller
        for name in added {
            onNewFile(folder.appendingPathComponent(name))
        }
    }
}