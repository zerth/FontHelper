//
//  NSURL+FHURLShim.m
//  FontHelper
//
//

#import "NSURL+FHURLShim.h"

@implementation NSURL (FHURLShim)

#if DEFINE_URL_GETFSREPR_SHIM

- (BOOL) getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxBufferLength {
    NSString *path, *parameterString, *fullPath;
    path = [self path];
    parameterString = [self parameterString];
    fullPath = path;
    if (parameterString) {
        fullPath = [fullPath stringByAppendingFormat: @";%@", parameterString];
    }
    if ([fullPath length] < maxBufferLength) {
        return [fullPath getCString: buffer maxLength: maxBufferLength encoding: NSUTF8StringEncoding];
    }
    return NO;
}

#endif

@end
