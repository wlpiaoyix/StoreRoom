//
//  VRGCalendarView.m
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//

#import "VRGCalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+convenience.h"
#import "NSMutableArray+convenience.h"
#import "UIView+convenience.h"
#define COLOR_HEAD_BG [UIColor colorWithRed:0.933 green:0.965 blue:0.910 alpha:1]
#define COLOR_MAIN_BG [UIColor colorWithRed:0.960 green:0.969 blue:0.950 alpha:1]
#define COLOR_SELECTED_BG [UIColor colorWithRed:0.678 green:0.863 blue:0.455 alpha:1]
#define COLOR_SELECTED_DATE [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]
#define COLOR_SELECTED_TAG [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]
#define COLOR_TAG [UIColor colorWithRed:0.525 green:0.714 blue:0.082 alpha:1]
#define COLOR_WEEKDAYS [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1]
#define COLOR_WORKDAYS [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1]
#define COLOR_WEEKENDDAYS [UIColor colorWithRed:0.66 green:0.36 blue:0.36 alpha:1.0f]
#define COLOR_DDATEDAYS [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1]
#define COLOR_MARKED01 [UIColor colorWithRed:0.525 green:0.714 blue:0.082 alpha:1]
#define COLOR_MARKED02 [UIColor colorWithRed:0.678 green:0.863 blue:0.455 alpha:1]
@interface VRGCalendarView(){
@private
    UILabel *labelCurrentMonth;
    
    BOOL isAnimating;
    BOOL prepAnimationPreviousMonth;
    BOOL prepAnimationNextMonth;
    UIImageView *animationView_A;
    UIImageView *animationView_B;
    //==>touch params
    double touchTime;
    id synTouch;
    UIView *touchTagView;
    CGSize touchTagSize;
    //<==
}
@property (nonatomic, getter = calendarHeight) float calendarHeight;
@property (nonatomic, strong) NSArray *markedDates;
@property (nonatomic, strong) NSArray *markedColors;
@end
@implementation VRGCalendarView
@synthesize currentMonth,delegate,selectedDate;

#pragma mark - Select Date
/**
 设定指定日期对背景
 */
-(void)selectDate:(int)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
    [comps setDay:date];
    self.selectedDate = [gregorian dateFromComponents:comps];
    
    int selectedDateYear = [selectedDate year];
    int selectedDateMonth = [selectedDate month];
    int currentMonthYear = [currentMonth year];
    int currentMonthMonth = [currentMonth month];
    
    if (selectedDateYear < currentMonthYear) {
        [self showPreviousMonth];
    } else if (selectedDateYear > currentMonthYear) {
        [self showNextMonth];
    } else if (selectedDateMonth < currentMonthMonth) {
        [self showPreviousMonth];
    } else if (selectedDateMonth > currentMonthMonth) {
        [self showNextMonth];
    } else {
        [self setNeedsDisplay];
    }
    
    if ([delegate respondsToSelector:@selector(calendarView:dateSelected:)]) [delegate calendarView:self dateSelected:self.selectedDate];
}

#pragma mark - Mark Dates
//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates {
    self.markedDates = [NSArray arrayWithArray:dates];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    for (int i = 0; i<[dates count]; i++) {
        [colors addObject:[UIColor grayColor]];
    }
    self.markedColors = [NSArray arrayWithArray:colors];
    [self setNeedsDisplay];
}

//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors {
    self.markedDates = [NSArray arrayWithArray:dates];
    self.markedColors = [NSArray arrayWithArray:colors];
    
    [self setNeedsDisplay];
}

#pragma mark - Set date to now
-(void)reset {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: self.selectedDate?self.selectedDate:[NSDate date]];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    
    [self updateSize];
    [self setNeedsDisplay];
    [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
}

