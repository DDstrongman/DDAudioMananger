//
//  DDAudioManager.m
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import "DDAudioManager.h"

#import "DDAudioHttp.h"
#import "DDAudioDiskCache.h"
#import <AVFoundation/AVFoundation.h>

@interface DDAudioManager()

@property (nonatomic, strong) DDAudioDiskCache *cache;
@property (nonatomic, strong) DDAudioHttp *http;


@end;

@implementation DDAudioManager

+ (instancetype)shareInstance {
    static DDAudioManager *DDAudioManangerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDAudioManangerInstance = [[DDAudioManager alloc]init];
    });
    return DDAudioManangerInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cache = [[DDAudioDiskCache alloc]initWithFileName:@"DDAudioManagerFiles"];
        _http = [[DDAudioHttp alloc]init];
    }
    return self;
}

- (void)setTrimNum:(int)trimNum {
    if (_trimSize != trimNum) {
        _trimNum = trimNum;
        _cache.diskTrimCount = _trimNum;
    }
}

- (void)setTrimSize:(float)trimSize {
    if (_trimSize != trimSize) {
        _trimSize = trimSize;
        _cache.diskTrimSize = _trimSize;
    }
}

- (void)playAudioWithUrl:(NSString *)url
                  Method:(DDAudioMethod)method {
    switch (method) {
        case DiskElseHttp: {
            if ([_cache containsObjectForKey:url]) {
                [_cache playAudioForKey:url];
            }else {
                [self httpPlayAndDownLoad:url];
            }
        }
            break;
        case DiskThenHttp: {
            if ([_cache containsObjectForKey:url]) {
                [_cache playAudioForKey:url];
            }else {
                __weak __typeof(&*self)weakSelf = self;
                [_http downloadHttp:url SuccessBlock:^(id res) {
                    [weakSelf.cache setObject:res forKey:url DoneBlock:^{
                        [weakSelf.cache playAudioForKey:url];
                    }];
                } FailedBlock:^(id res) {
                    
                }];    
            }
        }
            break;
        case DiskOnly: {
            if ([_cache containsObjectForKey:url]) {
                [_cache playAudioForKey:url];
            }
        }
            break;
        case HttpOnly: {
            [_http onlinePlayHttp:url SuccessBlock:^(id res) {
                
            } FailedBlock:^(id res) {
                
            }];
        }
            break;
        default: {
            if ([_cache containsObjectForKey:url]) {
                [_cache playAudioForKey:url];
            }else {
                [self httpPlayAndDownLoad:url];
            }
        }
            break;
    }
}

- (void)downloadAudioWithUrl:(NSString *)url {
    __weak __typeof(self)weakSelf = self;
    [_http downloadHttp:url SuccessBlock:^(id res) {
        [weakSelf.cache setObject:res forKey:url];
    } FailedBlock:^(id res) {
        
    }];
}

#pragma mark - support methods
- (void)httpPlayAndDownLoad:(NSString *)url {
    __weak __typeof(&*self)weakSelf = self;
    [_http onlinePlayHttp:url SuccessBlock:^(id res) {
        
    } FailedBlock:^(id res) {
        
    }];
    [_http downloadHttp:url SuccessBlock:^(id res) {
        [weakSelf.cache setObject:res forKey:url];
    } FailedBlock:^(id res) {
        
    }];
}

@end
