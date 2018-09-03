//
//  DDAudioHttp.m
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import "DDAudioHttp.h"

#import "DDHttpManager.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
    DDAVPlayerType = 0,
    DDAudioQueueType
}DDHttpAudioToolType;

@interface DDAudioHttp()<AVAudioPlayerDelegate>

{
    void (^playSuccess)(id);
    void (^playFailed)(id);
}

@property (nonatomic, strong) AVPlayer *audioPlayer;

@end;

@implementation DDAudioHttp

- (void)downloadHttp:(NSString *)url
        SuccessBlock:(void (^)(id))success
         FailedBlock:(void (^)(id))failed {
    [[DDHttpManager ShareInstance]AFNetMethodsSupport:url
                                           Parameters:nil
                                               Method:DDHttpGet
                                        RequestMethod:DDRequestHttp
                                          SucessBlock:success
                                          FailedBlock:failed];
}

- (void)onlinePlayHttp:(NSString *)url
          SuccessBlock:(void (^)(id))success
           FailedBlock:(void (^)(id))failed {
    NSString *newUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *audioUrl = [NSURL fileURLWithPath:newUrl];
    // 设置外放声音
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    AVPlayerItem *newItem = [[AVPlayerItem alloc]initWithURL:audioUrl];
    if (!_audioPlayer) {
        _audioPlayer = [[AVPlayer alloc]initWithPlayerItem:newItem];
    }else {
        [_audioPlayer replaceCurrentItemWithPlayerItem:newItem];
    }
    [_audioPlayer play];
}

@end
