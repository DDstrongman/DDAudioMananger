//
//  DDLruStorage.m
//  AFNetworking
//
//  Created by littlelight.ai on 2018/9/4.
//

#import "DDLruStorage.h"

#import "DDDBSearchHisManager.h"
#import "MJExtension.h"
#import "NSString+DDExt.h"

@implementation DDKVStorageModel

@end

@interface DDLruFIFOQueue ()

{
    float queueCurrentSize;
}

@end

@implementation DDLruFIFOQueue

- (instancetype)initWithLruKLimit:(NSInteger)lruKLimit {
    if (self = [super init]) {
        _queueArr = [NSMutableArray array];
        _lruKLimit = lruKLimit;
        queueCurrentSize = 0.0;
    }
    return self;
}

- (BOOL)insertQueue:(DDKVStorageModel *)item {
    if (!item) return NO;
    
    if (_queueNum && _queueNum > 0) {
        if (_queueArr.count >= _queueNum) {
            return NO;
        }else {
            if ((queueCurrentSize + item.size < _queueSize || _queueSize == 0) && item.accessNum >= _lruKLimit) {
                [_queueArr addObject:item];
                queueCurrentSize += item.size;
                return YES;
            }
        }
    }else {
        if (item.accessNum >= _lruKLimit) {
            if (queueCurrentSize + item.size < _queueSize) {
                [_queueArr addObject:item];
                queueCurrentSize += item.size;
                return YES;
            }
        }
    }
    return NO;
}

@end

@interface DDLruStorage ()

{
    DDLruFIFOQueue *lruQueue; ///< 根据lru-k选出的lruQueue
}
/// The path of this storage.
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FMDatabase *storeDB;

@end;

static NSString *DDLruStorTable = @"DDLruStorTable";
@implementation DDLruStorage

#pragma mark - init method
- (nullable instancetype)initWithDBName:(NSString *)dbName {
    if (self = [super init]) {
        if ([[DDDBSearchHisManager ShareInstance]creatDatabase:dbName]) {
            _storeDB = [DDDBSearchHisManager ShareInstance].searchHisDB;
            [self isTableExist:DDLruStorTable];
            _lruKNum = 0;
            NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            _path = [docsdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",dbName]];
            lruQueue = [[DDLruFIFOQueue alloc]initWithLruKLimit:_lruKNum];
        }
    }
    return self;
}

- (void)setLruKNum:(NSInteger)lruKNum {
    _lruKNum = lruKNum;
    lruQueue.lruKLimit = _lruKNum;
}
#pragma mark - saveItems
- (BOOL)saveItem:(DDKVStorageModel *)item {
    NSString *key = item.key;
    if ([self itemExistsForKey:key])
        return [[DDDBSearchHisManager ShareInstance]updateTableObj:DDLruStorTable
                                                         SearchDic:@{@"key":key}
                                                           DataDic:item.mj_keyValues];
    else
        return [[DDDBSearchHisManager ShareInstance]insertTableObj:DDLruStorTable
                                                           DataDic:item.mj_keyValues];
}
#pragma mark - removeItems
- (BOOL)removeItemForKey:(NSString *)key {
    return [[DDDBSearchHisManager ShareInstance]deleTableOjb:DDLruStorTable
                                                   DeleteDic:@{@"key":key}];
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys {
    __block BOOL result = YES;
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [[DDDBSearchHisManager ShareInstance]deleTableOjb:DDLruStorTable DeleteDic:@{@"key":key}];
        if (!result)
            *stop = YES;
    }];
    return result;
}

- (BOOL)removeItemsToFitSize:(float)maxSize deleteFileBlock:(void (^)(NSString *))fileBlock {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ order by accessTime DESC",DDLruStorTable];
    FMResultSet *result = [self.storeDB executeQuery:sql];
    BOOL removeBool = YES;
    while ([result next]) {
        NSDictionary *tempDic = [result resultDictionary];
        DDKVStorageModel *model = [DDKVStorageModel mj_objectWithKeyValues:tempDic];
        lruQueue.queueSize = maxSize;
        if (![lruQueue insertQueue:model]) {
            if (fileBlock) {
                NSLog(@"删除了");
                fileBlock(model.key);
            }
            removeBool = [[DDDBSearchHisManager ShareInstance]deleTableOjb:DDLruStorTable DeleteDic:tempDic];
            if (!removeBool)
                break;
        }
    }
    return removeBool;
}

