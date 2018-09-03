//
//  DDAudioHttp.h
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAudioHttp : NSObject

/**
 下载对应的音频文件入沙盒

 @param url 音频url
 @param success 成功后的block
 @param failed 失败后的block
 */
- (void)downloadHttp:(NSString *)url
        SuccessBlock:(void(^)(id res))success
         FailedBlock:(void(^)(id res))failed;

/**
 在线播放的方法

 @param url 音频url
 @param success 成功后的block
 @param failed 失败后的block
 */
- (void)onlinePlayHttp:(NSString *)url
          SuccessBlock:(void(^)(id res))success
           FailedBlock:(void(^)(id res))failed;

@end
