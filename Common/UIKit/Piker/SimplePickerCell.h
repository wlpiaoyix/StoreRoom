//
//  SimplePickerCell.h
//  Common
//
//  Created by wlpiaoyi on 14/12/4.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SimplePickerCell;

typedef void (^CallBackPickerCellStatu) (SimplePickerCell *cell,BOOL isSelected);

@interface SimplePickerCell : UITableViewCell
@property (nonatomic) UIEdgeInsets edgeInsetsCellView;
@property (nonatomic) UIView *subCell;
@property (nonatomic)  BOOL selectedStatus;
-(void) setCallBackPickerCellStatu:(CallBackPickerCellStatu) callback;
@end
