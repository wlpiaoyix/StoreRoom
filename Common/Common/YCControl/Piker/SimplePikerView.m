//
//  SimplePikerView.m
//  Common
//
//  Created by wlpiaoyi on 14/12/3.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SimplePikerView.h"
#import "SimplePikerTable.h"
#import "UIView+Expand.h"
#import "SimplePickerCell.h"

static NSString *CellIdentifier = @"CellIdentifierSimplePickerView";

@interface SimplePikerView(){
    id synlastCell;
}
@property (nonatomic,strong) SimplePikerTable *table;
//@property (nonatomic,strong) SimplePickerCell *lastCell;
@property (nonatomic) NSInteger lastRow;
@property (nonatomic) BOOL flagSelectedRow;
@end

@implementation SimplePikerView
-(id) init{
    if (self=[super init]) {
        _rowSkip = -1;
        _lastRow = -1;
//        _lastCell = nil;
        synlastCell = @"";
        
        _table = [SimplePikerTable new];
        _table.delegate = self;
        _table.dataSource = self;
        [_table autoresizingMask_TBLRWH];
        self.frame = CGRectMake(0, 0, 20, 20);
        _table.frame = self.frame;
        [self addSubview:_table];
        
        self.selectedWhenScroll = true;
        self.flagSelectedRow = false;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        self.cellUnSelectedBgColors =[NSArray arrayWithObjects:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1],[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1], nil];
        self.cellSelectedBgColor = [UIColor grayColor];
        
        __weak typeof(self) weakself = self;
        [_table setCallBackUnSelectedCell:^(UITableViewCell *cell,BOOL isauto) {
            if (weakself.selectedWhenScroll) {
                [weakself unSelectedCell];
            }
        }];
        [_table setCallBackSelectedCell:^(UITableViewCell *cell,BOOL isauto) {
            NSIndexPath *index = [weakself.table indexPathForCell:cell];
            if (isauto) {
                [weakself selectedCell:cell row:[index row]];
            }
        }];
        
    }
    return self;
}
-(void) setRowSkip:(NSInteger)rowSkip{
    [self setRowSkip:rowSkip animated:NO];
}

-(void) setRowSkip:(NSInteger)rowSkip animated:(BOOL) animated{
    self.flagSelectedRow = true;
    [self setRowSkipListner:rowSkip animated:animated];
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
    }else{
        [self.table setRowHeight:44.0f];
    }
    return self.table.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SimplePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SimplePickerCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_delegate) {
            UIView *subcell = [_delegate pickerGetCell:self];
            cell.subCell = subcell;
        }
        [cell setCallBackPickerCellStatu:^(SimplePickerCell* cell, BOOL isSelected) {
            [self setCallBackCell:cell isSelected:isSelected];
        }];
    }
    [self setSelectedWithScrollBackgroundWithCell:cell row:[indexPath row]];
    if (_delegate) {
        [_delegate picker:self setCell:cell.subCell row:[indexPath row]];
    }
    
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self setSelectedWhenScrollWithScrollViewDidEndDecelerating];
    }
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setSelectedWhenScrollWithScrollViewDidEndDecelerating];
}
-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
}
#pragma delegate UITableViewDelegate <==


#pragma dataSource UITableViewDataSource ==>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self setRowSkipListner:[indexPath row] animated:NO];
}


#pragma dataSource UITableViewDataSource <==


-(void) setMutipleValue:(float)mutipleValue{
    _mutipleValue = mutipleValue;
    PIKER_MUTIPLE_VALUE = mutipleValue;
}

-(void) setCallBackCell:(UITableViewCell*) cell isSelected:(BOOL) isSelected{
    if (isSelected) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pickerCellDidCheck:)]) {
            [self.delegate pickerCellDidCheck:((SimplePickerCell*)cell).subCell];
        }
    }else{
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pickerCellDidUnCheck:)]) {
            [self.delegate pickerCellDidUnCheck:((SimplePickerCell*)cell).subCell];
        }
    }
}
-(void) setRowSkipListner:(NSInteger)rowSkip animated:(BOOL) animated{
    _rowSkip = rowSkip;
    if (self.selectedWhenScroll) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowSkip inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }else{
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowSkip inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
    }
}

-(void) selectedCell:(UITableViewCell*) cell row:(NSInteger) row{
    [self unSelectedCell];
    @synchronized(synlastCell){
        @try {
            cell.backgroundColor = self.cellSelectedBgColor;
            [((SimplePickerCell*)cell) setSelectedStatus:YES];
            
            if (!self.flagSelectedRow&&self.delegate&&[self.delegate respondsToSelector:@selector(pickerCellDidSelected:)]) {
                [self.delegate pickerCellDidSelected:row];
            }else{
                self.flagSelectedRow = false;
            }
        }
        @finally {
            _lastRow = row;
        }
    }
}
-(void) unSelectedCell{
    @synchronized(synlastCell){
        if (_lastRow>=0) {
            int index = (_lastRow+1)%[_cellUnSelectedBgColors count];
            UIColor *bgc = [_cellUnSelectedBgColors objectAtIndex:index];
            SimplePickerCell *lastCell = (SimplePickerCell*)[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastRow inSection:0]];
            lastCell.backgroundColor = bgc;
            [((SimplePickerCell*)[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastRow inSection:0]]) setSelectedStatus:NO];
        }
        _lastRow = -1;
    }
}


-(void) setSelectedWithScrollBackgroundWithCell:(UITableViewCell*) cell row:(NSInteger) row{
    if (self.selectedWhenScroll) {
        UIColor *bgc = [_cellUnSelectedBgColors objectAtIndex:(row+1)%[_cellUnSelectedBgColors count]];
        cell.backgroundColor = bgc;
    }else{
        if (_rowSkip==row) {
            cell.backgroundColor = self.cellSelectedBgColor;
            [((SimplePickerCell*)cell) setSelectedStatus:YES];
        }else{
            UIColor *bgc = [_cellUnSelectedBgColors objectAtIndex:(row+1)%[_cellUnSelectedBgColors count]];
            cell.backgroundColor = bgc;
            [((SimplePickerCell*)cell) setSelectedStatus:NO];
        }
    }
}
-(void) setSelectedWhenScrollWithScrollViewDidEndDecelerating{
    if (self.selectedWhenScroll) {
        self.flagSelectedRow = false;
        [_table scrollViewDidEndDecelerating];
    }
}
-(void) setSelectedWhenScroll:(BOOL)selectedWhenScroll{
    _selectedWhenScroll = selectedWhenScroll;
    _table.flagOffy = _selectedWhenScroll;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
