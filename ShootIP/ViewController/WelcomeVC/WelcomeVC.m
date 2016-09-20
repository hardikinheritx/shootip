//
//  WelcomeVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "WelcomeVC.h"
#import "LoginVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface WelcomeVC ()

@end

@implementation WelcomeVC


#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self.navigationController setNavigationBarHidden:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signInTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [lblAlreadyHaveAccount addGestureRecognizer:tapGestureRecognizer];
    lblAlreadyHaveAccount.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Welcome Screen"];
    [APPDELEGATE setDropOffScreen:@"Welcome Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Navigation -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Action Delegates -

- (IBAction)actionSignUpWithFacebook:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             [SVProgressHUD dismiss];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             [SVProgressHUD dismiss];
         } else {
             NSLog(@"Logged in");
             [self fetchUserInfo];
         }
     }];

//    [Alerts showAlertWithMessage:ALERTINFO withBlock:^(NSInteger buttonIndex) {
//    } andButtons:@"OK", nil];
}

- (IBAction)actionSignUpWithEmail:(id)sender
{
    [self performSegueWithIdentifier:@"SignUpSegue" sender:nil];
}

#pragma mark - Custom Method -

-(void)signInTapped
{
    [self performSegueWithIdentifier:@"SignInSegue" sender:nil];
}

-(void)fetchUserInfo
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
//        /@{@"fields": @"id, name, link, first_name, last_name, picture.type(large), email, birthday, bio ,location ,friends ,hometown , friendlists, gender"}
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, link, first_name, last_name, picture.type(large), email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
            
                NSMutableDictionary *dictSignIn=[[NSMutableDictionary alloc] init];
                 [dictSignIn setObject:result[@"email"] forKey:@"email"];
                 [dictSignIn setObject:result[@"name"] forKey:@"username"];
                 [dictSignIn setObject:@"" forKey:@"password"];
                 [dictSignIn setObject:result[@"id"] forKey:@"facebook_id"];
                 NSString *device=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
                 
                 if([device length]>0)
                 {
                     [dictSignIn setObject:[USERDEFAULTS objectForKey:KEYDEVICETOKEN] forKey:KEYDEVICETOKEN];
                 }
                 else
                 {
                     [dictSignIn setObject:@"123456" forKey:KEYDEVICETOKEN];
                 }
                [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILOGIN method:@"POST" data:dictSignIn withImages:nil withVideo:nil];
                 
             }
             else
             {
                 NSLog(@"Error %@",error);
             }
         }];
    }
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult: (FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    
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
