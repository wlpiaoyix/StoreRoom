//
//  FDEntityManager.m
//  sdf
//
//  Created by wlpiaoyi on 14-3-25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "FDEntityManager.h"
#import "FMDB.h"
#import "Common.h"
@implementation FDEntityManager{
@protected
    FMDatabase *db ;
}
-(id) init{
    if(self = [super init]){
        self->db = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@/%@",documentDir,@"entities.db"]];
        if(![db open]){
            printf("open database faild!\n");
            return nil;
        }
        printf("open database success!\n");
    }
    return self;
}
-(id) initWithDBName:(NSString *) dbName{
    if(self = [super init]){
        self->db = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@/%@",documentDir,dbName]];
        if(![db open]){
            printf("open database faild!\n");
            return nil;
        }
        printf("open database success!\n");
    }
    return self;}
-(id) getDatabase{
    return (id)db;
}

-(BOOL) beginTransation{
    BOOL b = [db executeUpdate:@"begin"];
    return b;
}
-(int) commitTarnsation{
    int b = [db executeUpdate:@"commit"];
    return b;
}
- (BOOL)rollbackTarnsation {
    BOOL b = [db executeUpdate:@"rollback"];
    return b;
}
-(id<ProtocolEntity>) find:(NSNumber*) key Clazz:(Class<ProtocolEntity>) clazz{
    NSString *sql = [FDObject getFindeSqlByEnity:clazz];
    FMResultSet *result = [db executeQuery:sql,key];
    NSArray *array = [FDEntityManager parse:clazz ToResult:result];
    return (array&&[array count])?array[0]:nil;
}

-(int) persistArray:(NSArray*) entitys{
    [self beginTransation];
    NSMutableString *sqls = [NSMutableString new];
    BOOL flagxx = false;
    for(id<ProtocolEntity> entity in entitys){
        NSString *sql = [FDObject getInsertSqlByEnityImpl:entity];
        if (flagxx) {
            [sqls appendString:@";"];
        }else{
            flagxx = true;
        }
       [sqls appendString:sql];
    }
    [self commitTarnsation];
    return 0;
}
-(int) persist:(id<ProtocolEntity>) entity{
    @try {
        NSString *sql = [FDObject getInsertSqlByEnity:[entity class]];
        NSArray *colums = [[entity class] getColums];
        NSMutableArray *values = [NSMutableArray new];
        for (NSString *arg in colums) {
            id value = [FDEntityManager getEntity:entity Property:arg];
            value = [FDEntityManager chekcValue:value Index:(int)[colums indexOfObject:arg] Number:[[entity class] getTypes]];
            [values addObject:value];
        }
        int _id = [db executeUpdate:sql withArgumentsInArray:values];
        if(_id>0){
            return _id;
        }
        return 0;
    }
    @catch (NSException *exception) {
        @throw [[NSException alloc] initWithName:@"persistException" reason:exception.reason userInfo:nil];
    }
}
-(id<ProtocolEntity>) merge:(id<ProtocolEntity>) entity{
    @try {
        NSString *sql = [FDObject getUpdateSqlByEnity:[entity class]];
        NSString *_key = [[entity class] getKey];
        NSArray *colums = [[entity class] getColums];
        NSMutableArray *values = [NSMutableArray new];
        for (NSString *arg in colums) {
            id value = [FDEntityManager getEntity:entity Property:arg];
            value = [FDEntityManager chekcValue:value Index:(int)[colums indexOfObject:arg] Number:[[entity class] getTypes]];
            [values addObject:value];
        }
        [values addObject:[FDEntityManager getEntity:entity Property:_key]];
        if([db executeUpdate:sql withArgumentsInArray:values]){
            return entity;
        }
        return nil;
    }
    @catch (NSException *exception) {
        @throw [[NSException alloc] initWithName:@"mergeException" reason:exception.reason userInfo:nil];
    }
}
-(bool) remove:(id<ProtocolEntity>) entity{
    @try {
        NSString *sql = [FDObject getDeleteSqlByEnity:[entity class]];
        NSNumber *key = [FDEntityManager getEntity:entity Property:[[entity class] getKey]];
        return [db executeUpdate:sql,key];
    }
    @catch (NSException *exception) {
        @throw [[NSException alloc] initWithName:@"removeException" reason:exception.reason userInfo:nil];
    }
}
-(NSArray*) queryBySql:(NSString*) sql Clazz:(Class<ProtocolEntity>) clazz Params:(NSArray*) params{
    FMResultSet *result;
    if (params&&[params count]) {
        result = [db executeQuery:sql withArgumentsInArray:params];
    }else{
        result = [db executeQuery:sql];
    }
    NSArray *array = [FDEntityManager parse:clazz ToResult:result];
    return array;
}
-(NSArray*) queryBySql:(NSString *)sql Params:(NSArray *)params{
    FMResultSet *result;
    if (params&&[params count]) {
        result = [db executeQuery:sql withArgumentsInArray:params];
    }else{
        result = [db executeQuery:sql];
    }
    NSArray *array = [FDEntityManager parseResult:result];
    return array;
}
-(NSArray*) queryBySqlDic:(NSString *)sql Params:(NSArray *)params{
    FMResultSet *result;
    if (params&&[params count]) {
        result = [db executeQuery:sql withArgumentsInArray:params];
    }else{
        result = [db executeQuery:sql];
    }
    NSArray *array = [FDEntityManager parseDictionary:result];
    return array;
}
-(bool) excuSql:(NSString*) sql Params:(NSArray*) params{
    if (params) {
        return [db executeUpdate:sql withArgumentsInArray:params];
    }else{
        return [db executeUpdate:sql];
    }
}
-(void) dealloc{
    [db close];
}
+(void) setEntity:(id<ProtocolEntity>) entity Property:(NSString*) property Value:(id) value{
    NSString *method = [NSString stringWithFormat:@"set%@%@:",[[[property substringToIndex:1] substringFromIndex:0] uppercaseString],[[property substringToIndex:property.length] substringFromIndex:1]] ;
    SEL sel =  NSSelectorFromString(method);
    [entity performSelector:sel withObject:value];
}

