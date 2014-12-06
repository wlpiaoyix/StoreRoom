//
//  SimplePikerView.m
//  Common
//
//  Created by wlpiaoyi on 14/12/3.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SimplePikerView.h"
#import "SimplePikerTable.h"
#import "UIView+AutoRect.h"
#import "SimplePickerCell.h"

static NSString *CellIdentifier = @"CellIdentifierSimplePickerView";

@interface SimplePikerView(){
}
@property (nonatomic,strong) SimplePikerTable *table;
@property (nonatomic) BOOL autoSelectedFlag;
@end

@implementation SimplePikerView
-(id) init{
    if (self=[super init]) {
        _autoSelectedFlag = false;
        _table = [SimplePikerTable new];
        _table.delegate = self;
        _table.dataSource = self;
        [_table autoresizingMask_TBLRWH];
        self.frame = CGRectMake(0, 0, 20, 20);
        _table.frame = self.frame;
        [self addSubview:_table];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        self.cellUnSelectedBgColors =[NSArray arrayWithObjects:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1],[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1], nil];
        self.cellSelectedBgColor = [UIColor grayColor];
        
        __weak typeof(self) weakself = self;
        [_table setCallBackUnSelectedCell:^(UITableViewCell *cell,BOOL isauto) {
            NSIndexPath *index = [weakself.table indexPathForCell:cell];
            [weakself setBackgroundColorForCell:index cell:cell];
            if (isauto) {
                [cell setSelected:false];
            }
        }];
        [_table setCallBackSelectedCell:^(UITableViewCell *cell,BOOL isauto) {
            cell.backgroundColor = weakself.cellSelectedBgColor;
            NSIndexPath *index = [weakself.table indexPathForCell:cell];
            if (isauto) {
                [cell setSelected:YES];
                if (!weakself.autoSelectedFlag) {
                    if (weakself.delegate&&[weakself.delegate respondsToSelector:@selector(pickerCellDidSelected:)]) {
                        [weakself.delegate pickerCellDidSelected:[index row]];
                    }
                }
            }
            if (weakself.autoSelectedFlag) {
                weakself.autoSelectedFlag = false;
            }
            
        }];
        
    }
    return self;
}


-(void) scrollToRowAtIndex:(NSInteger) index animated:(BOOL) animated{
    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    self.autoSelectedFlag = true;
}

-(void) reloadData{
    [_table reloadData];
}

#pragma delegate UITableViewDelegate ==>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_delegate) {
        return [self.delegate pikerNumberOfRows:self];
    }
    return 0;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate&&[self.delegate respondsToSelector:@selector(picker:heightForRowAtIndex:)]) {
        [self.table setRowHeight:[_delegate picker:self heightForRowAtIndex:[indexPath row]]];
    }
    return self.table.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SimplePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SimplePickerCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setBackgroundColorForCell:indexPath cell:cell];
        if (_delegate) {
            UIView *subcell = [_delegate pickerGetCell:self];
            cell.subCell = subcell;
        }
        __weak typeof(self) weakself = self;
        [cell setCallBackPickerCellStatu:^(SimplePickerCell* cell, BOOL isSelected) {
            if (isSelected) {
                if (weakself.delegate&&[weakself.delegate respondsToSelector:@selector(pickerCellDidCheck:)]) {
                    [weakself.delegate pickerCellDidCheck:((SimplePickerCell*)cell).subCell];
                }
                
            }else{
                if (weakself.delegate&&[weakself.delegate respondsToSelector:@selector(pickerCellDidUnCheck:)]) {
                    [weakself.delegate pickerCellDidUnCheck:((SimplePickerCell*)cell).subCell];
                }
            }
        }];
    }
    if (_delegate) {
        [_delegate picker:self setCell:cell.subCell row:[indexPath row]];
    }
    
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [_table scrollViewDidEndDecelerating];
    }
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_table scrollViewDidEndDecelerating];
}
-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
}
#pragma delegate UITableViewDelegate <==


#pragma dataSource UITableViewDataSource ==>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma dataSource UITableViewDataSource <==

-(void) setBackgroundColorForCell:(NSIndexPath*) index cell:(UITableViewCell*) cell{
    UIColor *bgc = [_cellUnSelectedBgColors objectAtIndex:([index row]+1)%[_cellUnSelectedBgColors count]];
    cell.backgroundColor = bgc;
}
-(void) setMutipleValue:(float)mutipleValue{
    _mutipleValue = mutipleValue;
    PIKER_MUTIPLE_VALUE = mutipleValue;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
