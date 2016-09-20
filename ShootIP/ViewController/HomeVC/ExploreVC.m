//
//  ExploreVC.m
//  ShootIP
//
//  Created by Kandhal Bhutiya on 5/12/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "ExploreVC.h"
#import "ExploreCustomCell.h"
#import "HomeVC.h"

@interface ExploreVC ()
{
    NSInteger nextPage;
    NSArray *arrExploreImgData;
    NSArray *arrTitleData;
    NSArray *arrIconImgData;

}
@end

@implementation ExploreVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    arrExploreImgData = [[NSArray alloc]initWithObjects:@"staff_picks",@"explore",@"around_me",nil];
    
    arrTitleData = [[NSArray alloc] initWithObjects:@"Staff Picks",@"Explore",@"Around Me", nil];
    
    arrIconImgData =[[NSArray alloc]initWithObjects:@"icn_staff_picks",@"icn_explore",@"icn_around_me",nil];;
    
    
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
    
    _tableExplore.delegate = self;
    _tableExplore.dataSource = self;
    [_tableExplore reloadData];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
    
    nextPage=0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Tableview delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(iPhone4)
//    {
//        return 122;
//        
//    }
//    else if(iPhone5)
//    {
//        return 151.33;
//        
//    }else if(iPhone6)
//    {
//        return 184.33;
//    }else if (iPhone6Plus)
//    {
//        return 207.33;

    //    }else
//        return UITableViewAutomaticDimension;
    return 241;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID =  @"ExploreCustomCell";
    ExploreCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ExploreCustomCell" bundle:nil] forCellReuseIdentifier:cellID];
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    
    cell.imgView.image = [UIImage imageNamed:[arrExploreImgData objectAtIndex:indexPath.row]];
    cell.lblTitle.text = [arrTitleData objectAtIndex:indexPath.row];
    cell.imgIconRoundedView.image = [UIImage imageNamed:[arrIconImgData objectAtIndex:indexPath.row]];
    
    
    
    return cell ;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeVC *home = [STORYBOARD instantiateViewControllerWithIdentifier:@"HomeVC"];

    if (indexPath.row == 0)
    {
        home.strMainCategory = @"staff_picks";

    }else if(indexPath.row == 1)
    {
        home.strMainCategory = @"explore";

    }else if (indexPath.row ==2)
    {
        home.strMainCategory = APIAROUNDME;
    }
    [self.navigationController pushViewController:home animated:NO];
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
