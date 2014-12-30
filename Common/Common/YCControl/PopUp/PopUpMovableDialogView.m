//
//  PopUpDialogVendorView.m
//  ShiShang
//
//  Created by wlpiaoyi on 14/12/19.
//  Copyright (c) 2014年 wlpiaoyi. All rights reserved.
//

#import "PopUpMovableDialogView.h"
#import "Common.h"
//对话框宽度
static float STATIC_DIALOG_WIDTH;
//按钮高度
static float STATIC_DIALOG_BUTTON_HEIGHT;
//按钮文字字体
static UIFont *STATIC_DIALOG_BUTTON_NAME_FONT;
//边框景色
static UIColor *STATIC_DIALOG_BORDER_COLOR;
//背景色
static UIColor *STATIC_DIALOG_BACKGROUND_COLOR;
//按钮背景正常颜色
static UIColor *STATIC_DIALOG_BUTTON_BGCOLOR_NORMAL;
//按钮背景高亮颜色
static UIColor *STATIC_DIALOG_BUTTON_BGCOLOR_HIGHLIGHTED;
//按钮名称正常颜色
static UIColor *STATIC_DIALOG_BUTTON_TITLECOLOR_NORMAL;
//按钮名称高亮颜色
static UIColor *STATIC_DIALOG_BUTTON_TITLECOLOR_HIGHLIGHTED;

static UIColor *STATIC_ALERT_TITLE_COLOR;
static UIColor *STATIC_ALERT_MESSAGE_COLOR;
static UIFont *STATIC_ALERT_TITLE_FONT;
static UIFont *STATIC_ALERT_MESSAGE_FONT;
static float STATIC_ALERT_TITLE_OFFY;
static float STATIC_ALERT_MESSAGE_OFFY;

@interface PopUpDialogVendorView(){
    dispatch_block_dialog_vendor blockOnclick;
}
@property (nonatomic,strong) NSArray *buttons;
@property (nonatomic,strong) NSArray *buttonNames;

@end

@implementation PopUpDialogVendorView

+(void) initialize{
    [super initialize];
    UIFont *tempfont = [UIFont systemFontOfSize:1];
    STATIC_DIALOG_BACKGROUND_COLOR = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    STATIC_DIALOG_BUTTON_HEIGHT=50.0f;
    
    STATIC_DIALOG_BUTTON_NAME_FONT = [UIFont systemFontOfSize:[Utils getFontSizeWithHeight:STATIC_DIALOG_BUTTON_HEIGHT*0.6 fontName:tempfont.fontName]];
    STATIC_DIALOG_BUTTON_BGCOLOR_NORMAL = [UIColor whiteColor];
    STATIC_DIALOG_BUTTON_BGCOLOR_HIGHLIGHTED = [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1];
    STATIC_DIALOG_BUTTON_TITLECOLOR_NORMAL = STATIC_DIALOG_BUTTON_BGCOLOR_HIGHLIGHTED;
    STATIC_DIALOG_BUTTON_TITLECOLOR_HIGHLIGHTED = STATIC_DIALOG_BUTTON_BGCOLOR_NORMAL;
    STATIC_DIALOG_BORDER_COLOR = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    
    STATIC_ALERT_MESSAGE_COLOR = [UIColor colorWithRed:0.349 green:0.333 blue:0.357 alpha:1];
    STATIC_ALERT_TITLE_COLOR = STATIC_ALERT_MESSAGE_COLOR;
    STATIC_ALERT_TITLE_FONT = STATIC_DIALOG_BUTTON_NAME_FONT;
    STATIC_ALERT_MESSAGE_FONT = [UIFont systemFontOfSize:STATIC_DIALOG_BUTTON_NAME_FONT.pointSize*0.8];
    STATIC_ALERT_MESSAGE_OFFY = 10;
    STATIC_ALERT_TITLE_OFFY = 20;
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
    self.backgroundColor = STATIC_DIALOG_BACKGROUND_COLOR;
    _buttonBgColorHighLight = STATIC_DIALOG_BUTTON_BGCOLOR_HIGHLIGHTED;
    _buttonBgColorNormal = STATIC_DIALOG_BUTTON_BGCOLOR_NORMAL;
    _buttonNameColorHighLight = STATIC_DIALOG_BUTTON_TITLECOLOR_HIGHLIGHTED;
    _buttonNameColorNormal = STATIC_DIALOG_BUTTON_TITLECOLOR_NORMAL;
    _buttonHeight = STATIC_DIALOG_BUTTON_HEIGHT;
    _borderColor = STATIC_DIALOG_BORDER_COLOR;
    _buttonNameFont = STATIC_DIALOG_BUTTON_NAME_FONT;
}