-(void)reDisplay{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: self.currentMonth?self.currentMonth:[NSDate date]];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    
    [self updateSize];
    [self setNeedsDisplay];
    [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
}
#pragma mark - Next & Previous
-(void)showNextMonth {
    if (isAnimating) return;
    self.markedDates=nil;
    isAnimating=YES;
    prepAnimationNextMonth=YES;
    
    [self setNeedsDisplay];
    
    int lastBlock = [currentMonth firstWeekDayInMonth]+[currentMonth numDaysInMonth]-1;
    int numBlocks = [self numRows]*7;
    BOOL hasNextMonthDays = lastBlock<numBlocks;
    
    //Old month
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //New month
    self.currentMonth = [currentMonth offsetMonth:1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight: animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationNextMonth=NO;
    [self setNeedsDisplay];
    
    UIImage *imageNextMonth = [self drawCurrentState];
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
//    [animationHolder release];
    
    //Animate
    self->animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self->animationView_B = [[UIImageView alloc] initWithImage:imageNextMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasNextMonthDays) {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight - (kVRGCalendarViewDayHeight+3);
    } else {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight -3;
    }
    
    //Animation
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         //blockSafeSelf.frameHeight = 100;
                         if (hasNextMonthDays) {
                             animationView_A.frameY = -animationView_A.frameHeight + kVRGCalendarViewDayHeight+3;
                         } else {
                             animationView_A.frameY = -animationView_A.frameHeight + 3;
                         }
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf->animationView_A=nil;
                         blockSafeSelf->animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}

-(void)showPreviousMonth {
    if (isAnimating) return;
    isAnimating=YES;
    self.markedDates=nil;
    //Prepare current screen
    prepAnimationPreviousMonth = YES;
    [self setNeedsDisplay];
    BOOL hasPreviousDays = [currentMonth firstWeekDayInMonth]>1;
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //Prepare next screen
    self.currentMonth = [currentMonth offsetMonth:-1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationPreviousMonth=NO;
    [self setNeedsDisplay];
    UIImage *imagePreviousMonth = [self drawCurrentState];
    
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
//    [animationHolder release];
    
    self->animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self->animationView_B = [[UIImageView alloc] initWithImage:imagePreviousMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasPreviousDays) {
        animationView_B.frameY = animationView_A.frameY - (animationView_B.frameHeight-kVRGCalendarViewDayHeight) + 3;
    } else {
        animationView_B.frameY = animationView_A.frameY - animationView_B.frameHeight + 3;
    }
    
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         
                         if (hasPreviousDays) {
                             animationView_A.frameY = animationView_B.frameHeight-(kVRGCalendarViewDayHeight+3); 
                             
                         } else {
                             animationView_A.frameY = animationView_B.frameHeight-3;
                         }
                         
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf->animationView_A=nil;
                         blockSafeSelf->animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}


#pragma mark - update size & row count
-(void)updateSize {
    self.frameHeight = self.calendarHeight;
    [self setNeedsDisplay];
}

-(float)calendarHeight {
    return kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
}

-(int)numRows {
    float lastBlock = [self.currentMonth numDaysInMonth]+([self.currentMonth firstWeekDayInMonth]-1);
    return ceilf(lastBlock/7);
}
#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    @synchronized(self->synTouch){
        self->touchTime = [NSDate timeIntervalSinceReferenceDate];
        if (!self->touchTagView) {
            self->touchTagView = [UIView new];
            self->touchTagSize = CGSizeMake(44, 44);
            self->touchTagView.frame = CGRectMake(0, 0, self->touchTagSize.width,self->touchTagSize.height);
            self->touchTagView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6];
            [self->touchTagView setCornerRadiusAndBorder:self->touchTagView.frame.size.width/2 BorderWidth:0 BorderColor:nil];
        }
        
        CGRect r = self->touchTagView.frame;
        UITouch *touch = [touches anyObject];
        r.origin = [touch locationInView:self];
        r.origin.x -= r.size.width/2;
        r.origin.y -= r.size.height/2;
        self->touchTagView.frame = r;
        self->touchTagView.alpha = 0.0f;
        [self addSubview:self->touchTagView];
        [UIView animateWithDuration:0.15 animations:^{
            self->touchTagView.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    }
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    @synchronized(self->synTouch){
        CGRect r = self->touchTagView.frame;
        UITouch *touch = [touches anyObject];
        r.origin = [touch locationInView:self];
        r.origin.x -= r.size.width/2;
        r.origin.y -= r.size.height/2;
        self->touchTagView.frame = r;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    @synchronized(self->synTouch){
        self->touchTime = [NSDate timeIntervalSinceReferenceDate]-self->touchTime;
        
        [UIView animateWithDuration:0.2 animations:^{
            self->touchTagView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self->touchTagView removeFromSuperview];
            self->touchTagView.alpha = 1.0f;
        }];
        if(self->touchTime<0.5){
            [self clickView:touches];
        }
    }
}
-(void) clickView:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    self.selectedDate=nil;
    
    //Touch a specific day
    if (touchPoint.y > kVRGCalendarViewTopBarHeight) {
        float xLocation = touchPoint.x;
        float yLocation = touchPoint.y-kVRGCalendarViewTopBarHeight;
        
        int column = floorf(xLocation/(kVRGCalendarViewDayWidth+2));
        int row = floorf(yLocation/(kVRGCalendarViewDayHeight+2));
        
        int blockNr = (column+1)+row*7;
        int firstWeekDay = [self.currentMonth firstWeekDayInMonth]-1; //-1 because weekdays begin at 1, not 0
        int date = blockNr-firstWeekDay;
        
        if(!self.ifJumpShowMoth){
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
            [comps setDay:date];
            NSDate *d = [gregorian dateFromComponents:comps];
            if(d.month != self.currentMonth.month||d.year!=self.currentMonth.year){
                return;
            }
        }
        [self selectDate:date];
        return;
    }
    
    self.markedDates=nil;
    self.markedColors=nil;
    
    CGRect rectArrowLeft = CGRectMake(0, 0, 50, 40);
    CGRect rectArrowRight = CGRectMake(self.frame.size.width-50, 0, 50, 40);
    
    //Touch either arrows or month in middle
    if (CGRectContainsPoint(rectArrowLeft, touchPoint)) {
        [self showPreviousMonth];
    } else if (CGRectContainsPoint(rectArrowRight, touchPoint)) {
        [self showNextMonth];
    } else if (CGRectContainsPoint(self->labelCurrentMonth.frame, touchPoint)) {
        //Detect touch in current month
        int currentMonthIndex = [self.currentMonth month];
        int todayMonth = [[NSDate date] month];
        [self reset];
        if ((todayMonth!=currentMonthIndex) && [delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
    }
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    int firstWeekDay = [self.currentMonth firstWeekDayInMonth]-1; //-1 because weekdays begin at 1, not 0
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月"];
    labelCurrentMonth.text = [formatter stringFromDate:self.currentMonth];
    [labelCurrentMonth sizeToFit];
    labelCurrentMonth.frameX = roundf(self.frame.size.width/2 - labelCurrentMonth.frameWidth/2);
    labelCurrentMonth.frameY = 10;
//    [formatter release];
    [currentMonth firstWeekDayInMonth];
    
    CGContextClearRect(UIGraphicsGetCurrentContext(),rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rectangle = CGRectMake(0,0,self.frame.size.width,kVRGCalendarViewTopBarHeight);
    CGContextAddRect(context, rectangle);
    CGContextSetFillColorWithColor(context, COLOR_HEAD_BG.CGColor);
    CGContextFillPath(context);
    
    //Arrows
    int arrowSize = 14;
    int xmargin = 20;
    int ymargin = 15;
    
    //Arrow Left
    CGPoint p1 = CGPointMake(xmargin+arrowSize/1.5, ymargin);
    CGPoint p2 = CGPointMake(xmargin,ymargin+arrowSize/2);
    CGPoint p3 = CGPointMake(xmargin+arrowSize/1.5, ymargin+arrowSize);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x-1,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x-2,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    CGContextSetFillColorWithColor(context, 
                                   [UIColor darkGrayColor].CGColor);
    CGContextStrokePath(context);
   // CGContextFillPath(context);
    
    //Arrow right
    CGContextBeginPath(context);
    p1 = CGPointMake(self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    p2 = CGPointMake(self.frame.size.width-xmargin,ymargin+arrowSize/2);
    p3 = CGPointMake(self.frame.size.width-(xmargin+arrowSize/1.5),ymargin+arrowSize);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x+1,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    CGContextMoveToPoint(context, p1.x,p1.y);
    CGContextAddLineToPoint(context, p2.x+2,p2.y);
    CGContextAddLineToPoint(context, p3.x,p3.y);
    //CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    
    CGContextSetFillColorWithColor(context, 
                                   [UIColor darkGrayColor].CGColor);
    //CGContextFillPath(context);
    CGContextStrokePath(context);
    //Weekdays
   // NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   // dateFormatter.dateFormat=@"EEE";
    //always assume gregorian with monday first
    NSMutableArray *weekdays = [[NSMutableArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    [weekdays moveObjectFromIndex:0 toIndex:6];
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0x383838"].CGColor);
    for (int i =0; i<[weekdays count]; i++) {
        NSString *weekdayValue = (NSString *)[weekdays objectAtIndex:i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:13];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        [ps setAlignment:NSTextAlignmentCenter];
        [ps setLineBreakMode:NSLineBreakByClipping];
        [weekdayValue drawInRect:CGRectMake(i*(kVRGCalendarViewDayWidth+2), kVRGCalendarViewTopBarHeight-20, kVRGCalendarViewDayWidth+2, 20)  withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:ps,NSForegroundColorAttributeName:COLOR_WEEKDAYS}];
#else
        [weekdayValue drawInRect:CGRectMake(i*(kVRGCalendarViewDayWidth+2), kVRGCalendarViewTopBarHeight-20, kVRGCalendarViewDayWidth+2, 20) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
#endif
    }
    
    int numRows = [self numRows];
    
    CGContextSetAllowsAntialiasing(context, NO);
    
    //Grid background
    float gridHeight = numRows*(kVRGCalendarViewDayHeight+2)+1;
    CGRect rectangleGrid = CGRectMake(0,kVRGCalendarViewTopBarHeight,self.frame.size.width,gridHeight);
    CGContextAddRect(context, rectangleGrid);
    CGContextSetFillColorWithColor(context,COLOR_MAIN_BG.CGColor);
    CGContextFillPath(context);
 
    
    //Grid dark lines
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight);
    CGContextMoveToPoint(context, 0, gridHeight+kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, gridHeight+kVRGCalendarViewTopBarHeight);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetAllowsAntialiasing(context, YES);
    
    int numBlocks = numRows*7;
    NSDate *previousMonth = [self.currentMonth offsetMonth:-1];
    int currentMonthNumDays = [currentMonth numDaysInMonth];
    int prevMonthNumDays = [previousMonth numDaysInMonth];
    
    int selectedDateBlock = ([selectedDate day]-1)+firstWeekDay;
    
    //prepAnimationPreviousMonth nog wat mee doen
    
    //prev next month
    BOOL isSelectedDatePreviousMonth = prepAnimationPreviousMonth;
    BOOL isSelectedDateNextMonth = prepAnimationNextMonth;
    
    
    if (self.selectedDate!=nil) {
        isSelectedDatePreviousMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]<[currentMonth month]) || [selectedDate year] < [currentMonth year];
        
        if (!isSelectedDatePreviousMonth) {
            isSelectedDateNextMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]>[currentMonth month]) || [selectedDate year] > [currentMonth year];
        }
    }
    
    if (isSelectedDatePreviousMonth) {
        int lastPositionPreviousMonth = firstWeekDay-1;
        selectedDateBlock=lastPositionPreviousMonth-([selectedDate numDaysInMonth]-[selectedDate day]);
    } else if (isSelectedDateNextMonth) {
        selectedDateBlock = [currentMonth numDaysInMonth] + (firstWeekDay-1) + [selectedDate day];
    }
    
    NSDate *todayDate = [NSDate date];
    int todayBlock = -1;
    
    if ([todayDate month] == [currentMonth month] && [todayDate year] == [currentMonth year]) {
        todayBlock = [todayDate day] + firstWeekDay - 1;
    }
    
    //Draw markings
    if (!(!self.markedDates || isSelectedDatePreviousMonth || isSelectedDateNextMonth)){
        
        for (int i = 0; i<[self.markedDates count]; i++) {
            id markedDateObj = [self.markedDates objectAtIndex:i];
            
            int targetDate;
            if ([markedDateObj isKindOfClass:[NSNumber class]]) {
                targetDate = [(NSNumber *)markedDateObj intValue];
            } else if ([markedDateObj isKindOfClass:[NSDate class]]) {
                NSDate *date = (NSDate *)markedDateObj;
                targetDate = [date day];
            } else {
                continue;
            }
            
            int targetBlock = firstWeekDay + (targetDate-1);
            int targetColumn = targetBlock%7;
            int targetRow = targetBlock/7;
            
            int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) ;
            int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2);
            
            
            CGRect rectangleGrid = CGRectMake(targetX+4,targetY+4,kVRGCalendarViewDayWidth-9,kVRGCalendarViewDayHeight-9);
            CGContextSetFillColorWithColor(context, COLOR_MARKED02.CGColor);
            CGContextAddEllipseInRect(context, rectangleGrid);
            CGContextFillPath(context);
//            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context,COLOR_MARKED01.CGColor);
            CGContextAddEllipseInRect(context, rectangleGrid);
            CGContextStrokePath(context);
            
//            CGRect rectangle = CGRectMake(targetX,targetY+kVRGCalendarViewDayHeight,kVRGCalendarViewDayWidth,0.5f);
//            CGContextAddRect(context, rectangle);
//            CGContextSetFillColorWithColor(context, ((UIColor *)[self.markedColors objectAtIndex:i]).CGColor);
            CGContextFillPath(context);
        }
    }
    
    //Draw days
    CGContextSetFillColorWithColor(context, 
                                   [UIColor colorWithHexString:@"0x383838"].CGColor);
    
    for (int i=0; i<numBlocks; i++) {
        int targetDate = i;
        int targetColumn = i%7;
        int targetRow = i/7;
        int targetX = targetColumn * (kVRGCalendarViewDayWidth+2);
        int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2);
        
        if(targetColumn==0&&(i+7)<numBlocks){
            CGRect rectangle = CGRectMake(targetX,targetY+kVRGCalendarViewDayHeight,self.frame.size.width,0.5f);
            CGContextAddRect(context, rectangle);
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0.6f].CGColor);
            CGContextFillPath(context);
        }
        
        // BOOL isCurrentMonth = NO;
        if (i<firstWeekDay) { //previous month
            targetDate = (prevMonthNumDays-firstWeekDay)+(i+1);
            NSString *hex = (isSelectedDatePreviousMonth) ? @"0x383838" : @"aaaaaa";
            
            CGContextSetFillColorWithColor(context, 
                                           [UIColor colorWithHexString:hex].CGColor);
        } else if (i>=(firstWeekDay+currentMonthNumDays)) { //next month
            targetDate = (i+1) - (firstWeekDay+currentMonthNumDays);
            NSString *hex = (isSelectedDateNextMonth) ? @"0x383838" : @"aaaaaa";
            CGContextSetFillColorWithColor(context, 
                                           [UIColor colorWithHexString:hex].CGColor);
        } else {
            //current month
            // isCurrentMonth = YES;
            targetDate = (i-firstWeekDay)+1;
            NSString *hex = (isSelectedDatePreviousMonth || isSelectedDateNextMonth) ? @"0xaaaaaa" : @"0x383838";
            CGContextSetFillColorWithColor(context, 
                                           [UIColor colorWithHexString:hex].CGColor);
        }
        
        NSString *date = [NSString stringWithFormat:@"%i",targetDate];
        
        //draw selected date
        if (selectedDate && i==selectedDateBlock) {
            CGRect rectangleGrid = CGRectMake(targetX+3,targetY+3,kVRGCalendarViewDayWidth-7,kVRGCalendarViewDayHeight-7);
            CGContextSetFillColorWithColor(context, COLOR_SELECTED_BG.CGColor);
            CGContextAddEllipseInRect(context, rectangleGrid);
            CGContextFillPath(context);
            //如果是当天画一个小百点
            if (todayBlock==i) {
                CGRect rectangleGrid = CGRectMake(targetX+18,targetY+33,8,2);
                CGContextSetFillColorWithColor(context, COLOR_SELECTED_TAG.CGColor);
                CGContextAddRect(context, rectangleGrid);
                CGContextFillPath(context);
            }
        } else if (todayBlock==i) {
            CGRect rectangleGrid = CGRectMake(targetX+18,targetY+33,8,2);
            CGContextSetFillColorWithColor(context, COLOR_TAG.CGColor);
            CGContextAddRect(context, rectangleGrid);
            CGContextFillPath(context);
        }
        
        UIColor *textColor;
        UIFont *textFont;
        float offvalue = 0;
        if(selectedDate && i==selectedDateBlock){
            textColor = COLOR_SELECTED_DATE;
            textFont = [UIFont fontWithName:@".HelveticaNeueInterface-MediumP4" size:20];
            offvalue = -3.0f;
        }else if((targetDate>21&&i<7)||(targetDate<7&&i>21)){
            textColor = COLOR_DDATEDAYS;
            textFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        }else if(targetColumn>4){
            textColor = COLOR_WEEKENDDAYS;
            textFont = [UIFont fontWithName:@".HelveticaNeueInterface-Italic" size:15];
        }else{
            textColor = COLOR_WORKDAYS;
            textFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        }
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        [ps setAlignment:NSTextAlignmentCenter];
        [ps setLineBreakMode:NSLineBreakByClipping];
        [date drawInRect:CGRectMake(targetX, targetY+12+offvalue, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight)  withAttributes:@{NSFontAttributeName:textFont,NSParagraphStyleAttributeName:ps,NSForegroundColorAttributeName:textColor}];
