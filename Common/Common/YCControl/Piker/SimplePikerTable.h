//
//  SimplePikerTable.h
//  Common
//
//  Created by wlpiaoyi on 14/12/3.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//


#import <UIKit/UIKit.h>

extern float PIKER_MUTIPLE_VALUE;
extern float PIKER_DELERATIONRATE;


typedef void (^CallBackUnSelectedCell) (UITableViewCell *cell,BOOL isauto);
typedef void (^CallBackSelectedCell) (UITableViewCell *cell,BOOL isauto);

@interface SimplePikerTable : UITableView
@property (readonly) float scrolloffy;
@property (nonatomic) BOOL flagOffy;
@property (nonatomic,readonly) NSInteger lastRow;
@property (nonatomic,readonly) NSInteger curRow;
-(void) scrollViewDidEndDecelerating;
-(void) setCallBackUnSelectedCell:(CallBackUnSelectedCell) callback;
-(void) setCallBackSelectedCell:(CallBackSelectedCell) callBack;
@end
