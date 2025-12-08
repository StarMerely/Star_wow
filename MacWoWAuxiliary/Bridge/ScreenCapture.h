//
//  ScreenCapture.h
//  MacWoWAuxiliary
//
//  Created by star on 2025/12/1.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScreenCapture : NSObject

/// 截取整个屏幕
+ (CGImageRef _Nullable)captureMainScreen CF_RETURNS_RETAINED;

/// 截取指定窗口
+ (CGImageRef _Nullable)captureWindowWithID:(CGWindowID)windowID CF_RETURNS_RETAINED;

@end

NS_ASSUME_NONNULL_END
