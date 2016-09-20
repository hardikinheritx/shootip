#import <UIKit/UIKit.h>

@interface UIAlertView (Utils)

+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertViewWithMessage:(NSString*)message;
+ (void)showAlertViewWithTitle:(NSString*)title;
+ (void)showOkAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert;
+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert;
+ (void)showOkCancelAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert;
@end