#else
        offvalue = 0;
        textFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        CGContextSetFillColorWithColor(context,textColor.CGColor);
        [date drawInRect:CGRectMake(targetX, targetY+12+offvalue, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withFont:textFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
#endif

    }
    //    CGContextClosePath(context);
}

#pragma mark - Draw image for animation
-(UIImage *)drawCurrentState {
    float targetHeight = kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
    
    UIGraphicsBeginImageContext(CGSizeMake(kVRGCalendarViewWidth, targetHeight-kVRGCalendarViewTopBarHeight));
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, -kVRGCalendarViewTopBarHeight);    // <-- shift everything up by 40px when drawing.
    [self.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark - Init
-(id)init {
    self = [super initWithFrame:CGRectMake(0, 0, kVRGCalendarViewWidth, 0)];
    if (self) {
        self.contentMode = UIViewContentModeTop;
        self.clipsToBounds=YES;
        
        isAnimating=NO;
        self->labelCurrentMonth = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, kVRGCalendarViewWidth-68, 40)];
        [self addSubview:labelCurrentMonth];
        labelCurrentMonth.backgroundColor=[UIColor clearColor];
        labelCurrentMonth.font = [UIFont fontWithName:@"system" size:17];
        labelCurrentMonth.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
        labelCurrentMonth.textAlignment = NSTextAlignmentCenter;
        
        [self performSelector:@selector(reset) withObject:nil afterDelay:0.1]; //so delegate can be set after init and still get called on init
        //        [self reset];
    }
    return self;
}

-(void)dealloc {
    
    self.delegate=nil;
    self.currentMonth=nil;
    self->labelCurrentMonth=nil;
    
    self.markedDates=nil;
    self.markedColors=nil;
    
//    [super dealloc];
}
@end
