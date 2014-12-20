//
//  SimplePickerCell.m
//  Common
//
//  Created by wlpiaoyi on 14/12/4.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "SimplePickerCell.h"
#import "UIView+AutoRect.h"

@interface SimplePickerCell(){
    CallBackPickerCellStatu callBackPickerCellStatu;
}
@property (nonatomic,strong) UIView *baseView;
@end

@implementation SimplePickerCell

-(id) init{
    if (self = [super init]) {
        [self initParam];
    }
    return self;
}
-(id) initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initParam];
    }
    return self;
}


-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self initParam];
    }
    return self;
}
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initParam];
    }
    return self;
}
-(void) initParam{
    
    _baseView = [UIView new];
    _baseView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_baseView];
    
    CGRect frame = self.contentView.frame;
    _edgeInsetsCellView.top = _edgeInsetsCellView.bottom = frame.size.height*0.1;
    _edgeInsetsCellView.left = _edgeInsetsCellView.right = frame.size.width*0.1;
    [self setEdgeInsetsCellView:_edgeInsetsCellView];
}

- (void)awakeFromNib {
    // Initialization code
}

-(void) setSelectedStatus:(BOOL) selected{
    if (_selectedStatus!=selected&&callBackPickerCellStatu) {
        callBackPickerCellStatu(self,selected);
    }
    [self setSelected:selected];
    _selectedStatus = selected;
}
-(void) setCallBackPickerCellStatu:(CallBackPickerCellStatu) callback{
    callBackPickerCellStatu = callback;
}

-(void) setEdgeInsetsCellView:(UIEdgeInsets)edgeInsetsCellView{
    _edgeInsetsCellView = edgeInsetsCellView;
    CGRect r = self.contentView.frame;
    r.origin = CGPointMake(0, 0);
    r.origin.x += edgeInsetsCellView.left;
    r.origin.y += edgeInsetsCellView.top;
    r.size.width -= r.origin.x+edgeInsetsCellView.right;
    r.size.height -= r.origin.y+edgeInsetsCellView.bottom;
    _baseView.frame = r;
    [_baseView autoresizingMask_TBLRWH];
}

-(void) setSubCell:(UIView *)subCell{
    @synchronized(self.baseView){
        for (UIView *view in self.baseView.subviews) {
            [view removeFromSuperview];
        }
        [self.baseView addSubview:subCell];
        _subCell = subCell;
    }
}

@end