/**
 构建提醒框
 */
+(PopUpDialogVendorView*) alertWithMessage:(NSString*) message title:(NSString*) title onclickBlock:(dispatch_block_dialog_vendor) onclickBlock buttonNames:(NSString*) buttonName,...{
    PopUpAlert *alert = [PopUpAlert new];
    [alert setTitle:title message:message];
    PopUpDialogVendorView *dialogView = [[PopUpDialogVendorView alloc] init];
    NSMutableArray *buttonNames = [NSMutableArray new];
    if(buttonName){
        [buttonNames addObject:buttonName];
        va_list _list;
        va_start(_list, buttonName);
        NSString* resource;
        while ((resource = va_arg( _list, NSString *)))
        {
            [buttonNames addObject:resource];
        }
        va_end(_list);
    }
    [dialogView setDialogContext:alert blockOnclick:onclickBlock buttonNames:buttonNames];
    return dialogView;
}



/**
 构建对话框
 */
+(PopUpDialogVendorView*) dialogWithView:(UIView*) view onclickBlock:(dispatch_block_dialog_vendor) onclickBlock buttonNames:(NSString*) buttonName,...{
    PopUpDialogVendorView *dialogView = [[PopUpDialogVendorView alloc] init];
    NSMutableArray *buttonNames = [NSMutableArray new];
    if(buttonName){
        [buttonNames addObject:buttonName];
        va_list _list;
        va_start(_list, buttonName);
        NSString* resource;
        while ((resource = va_arg( _list, NSString *)))
        {
            [buttonNames addObject:resource];
        }
        va_end(_list);
    }
    [dialogView setDialogContext:view blockOnclick:onclickBlock buttonNames:buttonNames];
    return dialogView;
}
-(void) setDialogContext:(UIView*) dialogContext blockOnclick:(dispatch_block_dialog_vendor) _blockOnclick buttonNames:(NSArray*) buttonNames{
    _dialogContext = dialogContext;
    blockOnclick = _blockOnclick;
    _buttonNames = buttonNames;
    
}


