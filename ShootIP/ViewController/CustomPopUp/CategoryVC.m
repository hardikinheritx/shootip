//
//  CategoryVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 2/10/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "CategoryVC.h"

@interface CategoryVC ()
{
    NSMutableArray *arrCategoryList;
}

@end

@implementation CategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableDictionary *dictCategoryListing;
    viewPopUp.hidden = YES;
    dictCategoryListing=[[NSMutableDictionary alloc] init];
    [dictCategoryListing setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictCategoryListing setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFCATEGORY method:@"POST" data:dictCategoryListing withImages:nil withVideo:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCategoryList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =  @"CategoryTableViewCell";
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"CategoryTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor=[UIColor colorWithRed:60.0/255.0f green:60.0/255.0f blue:60.0/255.0f alpha:1.0];
    }
    else{
        cell.contentView.backgroundColor=[UIColor colorWithRed:40.0/255.0f green:40.0/255.0f blue:40.0/255.0f alpha:1.0];
    }
    
    cell.lblCategoryName.text=[[[arrCategoryList objectAtIndex:indexPath.row] objectForKey:@"category_name"] capitalizedString];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getDataFromCategory:)])
    {
        [self.delegate getDataFromCategory:[arrCategoryList objectAtIndex:indexPath.row]];
    }

    [self removeViewFromParent];
}

//when download failed of Post in Home VC
-(void)downloadFailed{
    
    [self.delegate downloadFailedWithCategory];
}

-(void)removeViewFromParent
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - WebService

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APILISTOFCATEGORY])
        {
            arrCategoryList=[[dictData objectForKey:@"data"] objectForKey:@"categories"];
            if (arrCategoryList > 0) {
                viewPopUp.hidden = NO;
            }
            [tblCategoryListing reloadData];
            [SVProgressHUD dismiss];
        }
    }
    else
    {
        if([reqURL myContainsString:APICREATEALBUM])
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


- (void)didReceiveMemoryWarning {
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

- (IBAction)actionCloseCategoryListing:(id)sender
{
    [self removeViewFromParent];
}
@end
