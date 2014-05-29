//
//  FontHelper.h
//  FontHelper
//
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define FONT UIFont
#else
#import <Foundation/Foundation.h>
#define FONT NSFont
#endif


@interface FontHelper : NSObject

+(id) loadFontData;

@end


