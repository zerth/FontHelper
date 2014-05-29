//
//  NSURL+FHURLShim.m
//  FontHelper
//
//

#import "NSURL+FHURLShim.h"

@implementation NSURL (FHURLShim)

#if DEFINE_URL_GETFSREPR_SHIM

- (BOOL) getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxBufferLength {
    NSString* path, parameterString, fullPath;
    path = [self path];
    parameterString = [self parameterString];
    fullPath = path;
    if (parameterString) {
        fullPath = [fullPath stringByAppendingFormat: @";%@", parameterString];
    }
    // fixme; write fullpath to buffer if possible.
    return NO;
}

#endif

@end
