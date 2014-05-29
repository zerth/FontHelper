//
//  FontHelperTests.m
//  FontHelperTests
//
//

#import <XCTest/XCTest.h>

#import "NSData+FHDigests.h"

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

- (void)testDigestCategory
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

@end
