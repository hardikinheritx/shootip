//
//  AlbumSelectionVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/28/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "AlbumSelectionVC.h"
#import "ExistingAlbumListVC.h"
#import "CreateNewAlbumVC.h"
#import "AlbumList.h"

@interface AlbumSelectionVC ()
{
    NSMutableDictionary *dictCreateAlbum;
    NSMutableArray *arrAlbumList;
}

@end

@implementation AlbumSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [viewAddToAlbum setHidden:NO];
    [viewExistingAlbumList setHidden:YES];
    [viewCreateAlbum setHidden:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
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
-(void)removeViewFromParent
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
- (IBAction)actionCloseAlbumSelection:(id)sender
{
//    [self.view removeFromSuperview];
    [self removeViewFromParent];
    
    
}

- (IBAction)actionAddToExisting:(id)sender
{
    NSMutableDictionary *dictAlbumListing;

    dictAlbumListing=[[NSMutableDictionary alloc] init];
    [dictAlbumListing setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictAlbumListing setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictAlbumListing setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:@"other_user_id"];
    [dictAlbumListing setObject:@"0" forKey:KEYPAGEINDEX];

    
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFALBUM method:@"POST" data:dictAlbumListing withImages:nil withVideo:nil];
}

- (IBAction)actionCreateNewAlbum:(id)sender
{
    [viewAddToAlbum setHidden:YES];
    [viewExistingAlbumList setHidden:YES];
    [viewCreateAlbum setHidden:NO];
    [txtAlbumName becomeFirstResponder];
}

- (IBAction)actionOk:(id)sender
{
    if(txtAlbumName.text.length==0)
    {
        [Alerts showAlertWithMessage:@"Please enter album name." withBlock:^(NSInteger buttonIndex) {
            
            
        } andButtons:@"OK", nil];
    }
    else
    {
        [self removeViewFromParent];
        [txtAlbumName resignFirstResponder];
        if (iPhone4 || iPhone5)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;
            }];
        }
        
        dictCreateAlbum=[[NSMutableDictionary alloc] init];
        [dictCreateAlbum setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictCreateAlbum setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictCreateAlbum setObject:txtAlbumName.text forKey:@"album_title"];
        [dictCreateAlbum setObject:@"" forKey:@"album_image"];
        
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APICREATEALBUM method:@"POST" data:dictCreateAlbum withImages:nil withVideo:nil];
        
    }

}

- (IBAction)actionCloseExistingAlbumList:(id)sender
{
    [viewAddToAlbum setHidden:YES];
    [viewExistingAlbumList setHidden:NO];
    [self removeViewFromParent];
}

#pragma mark - Textfield Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==txtAlbumName)
    {
        if (iPhone4 || iPhone5)
        {
            CGRect frame = viewCreateAlbum.frame;
            frame.origin.y = -55;
            
            [UIView animateWithDuration:0.3 animations:^{
                viewCreateAlbum.frame = frame;
            }];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==txtAlbumName)
    {
        [txtAlbumName resignFirstResponder];
        if (iPhone4 || iPhone5)
        {
            CGRect frame = viewCreateAlbum.frame;
            frame.origin.y = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                viewCreateAlbum.frame = frame;
            }];
        }
    }
    
    return YES;
}


#pragma mark - Table Datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAlbumList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =  @"AlbumList";
    AlbumList *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"AlbumList" bundle:nil] forCellReuseIdentifier:cellID];
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor=[UIColor colorWithRed:60.0/255.0f green:60.0/255.0f blue:60.0/255.0f alpha:1.0];
    }
    else{
        cell.contentView.backgroundColor=[UIColor colorWithRed:40.0/255.0f green:40.0/255.0f blue:40.0/255.0f alpha:1.0];
    }
    
    cell.lblAlbumName.text=[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"album_title"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(getDataFromAlbum:)])
    {
        [self.delegate getDataFromAlbum:[arrAlbumList objectAtIndex:indexPath.row]];
    }
    
    if(self.shouldAddVideoToAlbum)
    {
        NSMutableDictionary *dictAddVideo=[[NSMutableDictionary alloc] init];
        [dictAddVideo setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictAddVideo setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictAddVideo setObject:[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:KEYALBUMID] forKey:KEYALBUMID];
        [dictAddVideo setObject:self.strPostId forKey:KEYPOSTID];
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIADDVIDEOTOALBUM method:@"POST" data:dictAddVideo withImages:nil withVideo:nil];
    }
    else
    {
        [self removeViewFromParent];
    }
}

#pragma mark - WebService

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APICREATEALBUM])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(getDataFromAlbum:)])
            {
                [self.delegate getDataFromAlbum:[dictData objectForKey:@"data"]];
            }
            
            if(self.shouldAddVideoToAlbum)
            {
                NSMutableDictionary *dictAddVideo=[[NSMutableDictionary alloc] init];
                [dictAddVideo setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
                [dictAddVideo setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
                [dictAddVideo setObject:[[dictData objectForKey:@"data"] objectForKey:KEYALBUMID] forKey:KEYALBUMID];
                [dictAddVideo setObject:self.strPostId forKey:KEYPOSTID];
                [SVProgressHUD show];
                [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIADDVIDEOTOALBUM method:@"POST" data:dictAddVideo withImages:nil withVideo:nil];
            }
            else
            {
                [viewAddToAlbum setHidden:YES];
            }
        }
        else if ([reqURL myContainsString:APILISTOFALBUM])
        {
            arrAlbumList=[[dictData objectForKey:@"data"] objectForKey:@"albums"];
            [viewAddToAlbum setHidden:YES];
            [viewExistingAlbumList setHidden:NO];
            [viewCreateAlbum setHidden:YES];
            [tblAlbumListing reloadData];
        }
        else if ([reqURL myContainsString:APIADDVIDEOTOALBUM])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];
            [viewAddToAlbum setHidden:YES];
            [self removeViewFromParent];
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            
            if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(reloadTableDataForVideoCount:)])
            {
                [self.videoDelegate reloadTableDataForVideoCount:[dictData objectForKey:@"data"]];
            }
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APICREATEALBUM])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APILISTOFALBUM])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APIADDVIDEOTOALBUM])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            [viewAddToAlbum setHidden:YES];
            [self removeViewFromParent];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}

@end