- (BOOL)removeItemsToFitCount:(int)maxCount deleteFileBlock:(void (^)(NSString *))fileBlock {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ order by accessTime DESC",DDLruStorTable];
    FMResultSet *result = [self.storeDB executeQuery:sql];
    BOOL removeBool = YES;
    while ([result next]) {
        NSDictionary *tempDic = [result resultDictionary];
        DDKVStorageModel *model = [DDKVStorageModel mj_objectWithKeyValues:tempDic];
        lruQueue.queueNum = maxCount;
        if (![lruQueue insertQueue:model]) {
            if (fileBlock) {
                NSLog(@"删除了");
                fileBlock(model.key);
            }
            removeBool = [[DDDBSearchHisManager ShareInstance]deleTableOjb:DDLruStorTable DeleteDic:tempDic];
            if (!removeBool)
                break;
        }
    }
    return removeBool;
}

- (BOOL)removeItemsLargerThanSize:(float)size {
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE size > %f",DDLruStorTable,size];
    return [self.storeDB executeUpdate:deleteSQL];
}

- (BOOL)removeItemsEarlierThanTime:(int)time {
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE accessTime < %d",DDLruStorTable,time];
    return [self.storeDB executeUpdate:deleteSQL];
}

- (BOOL)removeAllItems {
    return [[DDDBSearchHisManager ShareInstance]deleTableOjb:DDLruStorTable DeleteDic:nil];
    return YES;
}
#pragma mark - getItems
- (nullable DDKVStorageModel *)getItemForKey:(NSString *)key {
    FMResultSet *result = [[DDDBSearchHisManager ShareInstance]SearchOne:DDLruStorTable SearchDic:@{@"key":key}];
    DDKVStorageModel *model;
    while ([result next]) {
        NSDictionary *modelDic = [result resultDictionary];
        model = [DDKVStorageModel mj_objectWithKeyValues:modelDic];
        model.accessTime = [[@"" currentTimeSince1970] intValue];
        model.accessNum += 1;
        [[DDDBSearchHisManager ShareInstance]updateTableObj:DDLruStorTable
                                                  SearchDic:@{@"key":key}
                                                    DataDic:model.mj_keyValues];
    }
    return model;
}

- (nullable NSArray<DDKVStorageModel *> *)getItemForKeys:(NSArray<NSString *> *)keys {
    __block NSMutableArray *resultArr = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [resultArr addObject:[strongSelf getItemForKey:key]];
    }];
    return resultArr;
}
#pragma mark - get Class Status
- (BOOL)itemExistsForKey:(NSString *)key {
    FMResultSet *result = [[DDDBSearchHisManager ShareInstance]SearchOne:DDLruStorTable SearchDic:@{@"key":key}];
    return [result next];
}

- (int)getItemsCount {
    FMResultSet *result = [[DDDBSearchHisManager ShareInstance]SearchAll:DDLruStorTable];
    int i = 0;
    while ([result next]) {
        i++;
    }
    return i;
}

- (float)getItemsSize {
    FMResultSet *result = [[DDDBSearchHisManager ShareInstance]SearchAll:DDLruStorTable];
    float itemsSize = 0.00;
    while ([result next]) {
        float size = [[result stringForColumn:@"size"] floatValue];
        itemsSize += size;
    }
    return itemsSize;
}

#pragma mark - DB methods
- (BOOL)isTableExist:(NSString *)tName {
    if(![self.storeDB tableExists:tName]) {
        NSString *sql = [NSString stringWithFormat:@"create table %@ (prikey INTEGER PRIMARY KEY AUTOINCREMENT,key TEXT,size REAL,modTime INTEGER,accessNum INTEGER,accessTime INTEGER)",tName];
        return [self.storeDB executeUpdate:sql];
    }else {
        return YES;
    }
}

@end
