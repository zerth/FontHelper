//
//  NSData+FHDigests.h
//  FontHelper
//
// Add md5sum and sha1sum methods (returning lowercase hex nsstrings) to NSData and NSInputStream instances.

#import <Foundation/Foundation.h>


@interface NSData (FHDigests)

- (NSString*) md5sum;
- (NSString*) sha1sum;

@end


#ifndef READ_CHUNK_SIZE
#define READ_CHUNK_SIZE 65536
#endif

@interface NSInputStream (FHDigests)

- (NSString*) md5sum;
- (NSString*) sha1sum;

@end
