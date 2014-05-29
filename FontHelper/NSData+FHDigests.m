//
//  NSData+FHDigests.m
//  FontHelper
//

#import <CommonCrypto/CommonDigest.h>
#import "NSData+FHDigests.h"


static char* buf_to_hex(const uint8_t *src, size_t src_count, char *dst);
static NSString* do_digest(unsigned char *(fn)(const void*, CC_LONG, unsigned char*),
                           const void*,
                           CC_LONG,
                           uint8_t*,
                           size_t,
                           char*);


@implementation NSData (FHDigests)

- (NSString*) md5sum {
    size_t dlen = CC_MD5_DIGEST_LENGTH;
    uint8_t digest[dlen];
    char digest_str[2*dlen+1];

    NSUInteger len = [self length];
    if (len < UINT_MAX) {
        return do_digest(CC_MD5, [self bytes], (CC_LONG) len, digest, dlen, digest_str);
    }
    return nil;
}

- (NSString*) sha1sum {
    size_t dlen = CC_SHA1_DIGEST_LENGTH;
    uint8_t digest[dlen];
    char digest_str[2*dlen+1];

    NSUInteger len = [self length];
    if (len < UINT_MAX) {
        return do_digest(CC_SHA1, [self bytes], (CC_LONG) len, digest, dlen, digest_str);
    }
    return nil;
}

@end


static NSString* do_digest(unsigned char *(fn)(const void *, CC_LONG, unsigned char *),
                           const void *data,
                           CC_LONG datasize,
                           uint8_t *buf,
                           size_t bufsize,
                           char *str) {
    if (fn(data, datasize, buf)) {
        return [NSString stringWithCString: buf_to_hex(buf, bufsize, (char*)str)
                                  encoding: NSASCIIStringEncoding];
    }
    return nil;
}

static char hex_digits[16] = { '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' };

// octet -> hex digits LUT (stored as: "0001020304"...):
static char *hex_lut = NULL;

static void build_hex_lut() {
    hex_lut = (char*)malloc(512 * sizeof(char));
    assert(hex_lut);
    for (int i = 0; i < 256; i++) {
        hex_lut[2*i] = hex_digits[i/16];
        hex_lut[2*i+1] = hex_digits[i%16];
    }
}

static char* buf_to_hex(const uint8_t *src, size_t src_count, char *dst) {
    // note: dst should have space for 2*src_count+1 elements.
    if (!hex_lut) { build_hex_lut(); }
    for (int i = 0; i < src_count; i++) {
        uint8_t c = src[i];
        dst[(i<<1)  ] = hex_lut[(c<<1)  ];
        dst[(i<<1)+1] = hex_lut[(c<<1)+1];
    }
    dst[(src_count<<1)] = 0;
    return dst;
}
