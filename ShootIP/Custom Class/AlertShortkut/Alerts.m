
#import "Alerts.h"

@implementation Alerts

+(Alerts*)sharedInstance
{
    static Alerts *objAlert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objAlert = [[self alloc] init];
    });
    return objAlert;
}

+(void)showAlertWithInputFieldAndMessage:(NSString*)pstrMessage withTitle:(NSString*)pstrTitle withBlock:(inputAlertBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION
{
    Alerts *objAlerts = [Alerts sharedInstance];
    objAlerts.pInputBlock = pobjBlock;
    
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:pstrTitle message:pstrMessage delegate:objAlerts cancelButtonTitle:nil otherButtonTitles:nil];
    

    va_list strButtonNameList;
    va_start(strButtonNameList, pstrButton);
    for (NSString *strBtnTitle = pstrButton; strBtnTitle != nil; strBtnTitle = va_arg(strButtonNameList, NSString*))
    {
        [alert addButtonWithTitle:strBtnTitle];
    }
    va_end(strButtonNameList);
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
     UITextField *txtInput = [alert textFieldAtIndex:0];
    txtInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    [alert show];
}

+(void)showAlertWithPasswordInputFieldAndMessage:(NSString*)pstrMessage withTitle:(NSString*)pstrTitle withBlock:(inputAlertBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION
{
    Alerts *objAlerts = [Alerts sharedInstance];
    objAlerts.pInputBlock = pobjBlock;
    
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:pstrTitle message:pstrMessage delegate:objAlerts cancelButtonTitle:nil otherButtonTitles:nil];
    
    
    va_list strButtonNameList;
    va_start(strButtonNameList, pstrButton);
    for (NSString *strBtnTitle = pstrButton; strBtnTitle != nil; strBtnTitle = va_arg(strButtonNameList, NSString*))
    {
        [alert addButtonWithTitle:strBtnTitle];
    }
    va_end(strButtonNameList);
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *txtInput = [alert textFieldAtIndex:0];
    txtInput.secureTextEntry=YES;
    txtInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    [alert show];
}


+(void)showAlertWithMessage:(NSString*)pstrMessage withBlock:(actionBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION
{
    Alerts *objAlerts = [Alerts sharedInstance];
    objAlerts.pBlock = pobjBlock;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APPNAME message:pstrMessage delegate:objAlerts cancelButtonTitle:nil otherButtonTitles:nil];
    
    va_list strButtonNameList;
    va_start(strButtonNameList, pstrButton);
    for (NSString *strBtnTitle = pstrButton; strBtnTitle != nil; strBtnTitle = va_arg(strButtonNameList, NSString*))
    {
        [alert addButtonWithTitle:strBtnTitle];
    }
    va_end(strButtonNameList);
    
    [alert show];
}

+(UIActionSheet *)actionSheetWithBlock:(actionBlock)pobjBlock andButtons:(NSString*)pstrButton, ...NS_REQUIRES_NIL_TERMINATION
{
    Alerts *objAlerts = [Alerts sharedInstance];
    objAlerts.pBlock = pobjBlock;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:objAlerts cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    va_list strButtonNameList;
    va_start(strButtonNameList, pstrButton);
    for (NSString *strBtnTitle = pstrButton; strBtnTitle != nil; strBtnTitle = va_arg(strButtonNameList, NSString*))
    {
        if(![[strBtnTitle lowercaseString] isEqualToString:@"cancel"])
            [actionSheet addButtonWithTitle:strBtnTitle];
    }
    va_end(strButtonNameList);
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
    
    return actionSheet;
}

#pragma mark - Delegates

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.pBlock)
        self.pBlock(buttonIndex);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
    {
        UITextField *txtInput = [alertView textFieldAtIndex:0];
        
        if (self.pInputBlock)
            self.pInputBlock(buttonIndex,txtInput.text);
    }
    else
    {
        if (self.pBlock)
            self.pBlock(buttonIndex);
    }
}

@end