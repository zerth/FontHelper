//
//  FontHelper.m
//  FontHelper
//
//

#import "FontHelper.h"
#import <CoreText/CTFont.h>

#import "NSData+FHDigests.h"
#import "NSURL+FHURLShim.h"

@implementation FontHelper


+ (id)loadFontData {
    NSString *font_name = @"Verdana";
    FONT *font = (__bridge_transfer FONT*)CTFontCreateWithName((__bridge CFStringRef) font_name, 0.0, NULL);
    // note: CTFontRef is toll-free bridged w/UIFont & NSFont
    if (font) {
        return [FontHelper cacheFontData: font];
    }
    return nil;
}


+ (id) cacheFontData:(FONT*)font {
    NSArray* tags = (__bridge_transfer NSArray*)CTFontCopyAvailableTables((__bridge CTFontRef)font,
                                                                          kCTFontTableOptionNoOptions);
    CFIndex i, count = [tags count];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: count];

    CTFontTableTag t;
    for (i = 0; i < count; i++) {
        t = (CTFontTableTag)(uintptr_t)CFArrayGetValueAtIndex((__bridge CFArrayRef)tags, i);
        [FontHelper updateFontDict: dict withFont: font andTag: t];
    }
    return dict;
}


+ (NSArray*) glyphDirectoryURLsForFont:(FONT*)font {
    NSString *glyphDirName = [NSString stringWithFormat: @"glyphs-%@-%1.2f",
                              [font fontName], [font pointSize]];
    NSArray *candidates = [[NSFileManager defaultManager]
                           URLsForDirectory: NSCachesDirectory
                           inDomains: NSLocalDomainMask];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [candidates count]];
    for (NSURL *url in candidates) {
        [result addObject: [url URLByAppendingPathComponent: glyphDirName
                                                isDirectory: YES]];
    }
    return result;
}


+ (id) updateFontDict:(NSMutableDictionary*)dict withFont:(FONT*)font andTag:(CTFontTableTag)t {
    char keyName[5] = {0, 0, 0, 0, 0};
    uint32_t tt = CFSwapInt32HostToLittle(t);
    keyName[0] = (tt & 0x7F000000) >> 24;
    keyName[1] = (tt & 0x007F0000) >> 16;
    keyName[2] = (tt & 0x00007F00) >> 8;
    keyName[3] = (tt & 0x0000007F) >> 0;
    NSString* dictKey = [NSString stringWithCString: keyName
                                           encoding: NSASCIIStringEncoding];
    NSData* data;
    switch (t) {
            case kCTFontTableMaxp:
            case kCTFontTableHead:
            case kCTFontTableKern:
            case kCTFontTableLoca:
            case kCTFontTableName:
            case kCTFontTableCmap:
            case kCTFontTablePost:
            case kCTFontTableHhea:
            case kCTFontTableHmtx:
            case kCTFontTableGlyf: {
                data = (__bridge_transfer NSData*)CTFontCopyTable((__bridge CTFontRef)font,
                                                                  t,
                                                                  kCTFontTableOptionNoOptions);
                NSLog(@"MD5sum of table for %s is %@\n", keyName, [data md5sum]);
                if (kCTFontTableGlyf != t) {
                    if (data) {
                        [dict setObject: data forKey: dictKey];
                    }
                } else {
                    // fixme: compute digest and write to cache dir if not already present.
                }
                break;
            }
        default:
            break;
    }
    return nil;
}

@end
