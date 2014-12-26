//
//  SimplePikerTable.m
//  Common
//
//  Created by wlpiaoyi on 14/12/3.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

float PIKER_MUTIPLE_VALUE = 0.3;
float PIKER_DELERATIONRATE = 0.5;
#import "SimplePikerTable.h"

#import "SimplePickerCell.h"

@interface SimplePikerTable(){
    CallBackUnSelectedCell callBackUnSelectedCell;
    CallBackSelectedCell callBackSelectedCell;
}

@property (nonatomic,strong) NSLock *lockscrollanimation;
@end

@implementation SimplePikerTable
-(id) init{
    if (self=[super init]) {
        self.showsHorizontalScrollIndicator =
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = PIKER_DELERATIONRATE;
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor clearColor];
        _lastRow = -1;
        UIEdgeInsets e = self.separatorInset;
        e.left = 0;
        self.separatorInset = e;
        _lockscrollanimation = [NSLock new];
    }
    return self;
}
-(void) setContentSize:(CGSize)contentSize{
    [super setContentSize:contentSize];
    [self setFlagOffy:_flagOffy];
}
-(void) setFlagOffy:(BOOL)flagOffy{
    _flagOffy = flagOffy;
    _scrolloffy = (self.frame.size.height-self.rowHeight)/2;
    if (_flagOffy) {
        self.contentInset = UIEdgeInsetsMake(_scrolloffy, 0, _scrolloffy, 0);
    }else{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

-(void) setContentOffset:(CGPoint)contentOffset{
    @synchronized(self.visibleCells){
        [super setContentOffset:contentOffset];
        for (SimplePickerCell *view in self.visibleCells) {
            CGRect r = view.frame;
            int offy = abs(r.origin.y-contentOffset.y-_scrolloffy);
            if (offy<=self.rowHeight) {
                CATransform3D transform;
                float sizep = (1-((float)offy)/((float)self.rowHeight))*PIKER_MUTIPLE_VALUE;
                transform = CATransform3DIdentity;
                transform = CATransform3DScale(transform, 1+sizep, 1+sizep, 1);
                view.subCell.layer.transform = transform;
            }else{
                CATransform3D transform;
                transform = CATransform3DIdentity;
                transform = CATransform3DScale(transform, 1, 1, 1);
                view.subCell.layer.transform = transform;
            }
        }
        if (_lastRow>=0&&callBackUnSelectedCell) {
            callBackUnSelectedCell([self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastRow inSection:0]],false);
            _lastRow = -1;
        }
    }
}


-(void) scrollViewDidEndDecelerating{
    CGPoint contentOffset = self.contentOffset;
    int d = ((int)(contentOffset.y+_scrolloffy))%((int)self.rowHeight);
    if(d>self.rowHeight/2){
        contentOffset.y += self.rowHeight-d;
    }else{
        contentOffset.y -= d;
    }
    [self setContentOffset:contentOffset animated:YES];
}
-(void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentOffset =contentOffset;
        } completion:^(BOOL finished) {
            [self setOptCallBackSelectedCells:contentOffset isauto:true];
        }];
    }else{
        self.contentOffset =contentOffset;
        [self setOptCallBackSelectedCells:contentOffset isauto:true];
    }
}
-(void) setOptCallBackSelectedCells:(CGPoint)contentOffset isauto:(BOOL) isauto{
    @synchronized(self.visibleCells){
        
        SimplePickerCell *currentSelectedView;
        if(((int)(contentOffset.y))==0||((int)(contentOffset.y)) == ((int)(self.contentSize.height-self.frame.size.height))){
            currentSelectedView = (SimplePickerCell*)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_curRow inSection:0]];
        }else{
            for (SimplePickerCell *view in self.visibleCells) {
                CGRect r = view.frame;
                int offy = abs(r.origin.y-contentOffset.y-_scrolloffy);
                offy = MIN(offy, self.rowHeight);
                if (offy==0) {
                    currentSelectedView = view;
                    break;
                }
            }
        }
        if (callBackSelectedCell&&currentSelectedView) {
            callBackSelectedCell(currentSelectedView,isauto);
        }
        if (_lastRow>=0&&callBackUnSelectedCell) {
            callBackUnSelectedCell([self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastRow inSection:0]],isauto);
            _lastRow = -1;
        }
        if(currentSelectedView)_lastRow = [self indexPathForCell:currentSelectedView].row;
    }
}

-(void) setCallBackUnSelectedCell:(CallBackUnSelectedCell) callback{
    callBackUnSelectedCell = callback;
}
-(void) setCallBackSelectedCell:(CallBackSelectedCell) callBack{
    callBackSelectedCell = callBack;
}
-(void) scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated{
    _curRow = [indexPath row];
    [super scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
