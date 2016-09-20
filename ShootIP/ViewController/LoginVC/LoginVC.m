//
//  LoginVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"

@interface LoginVC ()
{
    NSMutableDictionary *dictForgotPassword;
}

@end

@implementation LoginVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    txtEmail.text=@"milap.kundalia@inheritx.com";
//    txtPassword.text=@"123456";
    [viewForgotPassword setHidden:YES];
    [Constants setTextFieldPadding:txtEmail paddingValue:20];
    [Constants setTextFieldPadding:txtPassword paddingValue:20];
    [Constants placeholdercolorchange:txtEmail];
    [Constants placeholdercolorchange:txtPassword];
    [txtForgotPasswordEmailId setValue:[[UIColor alloc]initWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    NSArray *fields = @[txtEmail,txtPassword];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //txtEmail.text = @"nilay@inheritx.com";
    //txtPassword.text = @"1234567";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login Screen"];
    [APPDELEGATE setDropOffScreen:@"Login Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        // do some sh!t
        
    }
    
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - KeyboardNotification Delegates -

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, kbSize.height+15, 0)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kbSize.height+15, 0)];
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view layoutIfNeeded];
}


#pragma mark - TextField Delegates -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
    
    if(textField==txtForgotPasswordEmailId)
    {
        if (iPhone4 || iPhone5)
        {
            // move the view up by 90 pts
            CGRect frame = self.view.frame;
            frame.origin.y = -90;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;
            }];
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if(textField==txtForgotPasswordEmailId)
    {
        if (iPhone4 || iPhone5)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;
            }];
        }
    }
    return true;
}

#pragma mark - BSKeyboardControl Delegates -

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    [self.keyboardControls.activeField resignFirstResponder];
}

#pragma mark - Action Delegates -

- (IBAction)actionSignIn:(id)sender
{
    if ([self validation])
    {
        NSMutableDictionary *dictSignIn =[[NSMutableDictionary alloc] init];
        [dictSignIn setObject:txtEmail.text forKey:@"email"];
        [dictSignIn setObject:txtPassword.text forKey:@"password"];
        [dictSignIn setObject:@"" forKey:@"facebook_id"];
        NSString *device=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
        
        if([device length]>0)
        {
            [dictSignIn setObject:[USERDEFAULTS objectForKey:KEYDEVICETOKEN] forKey:KEYDEVICETOKEN];
        }
        else
        {
            [dictSignIn setObject:@"123456" forKey:KEYDEVICETOKEN];
        }
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILOGIN method:@"POST" data:dictSignIn withImages:nil withVideo:nil];
    }
}

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionForgotPasswordClicked:(id)sender
{
    [viewForgotPassword setHidden:NO];
    [txtForgotPasswordEmailId becomeFirstResponder];
    [txtForgotPasswordEmailId setText:@""];
    if (iPhone4 || iPhone5)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -80;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = frame;
        }];
    }
}

- (IBAction)actionSend:(id)sender
{
    if(txtForgotPasswordEmailId.text.length>0)
    {
        BOOL chk = [Constants validateEmail:txtForgotPasswordEmailId.text];
        
        if(!chk)
        {
            [Alerts showAlertWithMessage:@"Please enter valid email address." withBlock:^(NSInteger buttonIndex) {
                [txtForgotPasswordEmailId becomeFirstResponder];
            } andButtons:@"OK", nil];
        }
        else
        {
            dictForgotPassword=[[NSMutableDictionary alloc] init];
            [dictForgotPassword setObject:txtForgotPasswordEmailId.text forKey:@"email"];
            [SVProgressHUD show];
            [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIFORGOTPASSWORD method:@"POST" data:dictForgotPassword withImages:nil withVideo:nil];
        }
    }
    else
    {
        [Alerts showAlertWithMessage:@"Please enter email address." withBlock:^(NSInteger buttonIndex) {
            [txtForgotPasswordEmailId becomeFirstResponder];
        } andButtons:@"OK", nil];
    }
}

- (IBAction)actionCloseForgotPasswordPopup:(id)sender
{
    [viewForgotPassword setHidden:YES];
    [txtForgotPasswordEmailId resignFirstResponder];
    if (iPhone4 || iPhone5)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = frame;
        }];
    }
}

#pragma mark - Custom Methods -

-(void)resignAllTextField
{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
}

-(BOOL)validation
{
    // this method is for Adding validation
    [self resignAllTextField];
    
    BOOL chk = [Constants validateEmail:txtEmail.text];
    
    if([txtEmail.text length] ==0 && [txtPassword.text length] ==0)
    {
        [Alerts showAlertWithMessage:@"Please enter email address/username and password." withBlock:^(NSInteger buttonIndex) {
            [txtEmail becomeFirstResponder];
        } andButtons:@"OK", nil];
        return NO;
    }
    else if([txtEmail.text length] ==0)
    {
        [Alerts showAlertWithMessage:@"Please enter email/username." withBlock:^(NSInteger buttonIndex) {
            [txtEmail becomeFirstResponder];
        } andButtons:@"OK", nil];
        return NO;
    }
//    else if (!chk)
//    {
//        [Alerts showAlertWithMessage:@"Please enter valid email address." withBlock:^(NSInteger buttonIndex) {
//            [txtEmail becomeFirstResponder];
//        } andButtons:@"OK", nil];
//        return NO;
//    }
    else if([txtPassword.text length]==0)
    {
        [Alerts showAlertWithMessage:@"Please enter password." withBlock:^(NSInteger buttonIndex) {
            [txtPassword becomeFirstResponder];
        } andButtons:@"OK", nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APILOGIN])
        {
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYUSERID] forKey:KEYUSERID];
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYISFBUSER] forKey:KEYISFBUSER];
           
            [USERDEFAULTS setObject:@"1" forKey:KEYLOGGEDIN];
            [USERDEFAULTS synchronize];
            [APPDELEGATE PushToNextView:YES];
        }
        else if ([reqURL myContainsString:APIFORGOTPASSWORD])
        {
            [viewForgotPassword setHidden:YES];
            [txtForgotPasswordEmailId resignFirstResponder];
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Link has been send to your email address to reset password."];
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APILOGIN])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APIFORGOTPASSWORD])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
