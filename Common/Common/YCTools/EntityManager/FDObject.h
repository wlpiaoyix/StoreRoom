//
//  FDObject.h
//  sdf
//
//  Created by wlpiaoyi on 14-3-25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ProtocolEntity<NSObject>
@required
+(NSString*) getKey;
//@optional
+ (NSArray*) getColums;
+(long long int) getTypes;
+(NSString*) getTable;
@end
typedef enum{
    DEFAULT,
    INTEGER,
    REAL,
    TEXT,
    BLOB
} Enum_EntityType;
@interface FDObject : NSObject
+(Enum_EntityType) getEnumEnityTypeIndex:(int) index Number:(long long int) number;
+(NSString*) getCreateSqlByEntity:(Class<ProtocolEntity>) entity;
+(NSString*) getInsertSqlByEnity:(Class<ProtocolEntity>) entity colums:(NSArray*) colums;
+(NSString*) getInsertSqlByEnity:(Class<ProtocolEntity>) entity;
+(NSString*) getUpdateSqlByEnity:(Class<ProtocolEntity>) entity;
+(NSString*) getFindeSqlByEnity:(Class<ProtocolEntity>) entity;
+(NSString*) getDeleteSqlByEnity:(Class<ProtocolEntity>) entity;
+(NSString*) getInsertSqlByEnityImpl:(id<ProtocolEntity>) entity;
@end
