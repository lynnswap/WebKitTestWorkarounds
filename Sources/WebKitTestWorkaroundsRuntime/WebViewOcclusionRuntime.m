#import "WebKitTestWorkaroundsRuntime.h"

#if TARGET_OS_OSX

#import <WebKit/WebKit.h>
#import <objc/runtime.h>

// This declaration matches WebKit's WKWebViewPrivate.h.
@interface WKWebView (WKTWWindowOcclusion)
- (void)_setWindowOcclusionDetectionEnabled:(BOOL)enabled;
@end

static NSError *InstallationError(NSString *description)
{
    return [NSError errorWithDomain:@"WebKitTestWorkarounds.WebViewOcclusion" code:1
                          userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSError *Install(void)
{
    SEL selector = NSSelectorFromString(@"_initializeWithConfiguration:");
    Method method = class_getInstanceMethod(WKWebView.class, selector);
    if (!method)
        return InstallationError(@"This WebKit runtime does not expose the web view initialization method.");
    if (![WKWebView instancesRespondToSelector:@selector(_setWindowOcclusionDetectionEnabled:)])
        return InstallationError(@"This WebKit runtime does not expose the window occlusion API.");

    typedef void (*Initialize)(WKWebView *, SEL, WKWebViewConfiguration *);
    Initialize original = (Initialize)method_getImplementation(method);
    IMP replacement = imp_implementationWithBlock(^(WKWebView *webView, WKWebViewConfiguration *configuration) {
        original(webView, selector, configuration);
        [webView _setWindowOcclusionDetectionEnabled:NO];
    });
    method_setImplementation(method, replacement);
    return nil;
}

@implementation WKTWWebViewOcclusionRuntime

+ (BOOL)installWithError:(NSError **)error
{
    static dispatch_once_t once;
    static NSError *installationError;
    dispatch_once(&once, ^{
        installationError = Install();
    });
    if (error)
        *error = installationError;
    return installationError == nil;
}

@end

#endif
