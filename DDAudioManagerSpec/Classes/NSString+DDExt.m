//
//  NSString+DDExt.m
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/28.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import "NSString+DDExt.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (DDExt)

//md5 32位 加密 （小写）
- (NSString *)md5Mod32 {
    const char *cStr = [self UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0],result[1],result[2],result[3],
             result[4],result[5],result[6],result[7],
             result[8],result[9],result[10],result[11],
             result[12],result[13],result[14],result[15]] lowercaseString];
}

///md5 16位加密 （大写）
- (NSString *)md5Mod16Big {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr),result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

///md5 16位加密 （小写）
- (NSString *)md5Mod16 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr),result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
- (NSString *)currentTimeSince1970 {
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

@end
