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
        UIEdgeInsets e = self.separatorInset;
        e.left = 0;
        self.separatorInset = e;
        _lockscrollanimation = [NSLock new];
    }
    return self;
}
-(void) setContentSize:(CGSize)contentSize{
    [super setContentSize:contentSize];
    _scrolloffy = (self.frame.size.height-self.rowHeight)/2;
    self.contentInset = UIEdgeInsetsMake(_scrolloffy, 0, _scrolloffy, 0);
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
            if (offy==0) {
                if (callBackSelectedCell) {
                    callBackSelectedCell(view,false);
                }
            }else{
                if (callBackUnSelectedCell) {
                    callBackUnSelectedCell(view,false);
                }
            }
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
            [self setContentOffset:contentOffset];
        } completion:^(BOOL finished) {
            @synchronized(self.visibleCells){
                for (UITableViewCell *view in self.visibleCells) {
                    CGRect r = view.frame;
                    int offy = abs(r.origin.y-contentOffset.y-_scrolloffy);
                    offy = MIN(offy, self.rowHeight);
                    if (offy==0) {
                        if (callBackSelectedCell) {
                            callBackSelectedCell(view,true);
                        }
                    }else{
                        if (callBackUnSelectedCell) {
                            callBackUnSelectedCell(view,true);
                        }
                    }
                }
            }
        }];
    }else{
        [self setContentOffset:contentOffset];
        @synchronized(self.visibleCells){
            for (UITableViewCell *view in self.visibleCells) {
                CGRect r = view.frame;
                int offy = abs(r.origin.y-contentOffset.y-_scrolloffy);
                offy = MIN(offy, self.rowHeight);
                if (offy==0) {
                    if (callBackSelectedCell) {
                        callBackSelectedCell(view,true);
                    }
                }else{
                    if (callBackUnSelectedCell) {
                        callBackUnSelectedCell(view,true);
                    }
                }
            }
        }
    }
}


-(void) setCallBackUnSelectedCell:(CallBackUnSelectedCell) callback{
    callBackUnSelectedCell = callback;
}
-(void) setCallBackSelectedCell:(CallBackSelectedCell) callBack{
    callBackSelectedCell = callBack;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
