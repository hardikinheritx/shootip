#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)

+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (void)showAlertViewWithMessage:(NSString*)message
{
	[self showAlertViewWithTitle:nil message:message];
}

+ (void)showAlertViewWithTitle:(NSString*)title
{
	[self showAlertViewWithTitle:title message:nil];
}

+ (void)showOkAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
	alert.tag = tagAlert;
	[alert show];
}

+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
	alert.tag = tagAlert;
	[alert show];
}

+ (void)showOkCancelAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tagAlert
{	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Cancel", nil),nil];
	alert.tag = tagAlert;
	[alert show];
}

@end