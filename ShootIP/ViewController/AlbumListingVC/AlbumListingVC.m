//
//  AlbumListingVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "AlbumListingVC.h"
#import "AlbumCell.h"
#import "PlaceVC.h"
#import "CommentVC.h"

@interface AlbumListingVC ()
{
    NSMutableArray *arrAlbumList;
}

@end

@implementation AlbumListingVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self callAlbumListingWebservice];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Album List Screen"];
    [APPDELEGATE setDropOffScreen:@"Album List Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Webservice -

-(void)callAlbumListingWebservice
{
    NSMutableDictionary *dictAlbumListing;
    
    dictAlbumListing=[[NSMutableDictionary alloc] init];
    [dictAlbumListing setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictAlbumListing setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictAlbumListing setObject:_strOtherUserID forKey:@"other_user_id"];
//
    [dictAlbumListing setObject:@"0" forKey:KEYPAGEINDEX];
    
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFALBUM method:@"POST" data:dictAlbumListing withImages:nil withVideo:nil];
}

#pragma mark - Table Datasource and delegate -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAlbumList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 356;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID =  @"AlbumCell";
    
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"AlbumCell" bundle:nil] forCellReuseIdentifier:cellID];
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    
    cell.imgPostUser.layer.cornerRadius = cell.imgPostUser.frame.size.width / 2;
    cell.imgPostUser.clipsToBounds = YES;
    cell.imgPostUser.layer.borderWidth  = 1.5f;
    cell.imgPostUser.layer.borderColor = [UIColor whiteColor].CGColor;
    
    cell.lblAlbumName.text=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"album_title"]];
    cell.lblAlbumDuration.text=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"total_videos_duration"]];
//    cell.lblPostUserName.text=[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@""];
    cell.lblTotalComment.text=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"total_comments"]];
    cell.lblTotalLike.text=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"total_likes"]];
    cell.lblAlbumPostDate.text=[NSString stringWithFormat:@"%@",[APPDELEGATE UTCtoDeviceTimeZone:[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"created_at"]]];

    [cell.btnLikeAlbum removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    [cell.btnCommentAlbum removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventAllEvents];
    
    [cell.btnCommentAlbum addTarget:self action:@selector(btnCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCommentAlbum setTag:indexPath.row];
    [cell.btnLikeAlbum addTarget:self action:@selector(btnLikeDisLike:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnAlbumName addTarget:self action:@selector(btnAlbumNameClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnLikeAlbum setTag:indexPath.row];
    [cell.btnAlbumName setTag:indexPath.row];
    
    cell.lblPostUserName.text=[NSString stringWithFormat:@"%@",[[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"user_data"] objectForKey:@"username"]];
    NSURLRequest *userProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"user_data"] objectForKey:@"user_image"]]]];
    UIImage *placeholderImage = [UIImage imageNamed:@"user_placeholder_icon"];
    [cell.imgPostUser setupImageViewerWithImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"user_data"] objectForKey:@"user_image"]]]];
    
    [cell.imgPostUser setImageWithURLRequest:userProfileRequest
                           placeholderImage:placeholderImage
                                    success:nil
                                    failure:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"album_thumb_image"]]];
    [cell.imgAlbum setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"logo_placeholder"]
                                       success:nil failure:nil];
    
    NSString *likePost=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexPath.row] objectForKey:@"likebyme"]];
    
    if([likePost isEqualToString:@"1"])
    {
        [cell.btnImgLikeAlbum setSelected:YES];
    }
    else
    {
        [cell.btnImgLikeAlbum setSelected:NO];
    }
    
    return cell;
}

#pragma mark - Custom Method -

-(void)btnAlbumNameClick:(UIButton *)sender
{
    PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
    placeVC.fromWhere=@"Album";
    placeVC.strTitle=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:sender.tag] objectForKey:@"album_title"]];
    placeVC.strOtherUserId=_strOtherUserID;
    placeVC.dictPlaceDetail=[arrAlbumList objectAtIndex:sender.tag];
    [self.navigationController pushViewController:placeVC animated:YES];
}

-(void)btnCommentAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    
    [self performSegueWithIdentifier:@"CommentSegue" sender:[[arrAlbumList objectAtIndex:btn.tag] objectForKey:@"album_id"]];
//    [self performSegueWithIdentifier:@"CommentSegue" sender:nil];
}

-(void)btnLikeDisLike:(UIButton *)sender
{
//    AlbumCell* cell = (AlbumCell*)[[[[[sender superview] superview] superview] superview] superview];
//    cell.btnImgLikeAlbum.selected=!cell.btnImgLikeAlbum.selected;
    
    UIButton *btn=(UIButton *)sender;
//    btn.selected=!btn.selected;
//    [tblAlbumListing reloadData];
    
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrAlbumList objectAtIndex:btn.tag] objectForKey:@"album_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"album" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:sender.tag] objectForKey:@"likebyme"]];
    if([strLike isEqualToString:@"0"])
    {
        [dictLikeDislike setObject:@"like" forKey:@"action"];
    }
    else
    {
        [dictLikeDislike setObject:@"dislike" forKey:@"action"];
    }
    
    //    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILIKEDISLIKEPOSTALBUM method:@"POST" data:dictLikeDislike withImages:nil withVideo:nil];
}

#pragma mark - Action Method -

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APILISTOFALBUM])
        {
            arrAlbumList=[[NSMutableArray alloc] init];
            
            arrAlbumList= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)([[dictData objectForKey:@"data"] objectForKey:@"albums"]), kCFPropertyListMutableContainersAndLeaves));
            [tblAlbumListing reloadData];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];

            NSLog(@"dictData = %@",dictData);
            NSInteger indexOfMatchingDictionary = [arrAlbumList indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
                return [[obj valueForKey:@"album_id"] isEqual:[[dictData objectForKey:@"data"] objectForKey:@"album_id"]
                        ];
            }];
            
            NSMutableDictionary *tempDict=[[arrAlbumList objectAtIndex:indexOfMatchingDictionary] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"is_like"]] forKey:@"likebyme"];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"total_likes"]] forKey:@"total_likes"];
            [arrAlbumList replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
            AlbumCell *cell = (AlbumCell*)[tblAlbumListing cellForRowAtIndexPath:indePath];
            cell.lblTotalLike.text=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexOfMatchingDictionary] objectForKey:@"total_likes"]];
            
            NSString *likePost=[NSString stringWithFormat:@"%@",[[arrAlbumList objectAtIndex:indexOfMatchingDictionary] objectForKey:@"likebyme"]];
            
            if([likePost isEqualToString:@"1"])
            {
                [cell.btnImgLikeAlbum setSelected:YES];
            }
            else
            {
                [cell.btnImgLikeAlbum setSelected:NO];
            }
        }

        [SVProgressHUD dismiss];
    }
    else
    {
        if ([reqURL myContainsString:APILISTOFALBUM])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CommentSegue"])
    {
        CommentVC *objComment = segue.destinationViewController;
        objComment.isForPost=NO;
        objComment.strPostId=sender;
        
    }
}
#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
