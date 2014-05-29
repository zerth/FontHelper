//
//  FontHelperTests.m
//  FontHelperTests
//
//

#import <XCTest/XCTest.h>

#import "NSData+FHDigests.h"
#import "FHCacheHelper.h"
#import "FontHelper.h"

@interface FontHelperTests : XCTestCase

@end

@implementation FontHelperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNSDataDigest
{
    NSDictionary *md5pairs = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"d41d8cd98f00b204e9800998ecf8427e", @"",
                              @"6f623914ab07c9271aa9961711709ae2", @"hello, world! i am a potato",
                              nil];
    NSDictionary *sha1pairs = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"da39a3ee5e6b4b0d3255bfef95601890afd80709", @"",
                               @"c7aea9407fbe61bb4e68c232af51238c7a06092d", @"hello, world! i am a potato",
                               nil];
    NSDictionary *ipairs = [NSDictionary dictionaryWithObjectsAndKeys:

                            md5pairs,
                            @"md5sum",

                            sha1pairs,
                            @"sha1sum",

                            nil];

    [ipairs enumerateKeysAndObjectsUsingBlock: ^(NSString *selname, NSDictionary *dict, BOOL *stop_outer) {
        SEL sel = NSSelectorFromString(selname);
        [dict enumerateKeysAndObjectsUsingBlock: ^(NSString *str, NSString *digest, BOOL *stop_inner) {
            NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
            IMP imp = [data methodForSelector: sel];
            NSString* (*f) (id, SEL) = (void *)imp;
            NSString* result = f(data, sel);
            XCTAssertEqualObjects(digest, result);
        }];
    }];
}

- (void)testNSInputStreamDigest
{
    NSString *str = @"hello, world! i am a potato. i like cheese.";
    NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSURL *tmp = [FHCacheHelper findOrCacheData: data inSubdirectory: @"cheesier"];
    @try {
        XCTAssert(tmp);
        NSInputStream *istream = [NSInputStream inputStreamWithURL: tmp];
        XCTAssert(istream);
        NSString *hexdigest, *expected;
        @try {
            [istream open];
            hexdigest = [istream md5sum];
        }
        @finally {
            [istream close];
        }
        expected = [data md5sum];
        XCTAssertEqualObjects(hexdigest, expected);
    }
    @finally {
        [[NSFileManager defaultManager] removeItemAtURL: tmp error: nil];
    }
}

- (void)testCacheHelper
{
    NSString *str = @"hello, world! i am a potato.";
    NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSURL *tmp = [FHCacheHelper findOrCacheData: data inSubdirectory: @"the cheesiest!"];
    @try {
        XCTAssert(tmp);
        NSData *actual = [NSData dataWithContentsOfURL: tmp];
        NSString *hexdigest = [actual md5sum];
        NSString *expected = [data md5sum];
        XCTAssertEqualObjects(hexdigest, expected);
    }
    @finally {
        [[NSFileManager defaultManager] removeItemAtURL: tmp error: nil];
    }
}

- (void)testLoadFontData
{
    NSDictionary *dict = [FontHelper loadFontData];
    NSString *hexdigest = [dict objectForKey: @"glyphsTableDigest"];
    XCTAssert(hexdigest);
    NSString *cacheFile = [dict objectForKey: @"glyf"];
    XCTAssert(cacheFile);
    XCTAssertEqualObjects(hexdigest, [[NSData dataWithContentsOfURL: [NSURL URLWithString: cacheFile]]
                                       md5sum]);
}

@end
