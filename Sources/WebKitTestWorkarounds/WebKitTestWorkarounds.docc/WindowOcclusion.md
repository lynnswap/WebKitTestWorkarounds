# Loading videos in occluded test windows

Disable window occlusion detection for macOS web views created during tests.

## Overview

A macOS test window can be covered by another window even after it is ordered
onscreen. WebKit may then leave video elements at `HAVE_METADATA`, delaying the
page's load event and the navigation delegate's `didFinish` callback.

Call `WKWebViewOcclusionWorkaround.install()` on the main actor in test setup,
before creating the first test web view:

```swift
import WebKitTestWorkarounds

@MainActor
func setUpWebViewTests() throws {
    try WKWebViewOcclusionWorkaround.install()
}
```

Installation uses private WebKit APIs and affects all subsequently initialized
web views in the current process, including views decoded from archives, until
the process exits. Existing web views are unchanged. Windows must still be
ordered onscreen.

For tests that launch an app, install the workaround during app startup in the
app process. It can be installed alongside `ScreenTimeWorkaround`.

Repeated calls reuse the first installation result. If the required private APIs
are unavailable, installation throws, leaves initialization unchanged, and later
calls throw the same error. This API is available only on macOS.
