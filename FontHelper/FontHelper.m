//
//  FontHelper.m
//  FontHelper
//
//

#import "FontHelper.h"
#import <CoreText/CTFont.h>

#import "NSData+FHDigests.h"
#import "NSURL+FHURLShim.h"
#import "FHCacheHelper.h"

@implementation FontHelper


+ (NSDictionary*) loadFontData {
    NSString *font_name = @"Verdana";
    FONT *font = (__bridge_transfer FONT*)CTFontCreateWithName((__bridge CFStringRef) font_name, 0.0, NULL);
    // note: CTFontRef is toll-free bridged w/UIFont & NSFont
    if (font) {
        return [self cacheFontData: font];
    }
    return nil;
}


+ (NSDictionary*) cacheFontData:(FONT*)font {
    NSArray* tags = (__bridge_transfer NSArray*)CTFontCopyAvailableTables((__bridge CTFontRef)font,
                                                                          kCTFontTableOptionNoOptions);
    CFIndex i, count = [tags count];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: count];

    CTFontTableTag t;
    for (i = 0; i < count; i++) {
        t = (CTFontTableTag)(uintptr_t)CFArrayGetValueAtIndex((__bridge CFArrayRef)tags, i);
        [self updateFontDict: dict withFont: font andTag: t];
    }
    return dict;
}


+ (NSURL*) findOrCacheGlyphData:(NSData*)data forFont:(FONT*)font {
    return [FHCacheHelper findOrCacheData: data
                           inSubdirectory: [NSString stringWithFormat: @"glyphs-%@-%1.2f",
                                            [font fontName], [font pointSize]]];
}


+ (void) updateFontDict:(NSMutableDictionary*)dict withFont:(FONT*)font andTag:(CTFontTableTag)t {
    char keyName[5] = {0, 0, 0, 0, 0};
    uint32_t tt = CFSwapInt32HostToLittle(t);
    keyName[0] = (tt & 0x7F000000) >> 24;
    keyName[1] = (tt & 0x007F0000) >> 16;
    keyName[2] = (tt & 0x00007F00) >> 8;
    keyName[3] = (tt & 0x0000007F) >> 0;
    NSString *dictKey = [NSString stringWithCString: keyName
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
                if (kCTFontTableGlyf != t) {
                    if (data) {
                        [dict setObject: data forKey: dictKey];
                    }
                } else {
                    // compute digest of glyphs table and write to cache dir if not already present, then store the filename as the dict value.
                    NSURL *cachedGlyphs = [self findOrCacheGlyphData: data forFont: font];
                    if (cachedGlyphs) {
                        [dict setObject: [cachedGlyphs absoluteString] forKey: dictKey];
                        [dict setObject: [cachedGlyphs lastPathComponent] forKey: @"glyphsTableDigest"];
                    }
                    assert(cachedGlyphs);
                }
                break;
            }
        default:
            break;
    }
}

@end
