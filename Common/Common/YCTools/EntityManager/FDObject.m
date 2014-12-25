//
//  FDBObject.m
//  sdf
//
//  Created by wlpiaoyi on 14-3-25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "FDObject.h"
#import "FMDatabase.h"
#import "ReflectClass.h"
#import "Common.h"
@implementation FDObject
+(Enum_EntityType) getEnumEnityTypeIndex:(int) index  Number:(long long int) number{
    int offset = -1;
    double targetn = number*1.0;
    while (targetn>=1) {
        targetn /= 10;
        offset++;
    }
    offset -= index;
    if (offset<0) {
        printf("%s","array out of index");
        return 0;
    }
    targetn = number*1.0;
    for (int i=0; i<offset; i++) {
        targetn /= 10;
    }
    long long int result = targetn*1;
    result = result%10;
    return (int)result;
}
+(NSString*) getTableName:(Class<ProtocolEntity>) entity{
    NSString *table;
    if (class_getClassMethod(entity, @selector(getTable))) {
        table = [entity getTable];
    }else{
        table = [[NSString alloc] initWithCString:class_getName(entity) encoding:NSUTF8StringEncoding];
    }
    return table;
}
+(NSArray*) getColums:(Class<ProtocolEntity>) entity{
    NSArray *colums;
    if (class_getClassMethod(entity, @selector(getColums))) {
        colums = [entity getColums];
    }else{
        colums = [ReflectClass getAllPropertys:entity];
        [((NSMutableArray*)colums) removeObject:colums[0]];
    }
    
    return colums;
}
+(long long int) getTypes:(Class<ProtocolEntity>) entity Colums:(NSArray*) colums{
    long long int types = 0;
    if ([colums[0] isKindOfClass:[NSString class]]) {
        return [entity getTypes];
    }else{
        int index = 0;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[colums count]];
        for (NSDictionary *json in colums) {
            NSString *propertyName = [json objectForKey:@"propertyName"];
            Class clazz = [json objectForKey:@"class"];
            if (clazz==[NSNumber class]) {
                if ([propertyName stringEndWith:@"_f"])types += 2;
                else types += 1;
            }else if(clazz ==[NSString class]){
                types += 3;
            }else{
                types += 4;
            }
            [array addObject:propertyName];
            index++;
            types *=10;
        }
        [((NSMutableArray*)colums) removeAllObjects];
        [((NSMutableArray*)colums) addObjectsFromArray:array];
        return types/10;
    }
}
+(NSString*) getCreateSqlByEntity:(Class<ProtocolEntity>) entity{
    NSString *key = [entity getKey];
    NSString *table = [self getTableName:entity];
    NSArray *colums = [self getColums:entity];
    long long int types = [self getTypes:entity Colums:colums];
    NSString *columsql = [self getCreateColums:colums Types:types];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@)",table,key,columsql];
    return sql;
}

+(NSString*) getInsertSqlByEnityImpl:(id<ProtocolEntity>) entity{
    NSString *table = [self getTableName:[entity class]];
    NSArray *colums = [self getColums:[entity class]];
    [self getTypes:[entity class] Colums:colums];
    NSArray *sqls = [self getInsertColums:colums Entity:entity];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES %@",table,((NSString*)sqls[0]),((NSString*)sqls[1])];
    return sql;
}

+(NSArray*) getInsertColums:(NSArray*) colums Entity:(id<ProtocolEntity>) entity{
    NSString *columsql = nil;
    NSString *valuesql = @"(";
    for (NSString *arg in colums){
        id value = [((NSObject*)entity) valueForKey:arg];
        if (!value) {
            continue;
        }
        if ([value isKindOfClass:[NSString class]]) {
            if (![NSString isEnabled:value]) {
                continue;
            }
            value = [NSString stringWithFormat:@"'%@'",value];
        }
        
        if(columsql){
            columsql = [NSString stringWithFormat:@"%@,%@",columsql,arg];
            valuesql = [NSString stringWithFormat:@"%@,%@",valuesql,value];
        }else {
            columsql = arg;
            valuesql = [NSString stringWithFormat:@"%@%@",valuesql,value ];
        }
    }
    valuesql = [NSString stringWithFormat:@"%@%c",valuesql,')'];
    
    return [[NSArray alloc]initWithObjects:columsql,valuesql, nil];
}

+(NSString*) getInsertSqlByEnity:(Class<ProtocolEntity>) entity colums:(NSArray*) colums{
    NSString *table = [self getTableName:entity];
    [self getTypes:entity Colums:colums];
    NSArray *sqls = [self getInsertColums:colums];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES %@",table,((NSString*)sqls[0]),((NSString*)sqls[1])];
    return sql;
}


+(NSString*) getInsertSqlByEnity:(Class<ProtocolEntity>) entity{
    NSArray *colums = [self getColums:entity];
    return [self getInsertSqlByEnity:entity colums:colums];;
}
+(NSString*) getUpdateSqlByEnity:(Class<ProtocolEntity>) entity{
    NSString *key = [entity getKey];
    NSString *table = [self getTableName:entity];
    NSArray *colums = [self getColums:entity];
    [self getTypes:entity Colums:colums];
    NSString *sqls = [self getUpdateColums:colums];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?",table,sqls,key];
    return sql;
}

+(NSString*) getFindeSqlByEnity:(Class<ProtocolEntity>) entity{
    NSString *key = [entity getKey];
    NSString *table = [self getTableName:entity];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",table,key];
}
+(NSString*) getDeleteSqlByEnity:(Class<ProtocolEntity>) entity{
    NSString *key = [entity getKey];
    NSString *table = [self getTableName:entity];
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",table,key];
}

+(NSString*) getUpdateColums:(NSArray*) colums{
    NSString *columsql = nil;
    for (NSString *arg in colums) {
        if (columsql) {
            columsql = [NSString stringWithFormat:@"%@,%@ = ?", columsql,arg];
        }else{
            columsql = [NSString stringWithFormat:@"%@ = ?",arg];
        }
    }
    return columsql;
}
+(NSArray*) getInsertColums:(NSArray*) colums{
    NSString *columsql = nil;
    NSString *valuesql = @"(";
    for (NSString *arg in colums){
        if(columsql){
            columsql = [NSString stringWithFormat:@"%@,%@",columsql,arg];
            valuesql = [NSString stringWithFormat:@"%@,%c",valuesql,'?'];
        }else {
            columsql = arg;
            valuesql = [NSString stringWithFormat:@"%@%c",valuesql,'?'];
        }
    }
    valuesql = [NSString stringWithFormat:@"%@%c",valuesql,')'];
    
    return [[NSArray alloc]initWithObjects:columsql,valuesql, nil];
}
+(NSString*) getCreateColums:(NSArray*) colums Types:(long long int) types{
    NSString *columsql = @"";
    int index = 0;
    for (NSString *arg in colums) {
        char* _type_ = "";
        switch ([self getEnumEnityTypeIndex:index Number:types]) {
            case 1:
                _type_ = "INTEGER";
                break;
            case 2:
                _type_ = "REAL";
                break;
            case 3:
                _type_ = "TEXT";
                break;
            case 4:
                _type_ = "BLOB";
                break;
                
            default:
                break;
        }
        size_t i = strlen(_type_);
        if(!i){
            printf("Can't find the type on index:%d",index);
            continue;
        }
        if(index==0){
            columsql = [NSString stringWithFormat:@"%@ %s",arg,_type_];
        }else{
            columsql = [NSString stringWithFormat:@"%@,%@ %s",columsql,arg,_type_];
        }
        index++;
    }
    return columsql;
}
@end
