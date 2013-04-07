//
//  MDTwitterPosterIncludes.h
//  MDTwitterPoster_Demo
//
//  Created by MD on 10/23/12.
//  All rights belong to their respective owners.
//

#import <CommonCrypto/CommonHMAC.h>

#import <Foundation/NSString.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSData+Base64.h"

@interface NSString (HMACSHA1)
- (NSString *) base64StringWithHMACSHA1Digest:(NSString *)secretKey;
@end

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end


@implementation NSString (HMACSHA1)
// sligtly modified routine by Alex Reynolds
// found here: http://stackoverflow.com/questions/788569/rsa-encryption-decryption-in-iphone
// from Stackoverslow.com, so under CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/)
//
// This seems to be only working for iOS 5.0+, but it worked on simulator (iOS 4.3) and iPhone 4 (iOS 4.1)
// you may use any HMAC-SHA1 routine available as a replacement (which returns Base64 string data representation)
- (NSString *) base64StringWithHMACSHA1Digest:(NSString *)secretKey {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    char *keyCharPtr = strdup([secretKey UTF8String]);
    char *dataCharPtr = strdup([self UTF8String]);
    
    CCHmacContext hctx;
    CCHmacInit(&hctx, kCCHmacAlgSHA1, keyCharPtr, strlen(keyCharPtr));
    CCHmacUpdate(&hctx, dataCharPtr, strlen(dataCharPtr));
    CCHmacFinal(&hctx, digest);
    NSData *encryptedStringData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
    free(keyCharPtr);
    free(dataCharPtr);
    
    return [encryptedStringData base64EncodingWithLineLength:0];
}
@end

@implementation NSString (URLEncoding)
// correct url Encode by James Higgs (http://madebymany.com/blog/url-encoding-an-nsstring-on-ios)
// with slight additions suggested in comments by Matthew Robinson
// © 2012 Made By Many Ltd.
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                (CFStringRef)self,
                                                                NULL,
                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
}
@end