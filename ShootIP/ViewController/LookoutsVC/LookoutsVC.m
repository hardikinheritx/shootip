//
//  LookoutsVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/11/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "LookoutsVC.h"

@interface LookoutsVC ()
{
    NSMutableArray *arrListOfLookOuts;
    UIButton *btnClicked;
}

@end

@implementation LookoutsVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)GetListOFFollowingPlaces
{
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:_strOtherUserID forKey:@"other_user_id"];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFFOLLOWPLACE method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    
    [self GetListOFFollowingPlaces];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"LookOuts Screen"];
    [APPDELEGATE setDropOffScreen:@"LookOuts Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Table Datasource and delegate -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrListOfLookOuts.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 48;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSDictionary *dictLookoutsList = [self.mutablearrayLookoutsListInfo objectAtIndex:indexPath.row];
    
    static NSString *cellID =  @"LookoutsListCellIdentifier";
    
    LookoutsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[LookoutsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell.btnUnwatch removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    if ([[[[arrListOfLookOuts objectAtIndex:indexPath.row] objectForKey:@"is_follow"] stringValue]isEqualToString:@"0"]){
        cell.btnUnwatch.tag=indexPath.row;
        [cell.btnUnwatch addTarget:self action:@selector(actionWatch:) forControlEvents:UIControlEventTouchUpInside];

        [cell.btnUnwatch setTitle:@"WATCH" forState:UIControlStateNormal];
    }
    else
    {
        cell.btnUnwatch.tag=indexPath.row;
        [cell.btnUnwatch addTarget:self action:@selector(actionUnWatch:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnUnwatch setTitle:@"UNWATCH" forState:UIControlStateNormal];
    }


    cell.lblPlaceName.text = [NSString stringWithFormat:@"%@",[[arrListOfLookOuts objectAtIndex:indexPath.row] objectForKey:@"place"]];
    
    
    return cell;
    
}

#pragma mark - Action Method -

-(void)actionWatch:(id)sender
{
    btnClicked=(UIButton*)sender;
    NSMutableDictionary * dictUnfollowPlace=[[NSMutableDictionary alloc] init];
    [dictUnfollowPlace setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictUnfollowPlace setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictUnfollowPlace setObject:[[arrListOfLookOuts objectAtIndex:btnClicked.tag] objectForKey:@"place"] forKey:@"place"];
    [dictUnfollowPlace setObject:@"1" forKey:@"is_follow"];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIFOLLOWUNFOLLOWPLACE method:@"POST" data:dictUnfollowPlace withImages:nil withVideo:nil];
}

-(void)actionUnWatch:(id)sender
{
    btnClicked=(UIButton*)sender;
    NSMutableDictionary * dictUnfollowPlace=[[NSMutableDictionary alloc] init];
    [dictUnfollowPlace setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictUnfollowPlace setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictUnfollowPlace setObject:[[arrListOfLookOuts objectAtIndex:btnClicked.tag] objectForKey:@"place"] forKey:@"place"];
    [dictUnfollowPlace setObject:@"0" forKey:@"is_follow"];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIFOLLOWUNFOLLOWPLACE method:@"POST" data:dictUnfollowPlace withImages:nil withVideo:nil];
}

- (IBAction)actionback:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APILISTOFFOLLOWPLACE])
        {
            arrListOfLookOuts=[[NSMutableArray alloc] initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"places"]];
            [self.tblLookoutsList reloadData];
        }
        else if ([reqURL myContainsString:APIFOLLOWUNFOLLOWPLACE])
        {
            if(arrListOfLookOuts.count>0)
            {
                [arrListOfLookOuts removeObjectAtIndex:btnClicked.tag];
              //  [self GetListOFFollowingPlaces];
                [self.tblLookoutsList reloadData];
            }
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APILISTOFFOLLOWPLACE])
        {

            //            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if([reqURL myContainsString:APIFOLLOWUNFOLLOWPLACE])
        {
            //            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
