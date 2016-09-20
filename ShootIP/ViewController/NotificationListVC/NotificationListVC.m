//
//  NotificationListVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "NotificationListVC.h"
#import "PlaceVC.h"

@interface NotificationListVC ()
{
    NSMutableArray *arrNotificationList;
    NSInteger totalPage;
    NSInteger nextPage;
}

@end

@implementation NotificationListVC
@synthesize tblNotificationList;

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
    self.navigationController.navigationBar.hidden = YES;
//    [self playAudio];
    
    nextPage=0;
    [self callWebservice:nextPage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Notification List Screen"];
    [APPDELEGATE setDropOffScreen:@"Notification List Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)callWebservice:(NSInteger)index
{
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)nextPage] forKey:KEYPAGEINDEX];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APINOTIFICATIONLIST method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}

-(void)playAudio
{
    AudioServicesPlaySystemSound(1118);
}

#pragma mark - Table Datasource and delegate -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrNotificationList.count;;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSDictionary *dictNotificationList = [[APPDELEGATE arrayNotificationList] objectAtIndex:indexPath.row];
    
    static NSString *cellID =  @"NotificationListCellIdentifier";
    
    NotificationListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[NotificationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrNotificationList objectAtIndex:indexPath.row] objectForKey:@"post_video_thumb"]]]];
        [cell.imgOfPlace setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:nil failure:nil];

    
    cell.lblNameOfPlace.text = [NSString stringWithFormat:@"%@",[[arrNotificationList objectAtIndex:indexPath.row] objectForKey:@"place"]];
    
    
    NSString *strCity=[NSString stringWithFormat:@"%@",[[arrNotificationList objectAtIndex:indexPath.row] objectForKey:@"city"]];
    NSString *strCountry=[NSString stringWithFormat:@"%@",[[arrNotificationList objectAtIndex:indexPath.row] objectForKey:@"country"]];
    if([strCity length]>0 && [strCountry length]>0)
    {
        cell.lblCountryOfPlace.text = [NSString stringWithFormat:@"%@,%@",strCity,strCountry];
    }
    else if ([strCity length]>0 && [strCountry length]<1)
    {
        cell.lblCountryOfPlace.text = [NSString stringWithFormat:@"%@",strCity];
    }
    else if ([strCountry length]>0 && [strCity length]<1)
    {
        cell.lblCountryOfPlace.text = [NSString stringWithFormat:@"%@",strCountry];
    }
    
    cell.lblDescOfPlace.text = [NSString stringWithFormat:@"%@",[[arrNotificationList objectAtIndex:indexPath.row] objectForKey:@"place_description"]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
    placeVC.dictPlaceDetail=[arrNotificationList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:placeVC animated:YES];
    
//    [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in upcomming milestone."];  
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == arrNotificationList.count && arrNotificationList.count > 1)
    {
        if(nextPage==0)
        {
            
        }
        else
        {
            [self callWebservice:nextPage];
        }
    }
}


#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APINOTIFICATIONLIST])
        {
            arrNotificationList=[[NSMutableArray alloc] initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"notification_lists"]];
            if(arrNotificationList.count>0)
            {
                totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
                lblNoData.hidden=YES;
                tblNotificationList.hidden=NO;
                [tblNotificationList reloadData];
            }
            else
            {
                lblNoData.hidden=NO;
                tblNotificationList.hidden=YES;
            }
        }
    }
    else
    {
        if([reqURL myContainsString:APINOTIFICATIONLIST])
        {
            lblNoData.hidden=NO;
            tblNotificationList.hidden=YES;
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}


#pragma mark - Memory managment -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
