//
//  SimplePickerView.h
//  SimplePickerView
//
//  Created by Iman Zarrabian on 02/11/12.
//  Copyright (c) 2012 Iman Zarrabian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SimplePickerView;

@protocol SimplePickerViewDelegate <NSObject>

- (void)selector:(SimplePickerView *)valueSelector didSelectRowAtIndex:(NSInteger)index;
@end

@protocol SimplePickerViewDataSource <NSObject>
- (NSInteger)numberOfRowsInSelector:(SimplePickerView *)valueSelector;
- (UIView *)selector:(SimplePickerView *)valueSelector viewForRowAtIndex:(NSInteger) index;
- (CGRect)rectForSelectionInSelector:(SimplePickerView *)valueSelector;
- (CGFloat)rowHeightInSelector:(SimplePickerView *)valueSelector;
- (CGFloat)rowWidthInSelector:(SimplePickerView *)valueSelector;
@end



@interface SimplePickerView : UIView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) id <SimplePickerViewDelegate> delegate;
@property (nonatomic,assign) id <SimplePickerViewDataSource> dataSource;
@property (nonatomic,assign) BOOL shouldBeTransparent;
@property (nonatomic,assign) BOOL horizontalScrolling;

-(void) scrollToSelectedRowAtScrollPositionWidthIndex:(NSInteger) index;
- (void)reloadData;

@end
