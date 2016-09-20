//
//  SearchVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "SearchVC.h"
#import "AlbumListingVC.h"
#import "PlaceVC.h"

@interface SearchVC ()

@end

@implementation SearchVC

@synthesize OldIndexTab, CurrentIndexTab,arraySearchList,tblSearch;

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTableBackgroundColor];
    //Intialize array
    arraySearchList = [[NSMutableArray alloc]init];
    self.arrayUserSearchList = [[NSMutableArray alloc]init];
    OldIndexTab = 1;
    CurrentIndexTab = 1;
    [self.txtSearch becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
    self.imgTab.frame = CGRectMake(0, self.imgTab.frame.origin.y, self.imgTab.frame.size.width, self.imgTab.frame.size.height);
    
    if(CurrentIndexTab==2)
    {
        self.imgTab.frame = CGRectMake(btnSearchAlbum.frame.origin.x, self.imgTab.frame.origin.y, self.imgTab.frame.size.width, self.imgTab.frame.size.height);
    }
    else if(CurrentIndexTab==3)
    {
        self.imgTab.frame = CGRectMake(btnSearchHashtag.frame.origin.x, self.imgTab.frame.origin.y, self.imgTab.frame.size.width, self.imgTab.frame.size.height);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Search Screen"];
    [APPDELEGATE setDropOffScreen:@"Search Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Action Method -

- (IBAction)actionTab:(id)sender
{
    CurrentIndexTab = [sender tag];
    
    if (OldIndexTab != CurrentIndexTab)
    {
        OldIndexTab = CurrentIndexTab;
        // move the Tab Image Right and Left according to its x- axis
        CGRect frame = self.imgTab.frame;
        frame.origin.x = [sender frame].origin.x;
        [UIView animateWithDuration:0.3 animations:^{
            self.imgTab.frame = frame;
        }];
    }
    
    arraySearchList=[[NSMutableArray alloc] init];
    [tblSearch reloadData];

    if(self.txtSearch.text.length>0)
    {
        [self callSearchWebservice:self.txtSearch.text];
    }
}

#pragma mark - UITextFieldDelegate methods -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(newString.length>0)
    {
        [self callSearchWebservice:newString];
    }
    else
    {
        arraySearchList=[[NSMutableArray alloc] init];
        [tblSearch reloadData];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Webservice Call -

-(void)callSearchWebservice:(NSString *)string
{
    NSArray *arrKeyword=[[NSArray alloc] initWithObjects:@"place",@"album",@"hashtag", nil];
    
    NSMutableDictionary * dictSearch=[[NSMutableDictionary alloc] init];
    [dictSearch setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictSearch setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictSearch setObject:string forKey:@"keyword"];
    [dictSearch setObject:[arrKeyword objectAtIndex:CurrentIndexTab-1] forKey:@"type"];
    //    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APISEARCH method:@"POST" data:dictSearch withImages:nil withVideo:nil];
}

-(void)setTableBackgroundColor
{
    tblSearch.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    tblSearch.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table Datasource and delegate -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arraySearchList.count;
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
    static NSString *cellID =  @"SearchListCellIdentifier";
    
    SearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[SearchListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (CurrentIndexTab == 1)
    {
        cell.imgIcon.image = [UIImage imageNamed:@"icn_location"];
        cell.imgIcon.layer.cornerRadius = cell.imgIcon.frame.size.width / 2;
        cell.imgIcon.layer.borderWidth = 1.0f;
        cell.imgIcon.layer.borderColor = [UIColor clearColor].CGColor;
        cell.imgIcon.clipsToBounds = YES;
        
//        NSString *city=[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"city"]];
//        
//        if(city.length>0)
//        {
//            cell.lblname.text = [NSString stringWithFormat:@"%@, %@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"],[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"city"]];
//        }
//        else
//        {
//            cell.lblname.text = [NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"]];
//        }
        
        
        
        //NSString *place=[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"]];
        
        if ([[[arraySearchList objectAtIndex:indexPath.row] allKeys] containsObject:@"place"]) {
              cell.lblname.text = [NSString stringWithFormat:@"%@, %@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"],[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"city"]];
        }else {
              cell.lblname.text = [NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"city"]];
        }
        
    }
    else if(CurrentIndexTab == 2)
    {
        cell.imgIcon.image = [UIImage imageNamed:@"img_01"];
        cell.imgIcon.layer.cornerRadius = cell.imgIcon.frame.size.width / 2;
        cell.imgIcon.layer.borderWidth = 1.0f;
        cell.imgIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imgIcon.clipsToBounds = YES;
        cell.lblname.text = [NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"title"]];
    }
    else if(CurrentIndexTab == 3)
    {
        cell.imgIcon.image = [UIImage imageNamed:@"img_01"];
        cell.imgIcon.layer.cornerRadius = cell.imgIcon.frame.size.width / 2;
        cell.imgIcon.layer.borderWidth = 1.0f;
        cell.imgIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imgIcon.clipsToBounds = YES;
        cell.lblname.text = [NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"hash_tag"]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    SearchDetailsVC *searchdetailsvc = (SearchDetailsVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"SearchDetailsVC"];
//    searchdetailsvc.strTitleName = [self.arrayUserSearchList objectAtIndex:indexPath.row];
    
    if (CurrentIndexTab == 2)
    {
        PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
        placeVC.fromWhere=@"AlbumSearch";
        placeVC.strTitle=@"Album";
        placeVC.dictPlaceDetail=[arraySearchList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:placeVC animated:YES];
//        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in upcomming milestone."];
        [self GoogleAnalyticsEvent:@"Search" action:@"ByAlbum" label:[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"title"]]];
    }
    else if (CurrentIndexTab == 3)
    {
        PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
        placeVC.fromWhere=@"HashTag";
        placeVC.strTitle=@"HashTag";
        placeVC.dictPlaceDetail=[arraySearchList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:placeVC animated:YES];
//        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in upcomming milestone."];
        [self GoogleAnalyticsEvent:@"Search" action:@"ByHashtag" label:[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"hash_tag"]]];
    }
    else
    {
        PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
        placeVC.dictPlaceDetail=[arraySearchList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:placeVC animated:YES];
//        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in upcomming milestone."];
        
        //NSString *place=[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"]];
        
        if ([[[arraySearchList objectAtIndex:indexPath.row] allKeys] containsObject:@"place"]) {
           
        }else {
            
            placeVC.strTitle = [[arraySearchList objectAtIndex:indexPath.row] objectForKey: @"city"];
            
            placeVC.fromWhere = @"Top Destination";
        }
        
        [self GoogleAnalyticsEvent:@"Search" action:@"ByPlace" label:[NSString stringWithFormat:@"%@",[[arraySearchList objectAtIndex:indexPath.row] objectForKey:@"place"]]];
    }
    
    
    [self.txtSearch resignFirstResponder];
}

-(void)GoogleAnalyticsEvent:(NSString*)Search action:(NSString*)action label:(NSString*)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Search Screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:Search
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
  
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APISEARCH])
        {
            arraySearchList=[[NSMutableArray alloc] init];
            arraySearchList=[[dictData objectForKey:@"data"] objectForKey:@"search_data"];

            [tblSearch reloadData];
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APISEARCH])
        {
            arraySearchList=[[NSMutableArray alloc] init];
            [tblSearch reloadData];
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
