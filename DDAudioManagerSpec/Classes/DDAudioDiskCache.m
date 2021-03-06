//
//  DDAudioDiskCache.m
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import "DDAudioDiskCache.h"
#import "DDWriteFileSupport.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+DDExt.h"

#import "DDLruStorage.h"

typedef enum {
    DDAudioPlayerType = 0,
    DDSystemSoundType
}DDLocalAudioToolType;

@interface DDAudioDiskCache ()<AVAudioPlayerDelegate>

{
    ///整个沙盒文件夹的路径
    NSString *dirPath;
    dispatch_semaphore_t DDAudioLock;
    DDLruStorage *dbStorage;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

#define Lock() dispatch_semaphore_wait(DDAudioLock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(DDAudioLock)

@end;

@implementation DDAudioDiskCache

- (instancetype)init {
    @throw [NSException exceptionWithName:@"DDAudioManager init error"
                                   reason:@"DDAudioManager must be initialized with a name. Use 'initWithFileName:' instead."
                                 userInfo:nil];
    return [self initWithFileName:@"test"];
}

- (nullable instancetype)initWithFileName:(NSString *)name {
    if (self = [super init]) {
        if ([[DDWriteFileSupport ShareInstance]createDir:name
                                                   Filed:Documents]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            dirPath = [documentsDirectory stringByAppendingPathComponent:name];
            dbStorage = [[DDLruStorage alloc]initWithDBName:@"ddStorageDB"];
            DDAudioLock = dispatch_semaphore_create(1);
        }
    }
    return self;
}
#pragma mark - lazyloading
- (void)setDiskTrimSize:(float)diskTrimSize {
    if (_diskTrimSize != diskTrimSize) {
        _diskTrimSize = diskTrimSize;
        [self trimToCost:_diskTrimSize];
    }
}

- (void)setDiskTrimCount:(int)diskTrimCount {
    if (_diskTrimCount != diskTrimCount) {
        _diskTrimCount = diskTrimCount;
        [self trimToCount:_diskTrimCount];
    }
}


- (BOOL)containsObjectForKey:(NSString *)key {
    Lock();
    NSArray *fileNames = [[DDWriteFileSupport ShareInstance]readDirNames:dirPath];
    Unlock();
    __block BOOL containBool = NO;
    NSString *fileName = [key md5Mod16];
    [fileNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name containsString:fileName]) {
            containBool = YES;
            *stop = YES;
        }
    }];
    return containBool;
}

- (void)playAudioForKey:(NSString *)key {
    NSString *filePath = [self getFilePath:key];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    Lock();
    // 设置外放声音
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    BOOL isFileExist = [[DDWriteFileSupport ShareInstance]readFile:filePath FileType:Data];
    if (isFileExist) {
        switch ([self choosePlayType:key]) {
            case DDAudioPlayerType: {
                NSError *error = nil;
                if (!_audioPlayer) {
                    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
                }else {
                    [_audioPlayer stop];
                }
                if (error) {
                    NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
                    return;
                }
                // 设置播放属性
                _audioPlayer.volume = 0.8;
                _audioPlayer.numberOfLoops = 0; // 不循环
                _audioPlayer.delegate = self;
                if (_audioPlayer) {
                    [dbStorage getItemForKey:key];
                    [_audioPlayer prepareToPlay];
                    [_audioPlayer play];
                }
            }
                break;
            case DDSystemSoundType: {
                //需要创建一个soundID，因为播放系统声音的时候，系统找寻的是soundID，soundID的范围为1000-2000之间。
                SystemSoundID soundID;
                /*根据声音的路径创建ID    （__bridge在两个框架之间强制转换类型，值转换内存，不修改内存管理的
                 权限）在转换数据类型的时候，不希望该对象的内存管理权限发生改变，原来是MRC类型，转换了还是 MRC。*/
                AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
                [dbStorage getItemForKey:key];
                //播放音频
                AudioServicesPlayAlertSound(soundID);
            }
                break;
            default: {
                //需要创建一个soundID，因为播放系统声音的时候，系统找寻的是soundID，soundID的范围为1000-2000之间。
                SystemSoundID soundID;
                /*根据声音的路径创建ID    （__bridge在两个框架之间强制转换类型，值转换内存，不修改内存管理的
                 权限）在转换数据类型的时候，不希望该对象的内存管理权限发生改变，原来是MRC类型，转换了还是 MRC。*/
                AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
                [dbStorage getItemForKey:key];
                //播放音频
                AudioServicesPlayAlertSound(soundID);
            }
                break;
        }
    }
    Unlock();
}

