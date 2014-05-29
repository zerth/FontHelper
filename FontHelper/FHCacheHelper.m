//
//  FHCacheHelper.m
//  FontHelper
//
//

#import "FHCacheHelper.h"
#import "NSData+FHDigests.h"
#import "NSURL+FHURLShim.h"


@implementation FHCacheHelper


+ (NSArray*) cacheURLsForSubdirectory:(NSString*)subdir {
    NSArray *candidates = [[NSFileManager defaultManager]
                           URLsForDirectory: NSCachesDirectory
                           inDomains: NSLocalDomainMask];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [candidates count]];
    for (NSURL *url in candidates) {
        [result addObject: [url URLByAppendingPathComponent: subdir
                                                isDirectory: YES]];
    }
    return result;
}


+ (NSURL*) findOrCacheData:(NSData*)data inSubdirectory:(NSString*)subdir {
    NSString *hexdigest = [data md5sum];
    NSURL *defaultURL = nil;

    for (NSURL *url in [self cacheURLsForSubdirectory: subdir]) {
        NSURL *candidate = [url URLByAppendingPathComponent: hexdigest];
        NSLog(@"checking candidate url %@\n", candidate);
        if (!defaultURL) {
            defaultURL = candidate;
        }
        char path[1+PATH_MAX];
        path[PATH_MAX] = 0;
        if ([candidate getFileSystemRepresentation: path maxLength: PATH_MAX]) {
            NSLog(@"actual path: %s\n", path);
            NSString *nspath = [NSString stringWithCString: path encoding: NSUTF8StringEncoding];
            if ([[NSFileManager defaultManager] fileExistsAtPath: nspath isDirectory: NO]) {
                NSLog(@"a file exists at %s\n", path);
                NSInputStream *istream = [NSInputStream inputStreamWithURL: candidate];
                if (istream) {
                    NSLog(@"opened istream on %s\n", path);
                    NSString *actualDigest = [istream md5sum];
                    if ([hexdigest isEqualToString: actualDigest]) {
                        NSLog(@"candidate %@ digest matches expected value %@\n", candidate, hexdigest);
                        return candidate;
                    } else {
                        NSLog(@"digest mismatch: expected %@, actual %@\n", hexdigest, actualDigest);
                    }
                }
                [[NSFileManager defaultManager] removeItemAtPath: nspath error: nil];
            }
        }
    }
    NSLog(@"no cache file found, default is %@\n", defaultURL);
    // if we reached this point, no valid cache files were found, so write one if possible:
    if (defaultURL) {
        [[NSFileManager defaultManager]
            createDirectoryAtURL: [defaultURL URLByDeletingLastPathComponent]
            withIntermediateDirectories: YES
            attributes: nil
            error: nil];
        if ([data writeToURL: defaultURL atomically: YES]) {
            NSLog(@"wrote cache file to %@\n", defaultURL);
            return defaultURL;
        } else {
            NSLog(@"failed to write cache file %@\n", defaultURL);
        }
    }
    return nil;
}

@end
