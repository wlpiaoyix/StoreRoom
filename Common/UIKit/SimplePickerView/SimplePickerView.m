//
//  SimplePickerView.m
//  SimplePicker
//
//  Created by Iman Zarrabian on 02/11/12.
//  Copyright (c) 2012 Iman Zarrabian. All rights reserved.
//

#import "Common.h"
#import "SimplePickerView.h"
#import <QuartzCore/QuartzCore.h>
@interface SimplePickerView()
@property (nonatomic) NSInteger selecteIndex;
@property (nonatomic, strong) UITableView *contentTableView;
@end

@implementation SimplePickerView {
    CGRect selectionRect;
    id synScroll;
    bool ifscrollflag;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.horizontalScrolling = NO;
        self.selecteIndex = 0;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.horizontalScrolling = NO;
        self.selecteIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    if (self.contentTableView == nil) {
        [self createContentTableView];
    }
    [super layoutSubviews];
}



- (void)createContentTableView {
    synScroll = @"";
    ifscrollflag = false;
    CGRect r = self.frame;
    selectionRect = [self.dataSource rectForSelectionInSelector:self];
    UIImageView *selectionImageViewPre = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    UIImageView *selectionImageViewNext = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    UIImageView *imageLine01 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_line_check.png"]];
    UIImageView *imageLine02 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_line_check.png"]];
    if(self.horizontalScrolling){
    }else{
        imageLine01.frame = CGRectMake(0, selectionRect.origin.y, selectionRect.size.width, 1);
        imageLine02.frame = CGRectMake(0, selectionRect.origin.y+selectionRect.size.height, selectionRect.size.width, 1);
    }
    if (self.horizontalScrolling) {
        selectionImageViewPre.frame = CGRectMake(0, 0, selectionRect.origin.x,selectionRect.size.height);
        selectionImageViewNext.frame = CGRectMake(selectionRect.origin.x+selectionRect.size.width, 0, r.size.width-selectionRect.origin.x-selectionRect.size.width,selectionRect.size.height);
    }else{
        selectionImageViewPre.frame = CGRectMake(0, 0, selectionRect.size.width,selectionRect.origin.y);
        selectionImageViewNext.frame = CGRectMake(0, selectionRect.origin.y+selectionRect.size.height, selectionRect.size.width,r.size.height- selectionRect.origin.y-selectionRect.size.height);
    }
    if (self.shouldBeTransparent) {
        selectionImageViewPre.alpha = 0.8;
        selectionImageViewNext.alpha = 0.8;
    }
    if (self.horizontalScrolling) {
        //In this case user might have created a view larger than taller
        self.contentTableView = [[UITableView alloc] initWithFrame:self.frame];
    }
    else {
        self.contentTableView = [[UITableView alloc] initWithFrame:self.bounds];
    }

    // Initialization code
    CGFloat OffsetCreated = 0.0;
    
    //If this is an horizontal scrolling we have to rotate the table view
    if (self.horizontalScrolling) {
        CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
        self.contentTableView.transform = rotateTable;
        
        OffsetCreated = self.contentTableView.frame.origin.x;
        self.contentTableView.frame = self.bounds;
    }
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.horizontalScrolling) {
        self.contentTableView.rowHeight = [self.dataSource rowWidthInSelector:self];
    }
    else {
        self.contentTableView.rowHeight = [self.dataSource rowHeightInSelector:self];
    }
    r = self.contentTableView.frame;
    if (self.horizontalScrolling) {
        self.contentTableView.contentInset = UIEdgeInsetsMake( selectionRect.origin.x ,  0,r.size.height - selectionRect.origin.x - selectionRect.size.width - 2*OffsetCreated, 0);
    }
    else {
        self.contentTableView.contentInset = UIEdgeInsetsMake( selectionRect.origin.y, 0, r.size.height - selectionRect.origin.y - selectionRect.size.height  , 0);
    }
    self.contentTableView.scrollEnabled = YES;
    self.contentTableView.scrollEnabled = self.contentTableView.bounces = YES;
    self.contentTableView.directionalLockEnabled = YES;
    self.contentTableView.showsHorizontalScrollIndicator = self.contentTableView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.contentTableView];
    [self addSubview:selectionImageViewPre];
    [self addSubview:selectionImageViewNext];
    [self addSubview:imageLine01];
    [self addSubview:imageLine02];
    [self setCornerRadiusAndBorder:0 BorderWidth:0 BorderColor:nil];
    if (self.selecteIndex) {
        [self scrollToSelectedRowAtScrollPositionWidthIndex:self.selecteIndex];
        self.selecteIndex = 0;
    }
}

#pragma mark Table view methods


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = [self.dataSource numberOfRowsInSelector:self];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *contentSubviews = [cell.contentView subviews];
    //We the content view already has a subview we just replace it, no need to add it again
    //hopefully ARC will do the rest and release the old retained view
    if ([contentSubviews count] >0 ) {
        UIView *contentSubV = contentSubviews.firstObject;
        
        //This will release the previous contentSubV
        [contentSubV removeFromSuperview];
    }
    UIView *viewToAdd = (UILabel *)[self.dataSource selector:self viewForRowAtIndex:indexPath.row];
    [cell.contentView addSubview:viewToAdd];
    
    if (self.horizontalScrolling) {
        CGAffineTransform rotateTable = CGAffineTransformMakeRotation(M_PI_2);
        cell.transform = rotateTable;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @synchronized(synScroll){
        if(ifscrollflag) ifscrollflag = false;
    }
    [self scrollToSelectedRowAtScrollPositionWidthIndexX:[indexPath row]];
}

#pragma mark Scroll view methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    @synchronized(synScroll){
        if(ifscrollflag){
            [self scrollToTheSelectedCell];
        }
        ifscrollflag = false;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @synchronized(synScroll){
        ifscrollflag = true;
        if (!decelerate) {
            ifscrollflag = false;
            [self scrollToTheSelectedCell];
        }
    }
}

- (void)scrollToTheSelectedCell {
    
    CGRect selectionRectConverted = [self convertRect:selectionRect toView:self.contentTableView];
    NSArray *indexPathArray = [self.contentTableView indexPathsForRowsInRect:selectionRectConverted];
    
    CGFloat intersectionHeight = 0.0;
    NSIndexPath *selectedIndexPath = nil;
    
    for (NSIndexPath *index in indexPathArray) {
        //looping through the closest cells to get the closest one
        UITableViewCell *cell = [self.contentTableView cellForRowAtIndexPath:index];
        CGRect intersectedRect = CGRectIntersection(cell.frame, selectionRectConverted);
      
        if (intersectedRect.size.height>=intersectionHeight) {
            selectedIndexPath = index;
            intersectionHeight = intersectedRect.size.height;
        }
    }
    if (selectedIndexPath!=nil) {
        //As soon as we elected an indexpath we just have to scroll to it
        if (self.delegate) {
            [self.delegate selector:self didSelectRowAtIndex:[selectedIndexPath row]];
        }
        [self scrollToSelectedRowAtScrollPositionWidthIndex:[selectedIndexPath row]];
    }
}
-(void) scrollToSelectedRowAtScrollPositionWidthIndex:(NSInteger) index{
    if (!self.contentTableView) {
        self.selecteIndex = index;
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.contentTableView  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) scrollToSelectedRowAtScrollPositionWidthIndexX:(NSInteger) index{
    
    if (self.delegate) {
        [self.delegate selector:self didSelectRowAtIndex:index];
    }
    [self.contentTableView  scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



- (void)reloadData {
    
    [self.contentTableView  reloadData];
}




@end
