//
//  PopUpDialogVendorView.m
//  ShiShang
//
//  Created by wlpiaoyi on 14/12/19.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "PopUpDialogVendorView.h"
#import "Common.h"
#import "UIView+AutoRect.h"
//对话框宽度
static float STATIC_DEFAULT_DIALOG_WIDTH;
//按钮高度
static float STATIC_DEFAULT_DIALOG_BUTTON_HEIGHT;
//按钮文字字体
static UIFont *STATIC_DEFAULT_BUTTON_NAME_FONT;
//边框景色
static UIColor *STATIC_DEFAULT_BORDER_COLOR;
//背景色
static UIColor *STATIC_DEFAULT_BACKGROUND_COLOR;
//按钮背景正常颜色
static UIColor *STATIC_DEFAULT_BUTTON_BGCOLOR_NORMAL;
//按钮背景高亮颜色
static UIColor *STATIC_DEFAULT_BUTTON_BGCOLOR_HIGHLIGHTED;
//按钮名称正常颜色
static UIColor *STATIC_DEFAULT_BUTTON_TITLECOLOR_NORMAL;
//按钮名称高亮颜色
static UIColor *STATIC_DEFAULT_BUTTON_TITLECOLOR_HIGHLIGHTED;

@interface PopUpDialogVendorView(){
    dispatch_block_dialog_vendor blockOnclick;
}
@property (nonatomic,strong) NSArray *buttons;
@property (nonatomic,strong) NSMutableArray *buttonNames;

@end

@implementation PopUpDialogVendorView

+(void) initialize{
    [super initialize];
    UIFont *tempfont = [UIFont systemFontOfSize:1];
    STATIC_DEFAULT_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    STATIC_DEFAULT_DIALOG_WIDTH = 260.0f;
    STATIC_DEFAULT_DIALOG_BUTTON_HEIGHT=50.0f;
    STATIC_DEFAULT_BUTTON_NAME_FONT = [UIFont systemFontOfSize:[Common getFontSize:tempfont.fontName height:STATIC_DEFAULT_DIALOG_BUTTON_HEIGHT/2]];
    STATIC_DEFAULT_BUTTON_BGCOLOR_NORMAL = [UIColor whiteColor];
    STATIC_DEFAULT_BUTTON_BGCOLOR_HIGHLIGHTED = [UIColor colorWithRed:0.271 green:0.463 blue:0.761 alpha:1];
    STATIC_DEFAULT_BUTTON_TITLECOLOR_NORMAL = STATIC_DEFAULT_BUTTON_BGCOLOR_HIGHLIGHTED;
    STATIC_DEFAULT_BUTTON_TITLECOLOR_HIGHLIGHTED = STATIC_DEFAULT_BUTTON_BGCOLOR_NORMAL;
    STATIC_DEFAULT_BORDER_COLOR = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
}

-(id) init{
    if (self=[super init]) {
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
-(id) initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initParam];
    }
    return self;
}
-(void) initParam{
    [super initParam];
    self.backgroundColor = STATIC_DEFAULT_BACKGROUND_COLOR;
    _buttonBgColorHighLight = STATIC_DEFAULT_BUTTON_BGCOLOR_HIGHLIGHTED;
    _buttonBgColorNormal = STATIC_DEFAULT_BUTTON_BGCOLOR_NORMAL;
    _buttonNameColorHighLight = STATIC_DEFAULT_BUTTON_TITLECOLOR_HIGHLIGHTED;
    _buttonNameColorNormal = STATIC_DEFAULT_BUTTON_TITLECOLOR_NORMAL;
    _buttonHeight = STATIC_DEFAULT_DIALOG_BUTTON_HEIGHT;
    _borderColor = STATIC_DEFAULT_BORDER_COLOR;
}


/**
 构建对话框
 */
+(PopUpDialogVendorView*) dialogWithView:(UIView*) view onclickBlock:(dispatch_block_dialog_vendor) onclickBlock buttonNames:(NSString*) buttonName,...{
    PopUpDialogVendorView *dialogView = [[PopUpDialogVendorView alloc] init];
    dialogView->_dialogContext = view;
    dialogView->blockOnclick = onclickBlock;
    dialogView.buttonNames = [NSMutableArray new];
    if(buttonName){
        [dialogView.buttonNames addObject:buttonName];
        va_list _list;
        va_start(_list, buttonName);
        NSString* resource;
        while ((resource = va_arg( _list, NSString *)))
        {
            [dialogView.buttonNames addObject:resource];
        }
        va_end(_list);
    }
    return dialogView;
}

