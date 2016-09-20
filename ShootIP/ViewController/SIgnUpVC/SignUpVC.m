//
//  SIgnUpVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()
{
    UIImagePickerController *pickerController;
    NSMutableDictionary *dictSignUp;
    UIImage *userProfileImg;
    NSMutableDictionary *dictProfilePicture;

}

@end

@implementation SignUpVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];

    NSArray *fields = @[txtUsername,txtEmail,txtPassword,txtConfirmPassword];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [Constants setTextFieldPadding:txtEmail paddingValue:20];
    [Constants setTextFieldPadding:txtPassword paddingValue:20];
    [Constants setTextFieldPadding:txtUsername paddingValue:20];
    [Constants setTextFieldPadding:txtConfirmPassword paddingValue:20];
    
    [Constants placeholdercolorchange:txtUsername];
    [Constants placeholdercolorchange:txtConfirmPassword];
    [Constants placeholdercolorchange:txtEmail];
    [Constants placeholdercolorchange:txtPassword];
    [btnClearUsername setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    imgUserProfile.layer.cornerRadius = imgUserProfile.frame.size.width / 2;
    imgUserProfile.clipsToBounds = YES;
    imgUserProfile.layer.borderWidth = 3.0f;
    imgUserProfile.layer.borderColor = [UIColor whiteColor].CGColor;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SignUp Screen"];
    [APPDELEGATE setDropOffScreen:@"SignUp Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

#pragma mark - BSKeyboardControl Delegates -

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    [self.keyboardControls.activeField resignFirstResponder];
}

#pragma mark - TextField Delegates -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==txtUsername)
    {
        if(txtUsername.text>0)
        {
            NSMutableDictionary *dictVerifyUsername=[[NSMutableDictionary alloc] init];
            [dictVerifyUsername setObject:txtUsername.text forKey:KEYUSERNAME];
            [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIVERIFYUSERNAME method:@"POST" data:dictVerifyUsername withImages:nil withVideo:nil];
        }
    }
    return YES;
}

#pragma mark - Action Delegates -

- (IBAction)actionSignUp:(id)sender
{
    if ([self validation])
    {
        dictSignUp=[[NSMutableDictionary alloc] init];
        [dictSignUp setObject:txtEmail.text forKey:@"email"];
        [dictSignUp setObject:txtUsername.text forKey:@"username"];
        [dictSignUp setObject:txtPassword.text forKey:@"password"];
        
        NSString *device=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
        
        if([device length]>0)
        {
            [dictSignUp setObject:[USERDEFAULTS objectForKey:KEYDEVICETOKEN] forKey:@"iphone_device_token"];
        }
        else
        {
            [dictSignUp setObject:@"123456" forKey:@"iphone_device_token"];
        }
        [SVProgressHUD show];
        
        
        if (dictProfilePicture)
        {
            [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APISIGNUP method:@"POST" data:dictSignUp withImages:dictProfilePicture withVideo:nil];
        }
        else
        {
            [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APISIGNUP method:@"POST" data:dictSignUp withImages:nil withVideo:nil];
        }
        
        
//        NSMutableDictionary *dictImage=[[NSMutableDictionary alloc] initWithObjectsAndKeys:userProfileImg,@"user_image", nil];
//        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APISIGNUP method:@"POST" data:dictSignUp withImages:dictImage withVideo:nil];
    }
    
}

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionUserProfile:(id)sender
{
    [self resignAllTextField];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Profile Picture"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Gallery", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (IBAction)actionClearUsername:(id)sender
{
    [txtUsername setText:@""];
    [btnClearUsername setHidden:YES]; 
}

#pragma mark - UIActionSheet Delegate methods -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerController animated:YES completion:^{}];
        }
        else
        {
            
        }
    }
    else if (buttonIndex==1)
    {
        pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerController animated:YES completion:^{}];
    }
}

