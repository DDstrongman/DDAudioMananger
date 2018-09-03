//
//  DDAudioManager.h
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//
typedef enum {
    ///从沙盒播放，沙盒没有则网络播放。下载
    DiskElseHttp = 0,
    ///仅从沙盒播放，之后http更新沙盒。如果沙盒没有，在http下载到沙盒之后，才播放。下载
    DiskThenHttp,
    ///只从沙盒播放，如果沙盒没有则不播放。不下载
    DiskOnly,
    ///只从网络播放，支持网络播放的只有audioplayer支持的格式。不下载
    HttpOnly
}DDAudioMethod;

#import <Foundation/Foundation.h>

@interface DDAudioManager : NSObject

/**
 快捷使用单实例播放，如不使用单实例务必使用全局变量实例化本类，否则ARC情况下会在播放音频前被释放

 @return 返回单实例
 */
+ (instancetype)shareInstance;

/**
 播放音频并按模式处理

 @param url 音频url
 @param method 音频播放模式
 */
- (void)playAudioWithUrl:(NSString *)url
                  Method:(DDAudioMethod)method;

@end
