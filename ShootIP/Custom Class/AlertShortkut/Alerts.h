
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^actionBlock)(NSInteger buttonIndex);
typedef void(^inputAlertBlock)(NSInteger buttonIndex, NSString *strMessage);

@interface Alerts : NSObject <UIAlertViewDelegate,UIActionSheetDelegate>

@property (nonatomic,copy) actionBlock pBlock;
@property (nonatomic,copy) inputAlertBlock pInputBlock;

+(void)showAlertWithInputFieldAndMessage:(NSString*)pstrMessage withTitle:(NSString*)pstrTitle withBlock:(inputAlertBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION;
+(void)showAlertWithPasswordInputFieldAndMessage:(NSString*)pstrMessage withTitle:(NSString*)pstrTitle withBlock:(inputAlertBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION;
+(void)showAlertWithMessage:(NSString*)pstrMessage withBlock:(actionBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION;
+(UIActionSheet *)actionSheetWithBlock:(actionBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION;

@end
