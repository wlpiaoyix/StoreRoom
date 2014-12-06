//
//  SimplePikerView.h
//  Common
//
//  Created by wlpiaoyi on 14/12/3.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimplePikerViewDelegate;


/**
 滚动选择器
 */
@interface SimplePikerView : UIView<UITableViewDataSource,UITableViewDelegate>
/**
 事件操作的协议
*/
 @property (nonatomic,assign) id<SimplePikerViewDelegate> delegate;
/**
 目标的放大率 >0
*/
 @property (nonatomic) float mutipleValue;
/**
 选种背景
 */
@property (nonatomic,strong) UIColor *cellSelectedBgColor;
/**
 未选中的背景
 */
@property (nonatomic,strong) NSArray *cellUnSelectedBgColors;
/**
 跳转到指定的行
 */
-(void) scrollToRowAtIndex:(NSInteger) index animated:(BOOL) animated;
/**
 重载数据
 */
-(void) reloadData;
@end


@protocol SimplePikerViewDelegate<NSObject>
@required
-(UIView*) pickerGetCell:(SimplePikerView*) piker;
-(NSInteger) pikerNumberOfRows:(SimplePikerView*) piker;
-(void) picker:(SimplePikerView*) piker setCell:(UIView*) setcell row:(NSInteger) row;
@optional
-(CGFloat) picker:(SimplePikerView*) piker heightForRowAtIndex:(NSInteger) row;
-(void) pickerCellDidSelected:(NSInteger) row;
-(void) pickerCellDidCheck:(UIView*) cell;
-(void) pickerCellDidUnCheck:(UIView*) cell;
@end
