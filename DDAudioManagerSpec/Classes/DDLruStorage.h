//
//  DDLruStorage.h
//  AFNetworking
//
//  Created by littlelight.ai on 2018/9/4.
//

#import <Foundation/Foundation.h>


/**
 DDSqiliteManager专用的存储model
 */
@interface DDKVStorageModel : NSObject

@property (nonatomic, strong) NSString *key;                ///< key
@property (nonatomic) float size;                             ///< value's size in kb
@property (nonatomic) int modTime;                          ///< modification since1970 timestamp
@property (nonatomic) int accessNum;                       ///< access times number
@property (nonatomic) int accessTime;                       ///< last access since1970 timestamp

@end

@interface DDLruFIFOQueue : NSObject

/**
 队列容量，必须大于0，小于等于0默认为无限制
 */
@property (nonatomic, assign) NSInteger queueNum;
/**
 队列size最大容量，必须大于0，小于等于0默认无限制
 */
@property (nonatomic, assign) NSInteger queueSize;
/**
 lru-k
 */
@property (nonatomic, assign) NSInteger lruKLimit;
/**
 队列可变数组
 */
@property (nonatomic, strong) NSMutableArray *queueArr;

- (instancetype)initWithLruKLimit:(NSInteger)lruKLimit;
- (BOOL)insertQueue:(DDKVStorageModel *)item;

@end

/**
 全程参考了YYCache里的处理类
 */
@interface DDLruStorage : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/// The path of this storage.
@property (nonatomic, readonly) NSString *path;
///Lru-k 刷新的最低使用频次要求，默认为1
@property (nonatomic, assign) NSInteger lruKNum;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 The designated initializer.
 
 @param dbName  name of DB
 @return  A new storage object, or nil if an error occurs.
 @warning Multiple instances with the same path will make the storage unstable.
 */
- (nullable instancetype)initWithDBName:(NSString *)dbName NS_DESIGNATED_INITIALIZER;


#pragma mark - Save Items
///=============================================================================
/// @name Save Items
///=============================================================================

/**
 Save an item or update the item with 'key' if it already exists.
 
 @discussion This method will save the item.key, item.value, item.filename and
 item.extendedData to sqlite, other properties will be ignored. item.key
 and item.value should not be empty (nil or zero length).
 
 system saved to sqlite.
 
 @param item  An item.
 @return save result bool
 */
- (BOOL)saveItem:(DDKVStorageModel *)item;
#pragma mark - Remove Items
///=============================================================================
/// @name Remove Items
///=============================================================================

/**
 Remove an item with 'key'.
 
 @param key The item's key.
 @return remove result bool
 */
- (BOOL)removeItemForKey:(NSString *)key;

/**
 Remove items with an array of keys.
 
 @param keys An array of specified keys.
 @return remove result bool
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

/**
 Remove all items which `value` is larger than a specified size.
 
 @param size  The maximum size in kb.
 @return remove result bool
 */
- (BOOL)removeItemsLargerThanSize:(float)size;

/**
 Remove all items which last access time is earlier than a specified timestamp.
 
 @param time  The specified unix timestamp.
 @return remove result bool
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 Remove items to make the total size not larger than a specified size.
 The least recently used (LRU-k) items will be removed first.
 
 @param maxSize The specified size in kb.
 @param fileBlock diskcache delete files block
 @return remove result bool
 */
- (BOOL)removeItemsToFitSize:(float)maxSize deleteFileBlock:(void(^)(NSString *key))fileBlock;

/**
 Remove items to make the total count not larger than a specified count.
 The least recently used (LRU-k) items will be removed first.
 
 @param maxCount The specified item count.
 @param fileBlock diskcache delete files block
 @return remove result bool
 */
- (BOOL)removeItemsToFitCount:(int)maxCount deleteFileBlock:(void(^)(NSString *key))fileBlock;

/**
 Remove all items in background queue.
 
 @return remove result bool.
 */
- (BOOL)removeAllItems;


#pragma mark - Get Items
///=============================================================================
/// @name Get Items
///=============================================================================

/**
 Get item with a specified key.
 
 @param key A specified key.
 @return Item for the key, or nil if not exists / error occurs.
 */
- (nullable DDKVStorageModel *)getItemForKey:(NSString *)key;

/**
 Get items with an array of keys.
 
 @param keys  An array of specified keys.
 @return An array of `YYKVStorageItem`, or nil if not exists / error occurs.
 */
- (nullable NSArray<DDKVStorageModel *> *)getItemForKeys:(NSArray<NSString *> *)keys;
#pragma mark - Get Storage Status
///=============================================================================
/// @name Get Storage Status
///=============================================================================

/**
 Whether an item exists for a specified key.
 
 @param key  A specified key.
 
 @return `YES` if there's an item exists for the key, `NO` if not exists or an error occurs.
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 Get total item count.
 @return Total item count
 */
- (int)getItemsCount;

/**
 Get item value's total size in kb.
 @return Total size in kb
 */
- (float)getItemsSize;

@end