+(id) chekcValue:(id) value Index:(int) index Number:(long long int) number{
    if(!value){
        int type= [FDObject getEnumEnityTypeIndex:index Number:number];
        switch (type) {
            case 1:
            {
                value = [NSNumber numberWithInt:0];
            }
                break;
            case 2:
            {
                value = [NSNumber numberWithInt:0];
            }
                break;
            case 3:
            {
                value = @"";
            }
                break;
            case 4:
            {
                value = [NSData new];
            }
                break;
            default:
                value = @"";
                break;
        }
    }
    return value;
}
+(id) getEntity:(id<ProtocolEntity>) entity Property:(NSString*) property{
    SEL sel =  NSSelectorFromString(property);
    id value = [entity performSelector:sel];
    return value;
}
+(id) parse:(Class<ProtocolEntity>) clazz ToResult:(FMResultSet*) result{
    NSMutableArray *array = [NSMutableArray new];
    NSString *_key = [clazz getKey];
    NSArray *colums = [clazz getColums];
    long long int types = [clazz getTypes];
    while ([result next]) {
        int index = 0;
        id<ProtocolEntity> entity = (id<ProtocolEntity>)[NSClassFromString(NSStringFromClass(clazz)) new];
        while (index<[result columnCount]) {
            id value = nil;
            if(index==0){
                NSNumber *num = [NSNumber numberWithInt:[result intForColumnIndex:0]];
                [FDEntityManager setEntity:entity Property:_key Value:num];
                index ++;
                continue;
            }
            int type = [FDObject getEnumEnityTypeIndex:index-1 Number:types];
            switch (type) {
                case 1:
                {
                    value = [NSNumber numberWithInt:[result intForColumnIndex:index]];
                }
                    break;
                case 2:
                {
                    value = [NSNumber numberWithInt:[result intForColumnIndex:index]];
                }
                    break;
                case 3:
                {
                    value = [result stringForColumnIndex:index];
                }
                    break;
                case 4:
                {
                    value = [result dataForColumnIndex:index];
                }
                    break;
                    
                default:
                    break;
            }
            [FDEntityManager setEntity:entity Property:colums[index-1] Value:value];
            index++;
        }
        [array addObject:entity];
    }
    return array;
}
+(id) parseResult:(FMResultSet*) result{
    NSMutableArray *array = [NSMutableArray new];
    while ([result next]) {
        int index = 0;
        NSMutableArray *values = [NSMutableArray new];
        while (index<[result columnCount]) {
            id value = [result objectForColumnIndex:index];
            [values addObject:value];
            index++;
        }
        [array addObject:values];
    }
    return array;
}
+(id) parseDictionary:(FMResultSet*) result{
    NSMutableArray *array = [NSMutableArray new];
    while ([result next]) {
        int index = 0;
        NSMutableArray *values = [NSMutableArray new];
        while (index<[result columnCount]) {
            id value = [result objectForColumnIndex:index];
            NSString *key = [result columnNameForIndex:index];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:value forKey:key];
            [values addObject:dic];
            index++;
        }
        [array addObject:values];
    }
    return array;
}

@end
