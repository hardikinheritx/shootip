//
//  TopDestinationVC.m
//  ShootIP
//
//  Created by Paras Modi on 1/13/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "TopDestinationVC.h"
#import "PlaceVC.h"

@interface TopDestinationVC ()

@end

@implementation TopDestinationVC

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTableBackgroundColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Top Destination Screen"];
    [APPDELEGATE setDropOffScreen:@"Top Destination Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [APPDELEGATE arrayTopDestinationList].count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 200;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dicTopDestination = [[APPDELEGATE arrayTopDestinationList] objectAtIndex:indexPath.row];
    
    static NSString *cellID =  @"TopDestinationListCellIdentifier";
    
    TopDestinationListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[TopDestinationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    cell.imgDestination.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dicTopDestination objectForKey:@"DestinationThumbnail"]]];
    
    cell.lblDestinationName.text = [NSString stringWithFormat:@"%@",[dicTopDestination objectForKey:@"DestinationName"]];

    return cell;
//    Top Destination
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceVC *objPlaceVC = [STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
    objPlaceVC.fromWhere=@"Top Destination";
    objPlaceVC.strTitle=[[[APPDELEGATE arrayTopDestinationList] objectAtIndex:indexPath.row] objectForKey:@"DestinationName"];
    [self.navigationController pushViewController:objPlaceVC animated:YES];
//    [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in next milestone."];
}

#pragma mark - Action Button

- (IBAction)actionSearch:(id)sender
{
    [self performSegueWithIdentifier:@"SearchSegue" sender:nil];
}

#pragma mark - Custom Action

-(void)setTableBackgroundColor
{
    self.tblTopDestination.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    self.tblTopDestination.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
