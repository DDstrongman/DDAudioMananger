//
//  NSString+DDExt.h
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/28.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DDExt)

///md5 16位加密 （小写）
- (NSString *)md5Mod16;
///md5 16位加密 （大写）
- (NSString *)md5Mod16Big;
///md5 32位加密
- (NSString *)md5Mod32;
///获取当前距离1970的时间
- (NSString *)currentTimeSince1970;

@end
