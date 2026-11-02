#if os(macOS)

import Foundation
import Testing
import WebKit
import WebKitTestWorkarounds

@MainActor
@Test
func installationDisablesOcclusionForNewAndDecodedWebViews() throws {
    let key = "_windowOcclusionDetectionEnabled"
    let existing = WKWebView()
    try #require(existing.value(forKey: key) as? Bool == true)
    let archive = try NSKeyedArchiver.archivedData(
        withRootObject: existing, requiringSecureCoding: false
    )

    if #available(macOS 26.1, *) {
        try ScreenTimeWorkaround.install()
    }
    try WKWebViewOcclusionWorkaround.install()
    try WKWebViewOcclusionWorkaround.install()

    #expect(existing.value(forKey: key) as? Bool == true)
    for _ in 0..<2 {
        let webView = WKWebView()
        #expect(webView.value(forKey: key) as? Bool == false)
    }
    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: archive)
    unarchiver.requiresSecureCoding = false
    defer { unarchiver.finishDecoding() }
    let decoded = try #require(
        unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? WKWebView
    )
    #expect(decoded.value(forKey: key) as? Bool == false)
}

#endif
