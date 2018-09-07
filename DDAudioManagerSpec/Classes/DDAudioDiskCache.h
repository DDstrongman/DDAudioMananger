//
//  DDAudioDiskCache.h
//  DDAudioManager
//
//  Created by littlelight.ai on 2018/8/24.
//  Copyright © 2018年 DDSanLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAudioDiskCache : NSObject

#pragma mark - Attribute 所有硬盘缓存参考自YYCache
///=============================================================================
/// @name Attribute
///=============================================================================

/**
缓存数量限制
*/
@property (nonatomic, assign) int diskTrimCount;
/**
 缓存文件大小size限制
 */
@property (nonatomic, assign) float diskTrimSize;

#pragma mark - Initializer  所有硬盘缓存参考自YYCache
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
 通过LRU-k算法删除超过数量限制的文件

 @param count 限制的数量
 */
- (void)trimToCount:(int)count;
/**
 通过LRU-k算法删除超过大小限制之后的文件

 @param cost 限制的大小
 */
- (void)trimToCost:(float)cost;

@end