- (void)setObject:(nullable id<NSCoding>)object
           forKey:(NSString *)key {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    NSString *filePath = [self getFilePath:key];
    if ([[DDWriteFileSupport ShareInstance]writeFile:filePath
                                                Data:object]) {
        DDKVStorageModel *item = [[DDKVStorageModel alloc]init];
        item.key = key;
        item.modTime = [[@"" currentTimeSince1970] intValue];
        item.size = [[DDWriteFileSupport ShareInstance]countFileSize:filePath FileSizeType:KB];
        [dbStorage saveItem:item];
        if (_diskTrimCount > 0) {
            [self trimToCount:_diskTrimCount];
        }
        if (_diskTrimSize > 0) {
            [self trimToCost:_diskTrimSize];
        }
    }
}

- (void)setObject:(id<NSCoding>)object
           forKey:(NSString *)key
        DoneBlock:(void (^)(void))done {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    NSString *filePath = [self getFilePath:key];
    if ([[DDWriteFileSupport ShareInstance]writeFile:filePath
                                                Data:object]) {
        if (done) {
            done();
        }
        DDKVStorageModel *item = [[DDKVStorageModel alloc]init];
        item.key = key;
        item.modTime = [[@"" currentTimeSince1970] intValue];
        item.size = [[DDWriteFileSupport ShareInstance]countFileSize:filePath FileSizeType:KB];
        [dbStorage saveItem:item];
        if (_diskTrimCount > 0) {
            [self trimToCount:_diskTrimCount];
        }
        if (_diskTrimSize > 0) {
            [self trimToCost:_diskTrimSize];
        }
    }
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key) return;
    Lock();
    NSString *filePath = [self getFilePath:key];
    if ([[DDWriteFileSupport ShareInstance]removeFile:filePath]) {
        [dbStorage removeItemForKey:key];
    }
    Unlock();
}

- (void)removeAllObjects {
    Lock();
    if ([[DDWriteFileSupport ShareInstance]removeDirFiles:dirPath]) {
        [dbStorage removeAllItems];
    }
    Unlock();
}

- (NSInteger)totalCount {
    Lock();
    NSArray *fileNames = [[DDWriteFileSupport ShareInstance]readDirNames:dirPath];
    Unlock();
    return fileNames.count;
}

- (float)totalCost {
    Lock();
    float size = [[DDWriteFileSupport ShareInstance]countDirSize:dirPath FileSizeType:KB];
    Unlock();
    return size;
}

- (void)trimToCount:(int)count {
    __weak __typeof(&*self)weakSelf = self;
    [dbStorage removeItemsToFitCount:count deleteFileBlock:^(NSString *key) {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
       NSString *filePath = [strongSelf getFilePath:key];
        [[DDWriteFileSupport ShareInstance]removeFile:filePath];
    }];
}

- (void)trimToCost:(float)cost {
    __weak __typeof(&*self)weakSelf = self;
    [dbStorage removeItemsToFitSize:cost deleteFileBlock:^(NSString *key) {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        NSString *filePath = [strongSelf getFilePath:key];
        [[DDWriteFileSupport ShareInstance]removeFile:filePath];
    }];
}
#pragma mark - support methods
- (NSString *)getFilePath:(NSString *)key {
    NSString *filePath = [dirPath stringByAppendingPathComponent:[key md5Mod16]];
    switch ([self choosePlayType:key]) {
        case DDAudioPlayerType:
            filePath = [filePath stringByAppendingString:@".mp3"];
            break;
        case DDSystemSoundType:
            filePath = [filePath stringByAppendingString:@".wav"];
            break;
        default:
            filePath = [filePath stringByAppendingString:@".wav"];
            break;
    }
    return filePath;
}

- (DDLocalAudioToolType)choosePlayType:(NSString *)key {
    if ([key hasSuffix:@".caf"] || [key hasSuffix:@".wav"] || [key hasSuffix:@".aiff"]) {
        return DDSystemSoundType;
    }else {
        return DDAudioPlayerType;
    }
}

@end