-(void) setAllView{
    UIView *buttonViews = [self createButtonWithNames:_buttonNames];
    VendorMoveView *viewShow = [self createViewShow];
    
    CGRect r = viewShow.frame;
    r.size.height = buttonViews.frame.size.height+self.dialogContext.frame.size.height;
    r.size.width = self.dialogContext.frame.size.width;
    viewShow.frame = r;
    
    r = buttonViews.frame;
    r.origin.y = viewShow.frame.size.height-r.size.height;
    r.size.width = self.dialogContext.frame.size.width;
    buttonViews.frame = r;
    
    r = self.dialogContext.frame;
    r.origin.y = 0;
    r.origin.x = 0;
    self.dialogContext.frame = r;
    
    [viewShow addSubview:self.dialogContext];
    [viewShow addSubview:buttonViews];
    [self addSubview:viewShow];
}


-(VendorMoveView*) createViewShow{
    VendorMoveView *viewShow = [[VendorMoveView alloc] init];
    viewShow.frame = CGRectMake(0, 0, STATIC_DEFAULT_DIALOG_WIDTH, 0);
    viewShow.autoresizingMask = UIViewAutoresizingNone;
    [viewShow setCornerRadiusAndBorder:5 BorderWidth:0.5 BorderColor:_borderColor];
    return viewShow;
}

-(UIView*) createButtonWithNames:(NSArray*) names{
    if (!names||![names count]) {
        return nil;
    }
    NSMutableArray *buttons;
    NSMutableArray *lines;
    float offy = 0;
    if([names count]==2){
        float width = STATIC_DEFAULT_DIALOG_WIDTH/2;
        UIButton *buttonConfirm = [self createButton:[names objectAtIndex:0] width:width];
        UIButton *buttonCancel = [self createButton:[names objectAtIndex:1] width:width];
        [buttonConfirm setCornerRadiusAndBorder:0 BorderWidth:0.5f BorderColor:_borderColor];
        
        CGRect r = buttonConfirm.frame;
        r.origin.x = 0;
        r.origin.y = 0;
        buttonConfirm.frame = r;
        r.origin.x = STATIC_DEFAULT_DIALOG_WIDTH-r.size.width;
        buttonCancel.frame = r;
        
        UIView *viewLineHorizontal = [self createViewLineHorizontal:width*2];
        r = viewLineHorizontal.frame;
        r.origin.y = 0;
        viewLineHorizontal.frame = r;
        
        buttons = [NSMutableArray arrayWithObjects:buttonConfirm, buttonCancel, nil];
        lines = [NSMutableArray arrayWithObjects:viewLineHorizontal, nil];
        offy = _buttonHeight;
        
    }else{
        buttons = [NSMutableArray new];
        lines = [NSMutableArray new];
        float width = STATIC_DEFAULT_DIALOG_WIDTH;
        for (NSString *name in names) {
            UIButton *button = [self createButton:name width:width];
            CGRect r = button.frame;
            r.origin.y = offy;
            button.frame = r;
            
            UIView *viewLineHorizontal = [self createViewLineHorizontal:width];
            r = viewLineHorizontal.frame;
            r.origin.y = offy;
            viewLineHorizontal.frame = r;
            
            [buttons addObject:button];
            [lines addObject:viewLineHorizontal];
            
            offy+=button.frame.size.height;
        }
    }
    
    UIView *viewButtons = [UIView new];
    viewButtons.frame = CGRectMake(0, 0, STATIC_DEFAULT_DIALOG_WIDTH, offy);
    viewButtons.backgroundColor = [UIColor clearColor];
    [viewButtons autoresizingMask_TLRW];
    for (UIButton *button in buttons) {
        [viewButtons addSubview:button];
    }
    for (UIView *line in lines) {
        [viewButtons addSubview:line];
    }
    _buttons = buttons;
    return viewButtons;
}

-(UIButton*) createButton:(NSString*) name width:(float) width{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:_buttonNameColorNormal forState:UIControlStateNormal];
    [button setTitleColor:_buttonNameColorHighLight forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithColor:_buttonBgColorNormal] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:_buttonBgColorHighLight] forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, width, _buttonHeight);
    [button autoresizingMask_TLRW];
    [button setTitle:name forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onclickButton:)];
    return button;
}
-(UIView*) createViewLineHorizontal:(float) width{
    UIView *viewLineHorizontal = [UIView new];
    viewLineHorizontal.backgroundColor = _borderColor;
    viewLineHorizontal.frame = CGRectMake(0, 0, width, 0.5f);
    [viewLineHorizontal autoresizingMask_BLRW];
    return viewLineHorizontal;
}

-(void) onclickButton:(UIButton*) button{
    @try {
        if (blockOnclick) {
            __weak typeof(self) weakself = self;
            NSUInteger index = [_buttons indexOfObject:button];
            blockOnclick(weakself,index);
        }
    }
    @finally {
        [self close];
    }
    
}


-(void) show{
    [self setAllView];
    [super show];
}


@end
