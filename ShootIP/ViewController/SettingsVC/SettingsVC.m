//
//  SettingsVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/12/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "SettingsVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "TermsServiceVC.h"
#import "PrivacyPolicyVC.h"
#import "ContactUsVC.h"

@implementation SettingsVC
{
    NSMutableArray *arrSetting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrSetting=[[NSMutableArray alloc] initWithArray:[APPDELEGATE arraySettingsList]];

    
    if ([[[USERDEFAULTS objectForKey:KEYISFBUSER] stringValue] isEqualToString:@"1"]) {
        [arrSetting removeObjectAtIndex:1];
    }
    
#pragma mark - Set the Background color to Table
    self.tblSettingsList.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    
    self.tblSettingsList.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.switchValue = 1;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Setting Screen"];
    [APPDELEGATE setDropOffScreen:@"Setting Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrSetting.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 60;    
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID =  @"SettingsListCellIdentifier";
    
    SettingsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[SettingsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    if (indexPath.row == 0) {
        
        cell.switchNotification.hidden = NO;
    }
    
    else {
        
        cell.switchNotification.hidden = YES;
    }
    
    cell.lblTitle.text = [NSString stringWithFormat:@"%@",[arrSetting objectAtIndex:indexPath.row]];

    if (self.switchValue == 1) {
        
        [cell.switchNotification setOn:YES];
    }
    
    else {
        
        [cell.switchNotification setOn:NO];
    }
    
    [cell.switchNotification addTarget:self action:@selector(actionswitch:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[arrSetting objectAtIndex:indexPath.row] isEqualToString:@"Support"])
    {
        ContactUsVC *contactUsVC = (ContactUsVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"ContactUsVC"];
        [self.navigationController pushViewController:contactUsVC animated:YES];
    }
    else if ([[arrSetting objectAtIndex:indexPath.row] isEqualToString:@"Logout"])
    {
        //FB logout
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [[ServerConnection sharedConnection] stopDownloadFor:@"ProfileVC"];

        [APPDELEGATE clearCachedDirectory];
        
        [USERDEFAULTS setObject:@"0" forKey:KEYLOGGEDIN];
        [USERDEFAULTS synchronize];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        UINavigationController *navController = (UINavigationController *)APPDELEGATE.window.rootViewController;
        [navController popToRootViewControllerAnimated:YES];

    }
    else if ([[arrSetting objectAtIndex:indexPath.row] isEqualToString:@"Terms and Service"])
    {
        TermsServiceVC *termsServiceVC = (TermsServiceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"TermsServiceVC"];
        [self.navigationController pushViewController:termsServiceVC animated:YES];
    }
    else if ([[arrSetting objectAtIndex:indexPath.row] isEqualToString:@"Privacy Policy"])
    {
        PrivacyPolicyVC *privacyPolicyvc = (PrivacyPolicyVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PrivacyPolicyVC"];
        [self.navigationController pushViewController:privacyPolicyvc animated:YES];
    }
    else if ([[arrSetting objectAtIndex:indexPath.row] isEqualToString:@"Change Password"])
    {
        ChangePasswordVC *changepasswordvc = (ChangePasswordVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
        [self.navigationController pushViewController:changepasswordvc animated:YES];
    }
}

#pragma mark - Check if the Switch is currently ON or OFF
- (void) actionswitch:(UISwitch *)paramSender{
    
    if ([paramSender isOn]){
         self.switchValue = 1;
    } else {
         self.switchValue = 0;
    }
    
}


#pragma mark - Action for back Button
- (IBAction)actionback:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
