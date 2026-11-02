#if os(macOS)

internal import WebKitTestWorkaroundsRuntime

/// Disables window occlusion detection in web views initialized after installation.
@MainActor
public enum WKWebViewOcclusionWorkaround {
    /// Installs the workaround for subsequent web view initializations in the current process.
    ///
    /// Call this method on the main actor before creating the first test web view.
    /// Install it in the process that creates the web views. Successful installation
    /// affects all subsequently initialized web views, including views decoded from
    /// archives, until the process exits. Existing web views are unchanged.
    /// Windows must still be ordered onscreen.
    ///
    /// Repeated calls reuse the result of the first attempt. If installation fails,
    /// no hook is installed, and subsequent calls throw the same error.
    ///
    /// - Throws: An error if this WebKit runtime does not expose the required
    ///   private initialization or window occlusion APIs.
    public static func install() throws {
        try WKTWWebViewOcclusionRuntime.install()
    }
}

#endif
