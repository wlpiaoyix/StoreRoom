//
//  FDEntityManager.h
//  sdf
//
//  Created by wlpiaoyi on 14-3-25.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDObject.h"

@interface FDEntityManager : NSObject
-(id) initWithDBName:(NSString *) dbName;
-(id) getDatabase;
-(BOOL) beginTransation;
-(int) commitTarnsation;
- (BOOL)rollbackTarnsation;
-(id<ProtocolEntity>) find:(NSNumber*)  key Clazz:(Class<ProtocolEntity>) clazz;
-(int) persist:(id<ProtocolEntity>) entity;
-(int) persistArray:(NSArray*) entitys;
-(id<ProtocolEntity>) merge:(id<ProtocolEntity>) entity;
-(bool) remove:(id<ProtocolEntity>) entity;
-(bool) excuSql:(NSString*) sql Params:(NSArray*) params;
-(NSArray*) queryBySql:(NSString*) sql Clazz:(Class<ProtocolEntity>) clazz Params:(NSArray*) params;
-(NSArray*) queryBySql:(NSString *)sql Params:(NSArray *)params;
-(NSArray*) queryBySqlDic:(NSString *)sql Params:(NSArray *)params;
@end
