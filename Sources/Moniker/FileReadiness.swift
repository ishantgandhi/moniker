import Foundation

// Returns true once the file's size is above 0 and stops changing; false if it gave up
func waitUntilReady(_ url: URL) async -> Bool {
    // First size check (nil means the file doesn't exist)
    guard var previous = fileSize(url) else { return false }
    for _ in 1...5 {
        // Wait 2 seconds, then check again (give up if cancelled)
        guard (try? await Task.sleep(nanoseconds: 2_000_000_000)) != nil else { return false }
        // Give up if the file disappeared
        guard let current = fileSize(url) else { return false }
        // Ready: has content and didn't change since the last check
        if current > 0 && current == previous { return true }
        previous = current
    }
    // Still changing (or empty) after 5 tries
    return false
}

// File size in bytes, or nil if the file doesn't exist
private func fileSize(_ url: URL) -> UInt64? {
    let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
    return (attrs?[.size] as? NSNumber)?.uint64Value
}