-(void) setAllView{
    UIView *buttonViews = [self createButtonWithNames:_buttonNames viewWidth:self.dialogContext.frame.size.width];
    MovableView *viewShow = [self createViewShow];
    
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


-(MovableView*) createViewShow{
    MovableView *viewShow = [[MovableView alloc] init];
    viewShow.frame = CGRectMake(0, 0, self.dialogContext.frame.size.width, 0);
    viewShow.autoresizingMask = UIViewAutoresizingNone;
    [viewShow setCornerRadiusAndBorder:5 BorderWidth:0.5 BorderColor:_borderColor];
    return viewShow;
}

-(UIView*) createButtonWithNames:(NSArray*) names viewWidth:(float) viewWidth{
    if (!names||![names count]) {
        return nil;
    }
    NSMutableArray *buttons;
    NSMutableArray *lines;
    float offy = 0;
    if([names count]==2){
        float width = viewWidth/2;
        UIButton *buttonConfirm = [self createButton:[names objectAtIndex:0] width:width];
        UIButton *buttonCancel = [self createButton:[names objectAtIndex:1] width:width];
        [buttonConfirm setCornerRadiusAndBorder:0 BorderWidth:0.5f BorderColor:_borderColor];
        
        CGRect r = buttonConfirm.frame;
        r.origin.x = 0;
        r.origin.y = 0;
        buttonConfirm.frame = r;
        r.origin.x = viewWidth-r.size.width;
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
        float width = viewWidth;
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
    viewButtons.frame = CGRectMake(0, 0, viewWidth, offy);
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
    button.titleLabel.font = _buttonNameFont;
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
        [self close];
        if (blockOnclick) {
            __weak typeof(self) weakself = self;
            NSUInteger index = [_buttons indexOfObject:button];
            blockOnclick(weakself,index);
        }
    }
    @finally {
    }
    
}


-(void) show{
    [self setAllView];
    if ([self.dialogContext isKindOfClass:[PopUpAlert class]]) {
        self.dialogContext.backgroundColor = _buttonBgColorNormal;
    }
    [super show];
}


@end

@interface PopUpAlert()
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UILabel *messageLable;

@end
@implementation PopUpAlert

+(void) initialize{
    [super initialize];
    STATIC_DIALOG_WIDTH = 260;
    STATIC_ALERT_TITLE_COLOR = STATIC_ALERT_MESSAGE_COLOR;
    STATIC_ALERT_TITLE_FONT = STATIC_DIALOG_BUTTON_NAME_FONT;
    STATIC_ALERT_MESSAGE_FONT = [UIFont systemFontOfSize:STATIC_DIALOG_BUTTON_NAME_FONT.pointSize*0.8];
    STATIC_ALERT_MESSAGE_OFFY = 10;
    STATIC_ALERT_TITLE_OFFY = 20;
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
    self.backgroundColor = STATIC_DIALOG_BACKGROUND_COLOR;
    _titleColor = STATIC_ALERT_TITLE_COLOR;
    _messageColor = STATIC_ALERT_MESSAGE_COLOR;
    _titleFont = STATIC_ALERT_TITLE_FONT;
    _messageFont = STATIC_ALERT_MESSAGE_FONT;
    _titleOffy = STATIC_ALERT_TITLE_OFFY;
    _messageOffy = STATIC_ALERT_MESSAGE_OFFY;
    self.frame = CGRectMake(0, 0, STATIC_DIALOG_WIDTH, 0);
    
    CGRect r = CGRectMake(0, 0, STATIC_DIALOG_WIDTH, 0);
    _titleLable = [UILabel new];
    [_titleLable setParamTextColor:_titleColor textAlignment:NSTextAlignmentCenter numberOfLines:0 font:_titleFont];
    _titleLable.frame = r;
    _messageLable = [UILabel new];
    [_messageLable setParamTextColor:_messageColor textAlignment:NSTextAlignmentCenter numberOfLines:0 font:_messageFont];
    _messageLable.frame = r;
    self.frame = r;
    [self addSubview:_titleLable];
    [self addSubview:_messageLable];
}

-(void) setTitle:(NSString*) title message:(NSString*) message{
    [_titleLable setParamTextColor:_titleColor textAlignment:NSTextAlignmentCenter numberOfLines:0 font:_titleFont];
    [_messageLable setParamTextColor:_messageColor textAlignment:NSTextAlignmentCenter numberOfLines:0 font:_messageFont];
    _titleLable.text = title;
    _messageLable.text = message;
    
    _titleLable.frameHeight = 9999;
    _titleLable.frameWidth = self.frameWidth - 20;
    [_titleLable automorphismHeight];
    _titleLable.frameX = (self.frameWidth-_titleLable.frameWidth)/2;
    
    _messageLable.frameHeight = 9999;
    _messageLable.frameWidth = self.frameWidth - 20;
    [_messageLable automorphismHeight];
    _messageLable.frameX = (self.frameWidth-_messageLable.frameWidth)/2;
    _titleLable.frameY = _titleOffy;
    _messageLable.frameY = _titleLable.frameHeight+_titleLable.frameY+_messageOffy;
    self.frameHeight = _messageLable.frameHeight+_messageLable.frameY+_messageOffy;
}



@end
