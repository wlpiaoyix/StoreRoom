//
//  PopUpDialogView.m
//  DXAlertView
//
//  Created by wlpiaoyi on 14-4-9.
//  Copyright (c) 2014年 xiekw. All rights reserved.
//

#import "PopUpDialogView.h"
#import <objc/runtime.h>


UIColor *PopUpButtonBgStateHighlighted;
UIColor *PopUpButtonBgStateNormal;
UIColor *PopUpButtonTxtStateHighlighted;
UIColor *PopUpButtonTxtStateNormal;


static float PopUpDialogView_buttonHight;
static float PopUpDialogView_buttonViewWidth;
@interface PopUpDialogView()
@property (nonatomic,assign) id<PopUpDialogViewDelegate> delegate;
@end
@implementation PopUpDialogView{
@private
    UIView *dialogView;
    UILabel *dialogTitleLabel;
    UILabel *dialogMessageLabel;
    UIView *dialogButtonView;
    int tagButton;
    int indexButton;
}
+(void)initialize{
    [super initialize];
    PopUpDialogView_buttonHight = 45;
    PopUpDialogView_buttonViewWidth = 260;
    
    if(!PopUpButtonBgStateHighlighted)PopUpButtonBgStateHighlighted = [UIColor colorWithRed:0.008 green:0.439 blue:0.773 alpha:1];
    if(!PopUpButtonBgStateNormal)PopUpButtonBgStateNormal = [UIColor whiteColor];
    if(!PopUpButtonTxtStateHighlighted)PopUpButtonTxtStateHighlighted = [UIColor whiteColor];
    if(!PopUpButtonTxtStateNormal)PopUpButtonTxtStateNormal = [UIColor colorWithRed:0.404 green:0.404 blue:0.404 alpha:1];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(PopUpDialogView*) initWithTitle:(NSString *)title message:(NSString *)message TargetView:(UIView*) targetView delegate:(id<PopUpDialogViewDelegate>)_delegate_ cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    NSMutableArray *_resources = [NSMutableArray new];
    if(otherButtonTitles){
        [_resources addObject:otherButtonTitles];
        va_list _list;
        va_start(_list, otherButtonTitles);
        NSString* resource;
        while ((resource = va_arg( _list, NSString *)))
        {
            [_resources addObject:resource];
        }
        va_end(_list);
    }
    [_resources addObject:cancelButtonTitle];
    
    PopUpDialogView *pudv = [PopUpDialogView new];
    [pudv initParamWithTargetView:targetView];
    pudv->tagButton = (arc4random() % 9999999)*2;
    
    [pudv setHasCloseButton:YES];
    pudv->dialogView = [pudv createDialogView];
    pudv->dialogTitleLabel = [pudv createDialogTitleLabelWithTitle:title];
    pudv->dialogMessageLabel = [pudv createDialogMessageLabelWithMessage:message];
    [pudv->dialogView addSubview:pudv->dialogTitleLabel];
    [pudv->dialogView addSubview:pudv->dialogMessageLabel];
    
    pudv->dialogButtonView = [pudv createDialogButtonView:_resources];
    CGRect r  = pudv->dialogButtonView.frame;
    r.origin.y = pudv->dialogMessageLabel.frame.origin.y+pudv->dialogMessageLabel.frame.size.height;
    r.origin.x = (PopUpDialogView_buttonViewWidth-r.size.width)/2;
    pudv->dialogButtonView.frame = r;
    r = CGRectMake(0, 0, PopUpDialogView_buttonViewWidth, r.size.height+r.origin.y);
    [pudv->dialogView addSubview:pudv->dialogButtonView];
    
    pudv->dialogView.frame = r;
    [pudv addSubview:pudv->dialogView];
    
    pudv.delegate = _delegate_;
    return pudv;
}
+(PopUpDialogView*) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<PopUpDialogViewDelegate>)_delegate_ cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    NSMutableArray *_resources = [NSMutableArray new];
    if(otherButtonTitles){
        [_resources addObject:otherButtonTitles];
        va_list _list;
        va_start(_list, otherButtonTitles);
        NSString* resource;
        while ((resource = va_arg( _list, NSString *)))
        {
            [_resources addObject:resource];
        }
        va_end(_list);
    }
    [_resources addObject:cancelButtonTitle];
    
    PopUpDialogView *pudv = [PopUpDialogView new];
    [pudv initParam];
    pudv->tagButton = (arc4random() % 9999999)*2;
    
    [pudv setHasCloseButton:NO];
    pudv->dialogView = [pudv createDialogView];
    pudv->dialogTitleLabel = [pudv createDialogTitleLabelWithTitle:title];
    pudv->dialogMessageLabel = [pudv createDialogMessageLabelWithMessage:message];
    [pudv->dialogView addSubview:pudv->dialogTitleLabel];
    [pudv->dialogView addSubview:pudv->dialogMessageLabel];
    
    pudv->dialogButtonView = [pudv createDialogButtonView:_resources];
    CGRect r  = pudv->dialogButtonView.frame;
    r.origin.y = pudv->dialogMessageLabel.frame.origin.y+pudv->dialogMessageLabel.frame.size.height;
    r.origin.x = (PopUpDialogView_buttonViewWidth-r.size.width)/2;
    pudv->dialogButtonView.frame = r;
    r = CGRectMake(0, 0, PopUpDialogView_buttonViewWidth, r.size.height+r.origin.y);
    [pudv->dialogView addSubview:pudv->dialogButtonView];
    
    pudv->dialogView.frame = r;
    [pudv addSubview:pudv->dialogView];
    
    pudv.delegate = _delegate_;
    return pudv;
}
-(UIView*) createDialogView{
    UIView *_dialogView = [UIView new];
    _dialogView.backgroundColor = [UIColor whiteColor];
    [_dialogView setCornerRadiusAndBorder:5 BorderWidth:0.5f BorderColor:[UIColor colorWithRed:0.482 green:0.482 blue:0.482 alpha:0.7f]];
    return _dialogView;
}
-(UILabel*) createDialogMessageLabelWithMessage:(NSString *)message{
    UILabel *_dialogMessageLabel = [UILabel new];
    _dialogMessageLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _dialogMessageLabel.textColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1];
    _dialogMessageLabel.numberOfLines = 0;
    _dialogMessageLabel.textAlignment = NSTextAlignmentCenter;
    CGSize _size = [Common getBoundingRectWithSize:message font:_dialogMessageLabel.font size:CGSizeMake(220, 1000)] ;
    _size.width =  220;
    _size.height += 30;
    _dialogMessageLabel.frame = CGRectMake((PopUpDialogView_buttonViewWidth-_size.width)/2, 30, _size.width, _size.height);
    _dialogMessageLabel.text = message;
    
    return _dialogMessageLabel;
}
-(UILabel*) createDialogTitleLabelWithTitle:(NSString *)title{
    UILabel *_dialogTitleLabel = [UILabel new];
    _dialogTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    _dialogTitleLabel.textColor = [UIColor colorWithRed:56.0/255.0 green:64.0/255.0 blue:71.0/255.0 alpha:1];
    _dialogTitleLabel.numberOfLines = 0;
    _dialogTitleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize _size= CGSizeMake(PopUpDialogView_buttonViewWidth, 30);//[message sizeWithFont:dialogTitleLabel.font constrainedToSize:CGSizeMake(220, 1000)];
    _dialogTitleLabel.frame = CGRectMake(0, 5, _size.width, _size.height);
    _dialogTitleLabel.text = title;
    return _dialogTitleLabel;
}
-(UIView*) createDialogButtonView:(NSMutableArray*) array{
    UIView *_dialogButtonView = [UIView new];
    CGSize size = CGSizeMake(PopUpDialogView_buttonViewWidth, PopUpDialogView_buttonHight);
    if ([array count]==2) {
        CGRect btnFrame = CGRectMake(0 , 0, size.width/2+1, PopUpDialogView_buttonHight);
        UIButton *btn = [self createOtherButton:array[0]];
        btn.frame = btnFrame;
        [_dialogButtonView addSubview:btn];
        btn = [self createCancelButton:array[1]];
        btnFrame.origin.x += size.width/2;
        btn.frame = btnFrame;
        [_dialogButtonView addSubview:btn];
    }else{
        CGRect btnFrame = CGRectMake(0 , 0, size.width, PopUpDialogView_buttonHight+1);
        UIButton *btn;
        NSString *cancel = [array lastObject];
        [array removeObject:cancel];
        for (NSString *buttonTitle in array) {
            btn = [self createOtherButton:buttonTitle];
            btn.frame = btnFrame;
            [_dialogButtonView addSubview:btn];
            btnFrame.origin.y += btnFrame.size.height-1;
        }
        btn = [self createCancelButton:cancel];
        btn.frame = btnFrame;
        [_dialogButtonView addSubview:btn];
        size.height+= btnFrame.origin.y;
    }
    CGRect r = _dialogButtonView.frame;
    r.size =  size;
    _dialogButtonView.frame = r;
    return _dialogButtonView;
}
-(UIButton*) createCancelButton:(NSString*) cancelTitle{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageWithColor:PopUpButtonBgStateNormal] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:PopUpButtonBgStateHighlighted] forState:UIControlStateHighlighted];
    
    [btn setTitleColor:PopUpButtonTxtStateNormal forState:UIControlStateNormal];
    [btn setTitleColor:PopUpButtonTxtStateHighlighted forState:UIControlStateHighlighted];
    
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setCornerRadiusAndBorder:0.0f BorderWidth:0.5f BorderColor:[UIColor colorWithRed:0.482 green:0.482 blue:0.482 alpha:0.7f]];
    btn.tag = self->tagButton+self->indexButton;
    self->indexButton++;
    return btn;
}
-(UIButton*) createOtherButton:(NSString*) otherTitle{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageWithColor:PopUpButtonBgStateNormal] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:PopUpButtonBgStateHighlighted] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:PopUpButtonTxtStateNormal forState:UIControlStateNormal];
    [btn setTitleColor:PopUpButtonTxtStateHighlighted forState:UIControlStateHighlighted];
    [btn setTitle:otherTitle forState:UIControlStateNormal];
    [btn setCornerRadiusAndBorder:0.0f BorderWidth:0.5f BorderColor:[UIColor colorWithRed:0.482 green:0.482 blue:0.482 alpha:0.7f]];
    btn.tag = self->tagButton+self->indexButton;
    self->indexButton++;
    [btn addTarget:self action:@selector(clickOtherButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void) clickOtherButton:(UIButton*) button{
    if(self.delegate){
        __weak typeof(self) tempself = self;
        [self.delegate alertView:tempself clickedButtonAtIndex:(button.tag-self->tagButton)];
    }
}
-(void) clickCancelButton:(UIButton*) button{
    [super close];
    if(self.delegate){
        __weak typeof(self) tempself = self;
        SEL sel = @selector(alertView:clickedButtonAtIndex:);//得到方法uuid
        Method origMethod = class_getInstanceMethod([self.delegate class], sel);//找到对应类中的方法
        if(origMethod){//如果有就执行
            [self.delegate alertView:tempself clickedButtonAtIndex:(button.tag-self->tagButton)];
        }
        sel = @selector(alertViewCancel:);
        origMethod = class_getInstanceMethod([self.delegate class], sel);
        if(origMethod){
            [self.delegate alertViewCancel:tempself];
        }
    }
}
@end