#pragma mark - Image Picker Delegate method -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        userProfileImg=[info objectForKey:UIImagePickerControllerEditedImage];
        imgUserProfile.image=userProfileImg;
        
        
        userProfileImg =[Constants imageWithImage:[info objectForKey:UIImagePickerControllerEditedImage] scaledToSize:DefaultProfileImageSize];
        userProfileImg = [Constants scaleAndRotateImage:userProfileImg andMaxResolution:0];
        
        if (!userProfileImg)
        {
            return;
        }
        
        // Adjusting Image Orientation
        NSData *data = UIImagePNGRepresentation(userProfileImg);
        UIImage *tmp = [UIImage imageWithData:data];
        userProfileImg = [UIImage imageWithCGImage:tmp.CGImage scale:userProfileImg.scale orientation:userProfileImg.imageOrientation];
        
        [imgUserProfile setImage:userProfileImg];
        [imgUserProfile setContentMode:UIViewContentModeScaleAspectFit];
        //          [_btnProfilePic setImage:selectedImage forState:UIControlStateNormal];
        [btnUserProfile setTitle:@"" forState:UIControlStateNormal];
        dictProfilePicture = [[NSMutableDictionary alloc]initWithObjectsAndKeys:userProfileImg,@"user_image",nil];

        
    }];
}

#pragma mark - Custom Methods -

-(void)resignAllTextField
{
    [txtUsername resignFirstResponder];
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtConfirmPassword resignFirstResponder];
}

-(BOOL)validation
{
    // this method is for Adding validation
    [self resignAllTextField];
    
    BOOL chk = [Constants validateEmail:txtEmail.text];
    
    if([txtUsername.text length] ==0)
    {
        [Alerts showAlertWithMessage:@"Please enter username." withBlock:^(NSInteger buttonIndex) {
            
            [txtUsername becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if([txtEmail.text length]==0)
    {
        [Alerts showAlertWithMessage:@"Please enter email address." withBlock:^(NSInteger buttonIndex) {
            [txtEmail becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if([txtPassword.text length]==0)
    {
        [Alerts showAlertWithMessage:@"Please enter password." withBlock:^(NSInteger buttonIndex) {
            [txtPassword becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if([txtConfirmPassword.text length]==0)
    {
        [Alerts showAlertWithMessage:@"Please enter confirm password." withBlock:^(NSInteger buttonIndex) {
            [txtConfirmPassword becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if (txtUsername.text.length<5 || txtUsername.text.length>15)
    {
        [Alerts showAlertWithMessage:@"Username must be at least 5 characters and maximum 15 characters." withBlock:^(NSInteger buttonIndex) {
            [txtUsername becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if (!chk)
    {
        [Alerts showAlertWithMessage:@"Please enter valid email address." withBlock:^(NSInteger buttonIndex) {
            [txtEmail becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if([txtPassword.text length]<6)
    {
        [self resignAllTextField];
        
        [Alerts showAlertWithMessage:@"Password must be at least 6 characters." withBlock:^(NSInteger buttonIndex) {
            
            [txtPassword becomeFirstResponder];
            
        } andButtons:@"OK", nil];
        return NO;
    }
    else if(![txtConfirmPassword.text isEqualToString:txtPassword.text])
    {
        [Alerts showAlertWithMessage:@"Password and confirm password do not match." withBlock:^(NSInteger buttonIndex) {
            
            [txtConfirmPassword becomeFirstResponder];
            
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
        if ([reqURL myContainsString:APISIGNUP])
        {
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYUSERID] forKey:KEYUSERID];
            [USERDEFAULTS setObject:[[dictData objectForKey:@"data"] objectForKey:KEYISFBUSER] forKey:KEYISFBUSER];
            [USERDEFAULTS setObject:@"1" forKey:KEYLOGGEDIN];
            [USERDEFAULTS synchronize];
            [self performSegueWithIdentifier:@"tutorialSegue" sender:nil];
        }
        else if ([reqURL myContainsString:APIVERIFYUSERNAME])
        {
            
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APISIGNUP])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APIVERIFYUSERNAME])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            [btnClearUsername setHidden:NO];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
