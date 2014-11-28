//
//  PopUpDialogView.h
//  DXAlertView
//
//  Created by wlpiaoyi on 14-4-9.
//  Copyright (c) 2014年 xiekw. All rights reserved.
//

#import "PopUpBasisView.h"
#import "Common.h"


@interface PopUpDialogView:PopUpBasisView
+(PopUpDialogView*) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id/*<PopUpDialogViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
+(PopUpDialogView*) initWithTitle:(NSString *)title message:(NSString *)message TargetView:(UIView*) targetView delegate:(id/*<PopUpDialogViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
@end
@protocol PopUpDialogViewDelegate <NSObject>
@required
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(PopUpDialogView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
@optional
- (void)alertViewCancel:(PopUpDialogView *)alertView;
@end
