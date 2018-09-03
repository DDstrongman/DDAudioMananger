//
//  DDAudioDiskCache.h
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAudioDiskCache : NSObject

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
/**
 在documents文件夹下创建对应name的沙盒缓存文件夹

 @param name 文件夹名
 @return 返回生成对象
 */
- (nullable instancetype)initWithFileName:(NSString *)name;
#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================
/**
 沙盒内是否存在指定url的文件

 @param key 指定文件的url
 @return 返回存在与否
 */
- (BOOL)containsObjectForKey:(NSString *)key;
/**
 播放指定url的文件

 @param key 指定url
 */
- (void)playAudioForKey:(NSString *)key;
/**
 设置缓存的文件到沙河

 @param object 缓存的文件
 @param key 缓存的key
 */
- (void)setObject:(nullable id<NSCoding>)object
           forKey:(NSString *)key;
/**
 设置缓存的文件到沙河
 
 @param object 缓存的文件
 @param key 缓存的key
 @param done 写完成之后进行block
 */
- (void)setObject:(nullable id<NSCoding>)object
           forKey:(NSString *)key
        DoneBlock:(void(^)(void))done;

/**
 删除对应url的缓存

 @param key 缓存的url
 */
- (void)removeObjectForKey:(NSString *)key;
/**
 删除沙盒缓存音频文件
 */
- (void)removeAllObjects;
/**
 缓存文件数量

 @return 返回数量
 */
- (NSInteger)totalCount;
/**
 缓存文件大小
 
 @return 返回大小，kb
 */
- (float)totalCost;


#pragma mark - Trim
///=============================================================================
/// @name Trim
///=============================================================================

/**
 Removes objects from the cache use LRU, until the `totalCount` is below the specified value.
 This method may blocks the calling thread until operation finished.
 
 @param count  The total count allowed to remain after the cache has been trimmed.
 */
//- (void)trimToCount:(NSUInteger)count;

/**
 Removes objects from the cache use LRU, until the `totalCost` is below the specified value.
 This method may blocks the calling thread until operation finished.
 
 @param cost The total cost allowed to remain after the cache has been trimmed.
 */
//- (void)trimToCost:(NSUInteger)cost;
/**
 Removes objects from the cache use LRU, until all expiry objects removed by the specified value.
 This method may blocks the calling thread until operation finished.
 
 @param age  The maximum age of the object.
 */
//- (void)trimToAge:(NSTimeInterval)age;

@end
