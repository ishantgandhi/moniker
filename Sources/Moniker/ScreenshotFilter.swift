import Foundation

func isScreenshot(_ url: URL) -> Bool {
    let name = url.lastPathComponent
    // Hidden files (e.g. temp files starting with ".") never count
    guard !name.hasPrefix(".") else { return false }
    // Name must start with "Screenshot", ignoring upper/lower case
    guard name.lowercased().hasPrefix("screenshot") else { return false }
    // Only PNG files, ignoring upper/lower case
    return url.pathExtension.lowercased() == "png"
}
