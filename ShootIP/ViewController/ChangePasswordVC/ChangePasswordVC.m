//
//  ChangePasswordVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/12/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC ()
{
    NSMutableDictionary *dictChangePassword;
}

@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *fields = @[self.txtOldPwd,self.txtNewPwd,self.txtConfirmPwd];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    [Constants setTextFieldPadding:self.txtOldPwd paddingValue:20];
    [Constants setTextFieldPadding:self.txtNewPwd paddingValue:20];
    [Constants setTextFieldPadding:self.txtConfirmPwd paddingValue:20];
    
    
    [Constants placeholdercolorchange:self.txtOldPwd];
    [Constants placeholdercolorchange:self.txtNewPwd];
    [Constants placeholdercolorchange:self.txtConfirmPwd];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Change Password Screen"];
    [APPDELEGATE setDropOffScreen:@"Change Password Screen"];
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

#pragma mark - KeyboardNotification Delegates

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

#pragma mark - BSKeyboardControl Delegates

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    [self.keyboardControls.activeField resignFirstResponder];
}

#pragma mark - TextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

#pragma mark - Action for save Button
- (IBAction)actionSave:(id)sender {
    
    if ([self validation])
    {
        dictChangePassword=[[NSMutableDictionary alloc] init];
        [dictChangePassword setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:@"user_id"];
        [dictChangePassword setObject:self.txtOldPwd.text forKey:@"old_password"];
        [dictChangePassword setObject:self.txtNewPwd.text forKey:@"new_password"];
        [dictChangePassword setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:@"auth_token"];

        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APICHANGEPASSWORD method:@"POST" data:dictChangePassword withImages:nil withVideo:nil];
    }
}

#pragma mark - Custom Methods
-(void)resignAllTextField
{
    [self.txtOldPwd resignFirstResponder];
    [self.txtNewPwd resignFirstResponder];
    [self.txtConfirmPwd resignFirstResponder];
}

-(BOOL)validation
{
    // this method is for Adding validation
    [self resignAllTextField];
    
    if([self.txtOldPwd.text length] ==0)
    {
        [Alerts showAlertWithMessage:ALERTOLDPASSWORDBLANK  withBlock:^(NSInteger buttonIndex) {
            
            [self.txtOldPwd becomeFirstResponder];
            
        } andButtons:ALERT_OK, nil];
        return NO;
    }
    
    else if([self.txtNewPwd.text length]==0)
    {
        [Alerts showAlertWithMessage:ALERTNEWPASSWORDBLANK withBlock:^(NSInteger buttonIndex) {
            [self.txtNewPwd becomeFirstResponder];
            
        } andButtons:ALERT_OK, nil];
        return NO;
    }
    else if([self.txtConfirmPwd.text length]==0)
    {
        [Alerts showAlertWithMessage:ALERTRETYPEPASSWORDBLANK withBlock:^(NSInteger buttonIndex) {
            [self.txtConfirmPwd becomeFirstResponder];
            
        } andButtons:ALERT_OK, nil];
        return NO;
    }
    
    else if([self.txtNewPwd.text length]<6)
    {
        [self resignAllTextField];
        
        [Alerts showAlertWithMessage:ALERTSMALLPASSWORD withBlock:^(NSInteger buttonIndex) {
            
            [self.txtNewPwd becomeFirstResponder];
            
        } andButtons:ALERT_OK, nil];
        return NO;
    }
    
    
    else if(![self.txtConfirmPwd.text isEqualToString:self.txtNewPwd.text])
    {
        [Alerts showAlertWithMessage:ALERTPASSWORDMISMATCH withBlock:^(NSInteger buttonIndex) {
            
            [self.txtConfirmPwd becomeFirstResponder];
            
        } andButtons:ALERT_OK, nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - Action for back Button
- (IBAction)actionback:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebService

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APICHANGEPASSWORD])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Password Changed Successfully"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APICHANGEPASSWORD])
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



#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
