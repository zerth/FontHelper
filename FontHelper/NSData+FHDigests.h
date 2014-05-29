//
//  NSData+FHDigests.h
//  FontHelper
//
// Add md5sum and sha1sum methods (returning lowercase hex nsstrings) to NSData instances.

#import <Foundation/Foundation.h>

@interface NSData (FHDigests)

- (NSString*) md5sum;
- (NSString*) sha1sum;

@end
