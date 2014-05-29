//
//  FHCacheHelper.h
//  FontHelper
//
//

#import <Foundation/Foundation.h>

@interface FHCacheHelper : NSObject

+ (NSArray*) cacheURLsForSubdirectory:(NSString*)subdir;
+ (NSURL*) findOrCacheData:(NSData*)data inSubdirectory:(NSString*)subdir;

@end
