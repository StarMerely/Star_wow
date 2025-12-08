//
//  ScreenCapture.m
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

#import "ScreenCapture.h"
#import <AppKit/AppKit.h>

@implementation ScreenCapture

+ (CGImageRef _Nullable)captureMainScreen {
    NSScreen *mainScreen = [NSScreen mainScreen];
    if (!mainScreen) {
        return NULL;
    }
    
    CGRect screenRect = mainScreen.frame;
    
    // 使用 CGWindowListCreateImage 截取屏幕
    // 在 Objective-C 中不会有弃用警告的编译错误
    CGImageRef image = CGWindowListCreateImage(
        screenRect,
        kCGWindowListOptionOnScreenOnly,
        kCGNullWindowID,
        kCGWindowImageBestResolution | kCGWindowImageBoundsIgnoreFraming
    );
    
    return image;
}

+ (CGImageRef _Nullable)captureWindowWithID:(CGWindowID)windowID {
    CGImageRef image = CGWindowListCreateImage(
        CGRectNull,
        kCGWindowListOptionIncludingWindow,
        windowID,
        kCGWindowImageBestResolution | kCGWindowImageBoundsIgnoreFraming
    );
    
    return image;
}

@end
