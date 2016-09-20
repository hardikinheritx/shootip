//
//  PlaceVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "PlaceVC.h"
#import "VideoPostCell.h"
#import "NewPostVC.h"
#import "MapVC.h"
#import "AlbumSelectionVC.h"
#import "CommentVC.h"
#import "TwitterVideoUpload.h"
#import "CBStoreHouseRefreshControl.h"
#import "ShareAndReportVC.h"
#import "OtherUserProfileVC.h"

@interface PlaceVC ()
{
    NSMutableArray *arrPlaceList;
    AVQueuePlayer *queuePlayer;
    NSString *strCategoryName;
    NSString *strType;
    NSInteger totalPage;
    NSInteger nextPage;
    NSInteger selectedPlayIndex;
    AVPlayer *avPlayer;
    AVPlayerItem *playerItem;
    AVPlayerLayer *layer;
    UIRefreshControl *refreshControl;
    BOOL isRefresh;
    
    NSMutableArray *arrURl;// kandhal
    AVPlayerViewController *playerViewController;
    PlayAllOverlayVC *objPlayAllOverlayVC;
    int CountVideo;
    int playingCount;
    int playedCount;
    int maxPlayedElement;
    int  resumeVideoCount;
    BOOL IsPlayingAll;
    BOOL iSOvelayViewShow;
    
    BOOL isAllVideoDownload;
    
    //UIView *blurView;
}

@end

@implementation PlaceVC
@synthesize dictPlaceDetail;

#pragma mark - View LifeCycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    //  self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:tblPlaceList target:self refreshAction:@selector(refreshTriggered:) plist:@"ShootipRefresh" color:[UIColor whiteColor] lineWidth:1.5 dropHeight:60 scale:.7 horizontalRandomness:500 reverseLoadingAnimation:NO internalAnimationFactor:0.7];
    isAllVideoDownload = FALSE;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTriggered:) forControlEvents:UIControlEventValueChanged];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:0.337 green:0.659 blue:0.467 alpha:1.000];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..." attributes:attrsDictionary];
    refreshControl.attributedTitle = attributedTitle;
    [tblPlaceList addSubview:refreshControl];
    
    
    arrPlaceList=[[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UpdateCommentCount:)
                                                 name:UPDATECOMMENTCOUNTNOTIFICATION object:nil];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    
    arrPlaceList=[[NSMutableArray alloc] init];
    
    strType=@"Most recent";
    strCategoryName=@"all";
    nextPage=0;
    messageLabel = [[UILabel alloc] init];
    tblPlaceList.hidden = YES;

    if([self.fromWhere isEqualToString:@"Profile"])
    {
        [viewSortPlayFunction setHidden:YES];
        lblNavTitle.text=[dictPlaceDetail objectForKey:@"place"];
        btnFollowPlace.hidden=YES;
        [viewSortPlayFunctionHeightContraint setConstant:0];
        [self.view layoutIfNeeded];
    }
    else if([self.fromWhere isEqualToString:@"Top Destination"])
    {
        [viewSortPlayFunction setHidden:NO];
        lblNavTitle.text=self.strTitle;
        btnFollowPlace.hidden=YES;
        //        [viewSortPlayFunctionHeightContraint setConstant:0];
        [self.view layoutIfNeeded];
        [self callListOfPostByCityWebService];
    }
    else if([self.fromWhere isEqualToString:@"Album"])
    {
        [viewSortPlayFunction setHidden:NO];
        lblNavTitle.text=self.strTitle;
        //        btnFollowPlace.hidden=NO;
        [btnFollowPlace setImage:[UIImage imageNamed:@"icn_delete_post"] forState:UIControlStateNormal];
        [btnFollowPlace setTag:2];//TAG 2 assigned for delete album
        
        //        if (![_strOtherUserId isEqualToString:[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:[USERDEFAULTS objectForKey:KEYUSERID]]]])
        if (![[NSString stringWithFormat:@"%@",_strOtherUserId] isEqualToString:[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]]])
        {
            btnFollowPlace.hidden=YES;
        }
        else {
            btnFollowPlace.hidden=NO;
        }
        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        
    }
    else if([self.fromWhere isEqualToString:@"AlbumSearch"])
    {
        [viewSortPlayFunction setHidden:NO];
        lblNavTitle.text=self.strTitle;
        //        btnFollowPlace.hidden=NO;
        [btnFollowPlace setImage:[UIImage imageNamed:@"icn_delete_post"] forState:UIControlStateNormal];
        [btnFollowPlace setTag:2];//TAG 2 assigned for delete album
        
        if (![[NSString stringWithFormat:@"%@",_strOtherUserId] isEqualToString:[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]]])
        {
            btnFollowPlace.hidden=YES;
        }
        else {
            btnFollowPlace.hidden=NO;
        }
        [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        
    }
    else if([self.fromWhere isEqualToString:@"HashTag"])
    {
        [viewSortPlayFunction setHidden:YES];
        lblNavTitle.text=self.strTitle;
        btnFollowPlace.hidden=YES;
        [viewSortPlayFunctionHeightContraint setConstant:0];
        [self.view layoutIfNeeded];
        [self callListOfPostByHashTagWebservice];
    }
    else
    {
        [viewSortPlayFunction setHidden:NO];
        lblNavTitle.text=[dictPlaceDetail objectForKey:@"place"];
        btnFollowPlace.hidden=NO;
        [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
    }
    [tblPlaceList reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // _player is an instance of AVPlayer
    IsPlayingAll = NO;
    [ServerConnection sharedConnection].isPlaying = IsPlayingAll;
    if ([avPlayer respondsToSelector:@selector(setAllowsExternalPlayback:)]) {
        // iOS 6+
        avPlayer.allowsExternalPlayback = NO;
        [avPlayer pause];
        [layer removeFromSuperlayer];
        @try
        {
            [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
            [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
            [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
            
            
        }
        @catch (NSException * __unused exception)
        {
            
            
        }
        @finally {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
            
        }
        
        playerItem=nil;
        avPlayer=nil;
    }
    
    [queuePlayer removeAllItems];
    [self finishRefreshControl];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self finishRefreshControl];
}

#pragma mark - Notifying refresh control of scrolling -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.storeHouseRefreshControl scrollViewDidScroll];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self.storeHouseRefreshControl scrollViewDidEndDragging];
//}

#pragma mark - Listening for the user to trigger a refresh -

- (void)refreshTriggered:(id)sender
{
    [self removeAvPlayerReference];
    avPlayer=nil;
    isRefresh=YES;
    
    nextPage=0;

    if([self.fromWhere isEqualToString:@"Profile"])
    {
        
    }
    else if([self.fromWhere isEqualToString:@"Top Destination"])
    {
        [self callListOfPostByCityWebService];
        
    }
    else if([self.fromWhere isEqualToString:@"Album"])
    {
        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        
    }
    else if([self.fromWhere isEqualToString:@"AlbumSearch"])
    {
        //[self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        
    }
    else if([self.fromWhere isEqualToString:@"HashTag"])
    {
        [self callListOfPostByHashTagWebservice];
        
    }
    else
    {
        [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
    }
    
//    if([self.fromWhere isEqualToString:@"Top Destination"])
//    {
//        [self callListOfPostByCityWebService];
//    }
//    else
//    {
//        nextPage=0;
//        [self callListOfPostWebService:strCategoryName type:strType pageIndex:0];
//    }
    
    //  [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:30.0 inModes:@[NSRunLoopCommonModes]]; old code 
    
    
    
    
    //    [arrPlaceList removeAllObjects];
    //    [tblHomePost reloadData];
    
    
    
}

- (void)finishRefreshControl
{
    [refreshControl endRefreshing];
    
    [self.storeHouseRefreshControl finishingLoading];
}
- (void)reachabilityChanged:(NSNotification *)notification
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        NSLog(@"Reachable");
        [self callListOfPostWebService:strCategoryName type:strType pageIndex:0];
    } else {
        NSLog(@"Unreachable");
    }
    
}
-(void)callListOfPostWebService:(NSString*)category type:(NSString*)type pageIndex:(NSInteger)index
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO){
        [self finishRefreshControl];
        return;
    }
    
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:KEYPAGEINDEX];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"place"] forKey:@"place"];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"city"] forKey:@"city"];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"country"] forKey:@"country"];
    [dictListOfPost setObject:type forKey:@"type"];
    [dictListOfPost setObject:category forKey:@"category"];
    if(IsPlayingAll == NO){
        [SVProgressHUD show];
    }

    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOSTBYPLACE method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}

-(void)callListOfPostByHashTagWebservice
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO)
    {
        [self finishRefreshControl];
        return;
    }
    
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"hash_tag"] forKey:@"hashtag"];
    [dictListOfPost setObject:strType forKey:@"type"];
    [dictListOfPost setObject:strCategoryName forKey:@"category"];
    [dictListOfPost setObject:@"0" forKey:KEYPAGEINDEX];
    if(IsPlayingAll == NO){
        [SVProgressHUD show];
    }

    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOSTBYHASHTAG method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}


-(void)callListOfPostByCityWebService
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO){
        [self finishRefreshControl];
        return;
    }
    
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)nextPage] forKey:KEYPAGEINDEX];
    [dictListOfPost setObject:strCategoryName forKey:@"category"];
    [dictListOfPost setObject:strType forKey:@"type"];

    [dictListOfPost setObject:self.strTitle forKey:@"city"];
    if(IsPlayingAll == NO){
        [SVProgressHUD show];
    }
    
    //[SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOSTBYCITY method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}
-(void)callSearchAlbumVideoWebService:(NSString*)category type:(NSString*)type pageIndex:(NSInteger)index
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO){
        [self finishRefreshControl];
        return;
    }
    
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"album_id"] forKey:@"album_id"];
    
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:KEYPAGEINDEX];
    [dictListOfPost setObject:type forKey:@"type"];
    if(IsPlayingAll == NO){
        [SVProgressHUD show];
    }
    
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFVIDEOBYSEARCHALBUM method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}
-(void)callAlbumVideoWebService:(NSString*)category type:(NSString*)type pageIndex:(NSInteger)index
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO){
        [self finishRefreshControl];
        return;
    }
    
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[dictPlaceDetail objectForKey:@"album_id"] forKey:@"album_id"];
    if ([_strOtherUserId length]>0) {
        [dictListOfPost setObject:_strOtherUserId forKey:@"other_user_id"];
    }
    else{
        [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:@"other_user_id"];
        
    }
    [dictListOfPost setObject:category forKey:@"category"];
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:KEYPAGEINDEX];
    [dictListOfPost setObject:type forKey:@"type"];
    if(IsPlayingAll == NO){
        [SVProgressHUD show];
    }
    
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFALBUMBYVIDEO method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
}



#pragma mark - Table Datasource and delegate -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPlaceList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([arrPlaceList count]!=0)
    {
        tblPlaceList.hidden = NO;
        messageLabel.text=@"";
        viewSortPopUp.hidden = NO;
        return 1;
    }
    else
    {
        viewSortPopUp.hidden = NO;
        messageLabel.text = @"No post found.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //    return 393;
    return 443;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([arrPlaceList count]) {
        static NSString *cellID =  @"VideoPostCell";
        VideoPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"VideoPostCell" bundle:nil] forCellReuseIdentifier:cellID];
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        }
        
        [cell.btnComment addTarget:self action:@selector(btnCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnTitle addTarget:self action:@selector(btnTitleAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMap addTarget:self action:@selector(btnMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLikeDisLike addTarget:self action:@selector(btnLikeDisLikeAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnAddVideoToAlbum addTarget:self action:@selector(btnAddVideoToAlbumAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnPlayVideo addTarget:self action:@selector(btnPlayVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnPlayVideo setHidden:NO];
        
        NSDictionary *dictPost=[arrPlaceList objectAtIndex:indexPath.row];
        [cell ConfigureCell:[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"rating"]] postDict:dictPost];
        [cell.btnReportOrEdit addTarget:self action:@selector(btnReportOrEditAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tapRecognizerUsername = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userNameTapped:)];
        cell.lblUserName.userInteractionEnabled=YES;
        [cell.lblUserName addGestureRecognizer:tapRecognizerUsername];
        
        
        cell.lblUserName.tag=cell.btnReportOrEdit.tag=cell.btnComment.tag=cell.btnTitle.tag=cell.btnLikeDisLike.tag=cell.btnAddVideoToAlbum.tag=cell.btnPlayVideo.tag=cell.btnMap.tag=indexPath.row;
        
        return cell;
    }
    else{
        static NSString *cellID =  @"VideoPostCell";
        
        VideoPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"VideoPostCell" bundle:nil] forCellReuseIdentifier:cellID];
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        }
        
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == arrPlaceList.count && arrPlaceList.count > 1)
    {
        if(nextPage==0)
        {
            
        }
        else
        {
            /*if([self.fromWhere isEqualToString:@"Top Destination"])
                [self callListOfPostByCityWebService];
            else
                [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];*/
            
            //added code by Paras - 2016/08/03
            
            if([self.fromWhere isEqualToString:@"Profile"])
            {
                
            }
            else if([self.fromWhere isEqualToString:@"Top Destination"])
            {
                [self callListOfPostByCityWebService];
                
            }
            else if([self.fromWhere isEqualToString:@"Album"])
            {
                [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                
            }
            else if([self.fromWhere isEqualToString:@"AlbumSearch"])
            {
                //[self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                
            }
            else if([self.fromWhere isEqualToString:@"HashTag"])
            {
                [self callListOfPostByHashTagWebservice];
                
            }
            else
            {
                [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
            }
             
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        if(selectedPlayIndex==indexPath.row)
        {
            if ([arrPlaceList count]>0) {
                VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indexPath];
                cell.btnPlayVideo.hidden=NO;
                [layer removeFromSuperlayer];
                [avPlayer pause];
                @try
                {
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
                    
                }
                @catch (NSException * __unused exception)
                {
                    
                }
                @finally {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
                    
                }
                playerItem=nil;
            }
        }
    }
}

#pragma mark - ScrollView Delegate Method -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.storeHouseRefreshControl scrollViewDidEndDragging];
    
    if(!decelerate)
    {
        [self checkWhichVideoToEnable];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    [self checkWhichVideoToEnable];
}

#pragma mark - Video Play Method -
- (void)removeObserverForStatusPlay
{
    @try {
        
        [avPlayer removeObserver:self forKeyPath:@"status"];
    } @catch(id anException) {
        NSLog(@"excepcion remove observer == %@. Remove previously or never added observer.",anException);
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}
-(void)checkWhichVideoToEnable
{
    for(VideoPostCell *cell in [tblPlaceList visibleCells])
    {
        if([cell isKindOfClass:[VideoPostCell class]])
        {
            NSIndexPath *indexPath = [tblPlaceList indexPathForCell:cell];
            CGRect cellRect = [tblPlaceList rectForRowAtIndexPath:indexPath];
            UIView *superview = tblPlaceList.superview;
            
            CGRect convertedRect=[tblPlaceList convertRect:cellRect toView:superview];
            CGRect intersect = CGRectIntersection(tblPlaceList.frame, convertedRect);
            float visibleHeight = CGRectGetHeight(intersect);
            
            if(visibleHeight>443*0.6) // only if 60% of the cell is visible
            {
                @try
                {
                    NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
                    
                    if(!(selectedPlayIndex==indePath.row))
                    {
                        VideoPostCell *cell1 = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath1];
                        cell1.btnPlayVideo.hidden=NO;
                        cell1.videoActivityIndicator.hidden=YES;
                        [self removeAvPlayerReference];
                        
                        VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath];
                        cell.btnPlayVideo.hidden=YES;
                        if ([APPDELEGATE checkIfVideoExists:[[arrPlaceList objectAtIndex:indexPath.row] objectForKey:@"post_id"]])
                        {
                            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                            
                            NSString *savedVideoPath = [NSString stringWithFormat:@"%@/%@.mov",paths1,[[arrPlaceList objectAtIndex:indexPath.row] objectForKey:@"post_id"]];
                            playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:savedVideoPath]];
                        }
                        else
                        {
                            playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrPlaceList objectAtIndex:indexPath.row] objectForKey:@"video"]]];
                            
                        }
                        
                        //                        playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrPlaceList objectAtIndex:indexPath.row] objectForKey:@"video"]]];
                        
                        if(!avPlayer)
                        {
                            
                            avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
                        }
                        else
                        {
                            //   [self removeObserverForStatusPlay];
                            
                            [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
                        }
                        
                        layer = [[AVPlayerLayer alloc]  init];
                        layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
                        [layer layoutIfNeeded];
                        [cell.viewVideoPreview.layer addSublayer:layer];
                        [avPlayer setVolume:7.0f];
                        
                        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
                        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
                        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
                        
                        NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
                        [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                object:nil // any object can send
                                                 queue:nil // the queue of the sending
                                            usingBlock:^(NSNotification *note) {
                                                cell.btnPlayVideo.hidden=NO;
                                                [layer removeFromSuperlayer];
                                            }];
                        
                        if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
                        {
                            [avPlayer play];
                        }
                        else if (avPlayer.currentItem.status == AVPlayerStatusFailed) {
                            // something went wrong. player.error should contain some information
                            //   NSLog(@"not fineee");
                            //  NSLog(@"Error fial is %@",avPlayer.error);
                        }
                        else
                        {
                            // NSLog(@"Not ready");
                            [cell.videoActivityIndicator setHidden:NO];
                        }
                        selectedPlayIndex=indexPath.row;
                    }
                }
                @catch (NSException * __unused exception)
                {
                    
                }
            }
            else
            {
                
            }
        }
    }
}
#pragma mark - Category delegate method -
- (IBAction)actionCategoryPopUp:(id)sender
{
    CategoryVC *objCategorySelection = [STORYBOARD instantiateViewControllerWithIdentifier:@"CategoryVC"];
    objCategorySelection.delegate=self;
    [[APPDELEGATE window].rootViewController addChildViewController:objCategorySelection];
    objCategorySelection.view.alpha = 0.0;
    [[APPDELEGATE window].rootViewController.view addSubview:objCategorySelection.view];
    [UIView animateWithDuration:0.5 animations:^{
        objCategorySelection.view.alpha = 1.0;
    }];
    
}
- (void)getDataFromCategory:(NSDictionary*)getCategoryDict
{
    //    NSLog(@"%@",getCategoryDict);
    
    //    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    //    [dictListOfPost setObject:@"0" forKey:KEYPAGEINDEX];
    //    [dictListOfPost setObject:@"all" forKey:@"type"];
    
    strCategoryName=[getCategoryDict objectForKey:@"category_name"];
//    strType=@"Most recent";
//    strCategoryName=@"all";
    //    [dictListOfPost setObject:strCategoryName forKey:@"category"];
    arrPlaceList=[[NSMutableArray alloc] init];
    tblPlaceList.hidden = YES;

    [tblPlaceList reloadData];
    nextPage=0;
    //    [SVProgressHUD show];
    //    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOST method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
    if([self.fromWhere isEqualToString:@"Profile"])
    {
        
    }
    else if([self.fromWhere isEqualToString:@"Top Destination"])
        [self callListOfPostByCityWebService];
    else if([self.fromWhere isEqualToString:@"Album"])
        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
    else if([self.fromWhere isEqualToString:@"AlbumSearch"])
        //[self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
        [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
    else if([self.fromWhere isEqualToString:@"HashTag"])
        [self callListOfPostByHashTagWebservice];
    else
        [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];

}

-(void)reloadTableDataForVideoCount:(NSMutableDictionary*)getVideoDetails;
{
    NSInteger indexOfMatchingDictionary = [arrPlaceList indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
        return [[obj valueForKey:@"post_id"] isEqual:[getVideoDetails objectForKey:@"post_id"]
                ];
    }];
    NSMutableDictionary *tempDict=[[arrPlaceList objectAtIndex:indexOfMatchingDictionary] mutableCopy];
    [tempDict setObject:[NSString stringWithFormat:@"%@",[getVideoDetails objectForKey:@"video_added_count"]] forKey:@"video_added_count"];
    [arrPlaceList replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
    
    NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
    VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath];
    
    cell.lblNoOfVideoShared.text=[NSString stringWithFormat:@"%@",[[arrPlaceList objectAtIndex:indexOfMatchingDictionary] objectForKey:@"video_added_count"]];
    
    //    [tblPlaceList beginUpdates];
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
    //    [tblPlaceList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //    [tblPlaceList endUpdates];
}


#pragma mark - Custom Action -

-(void)removeAvPlayerReference
{
    [avPlayer pause];
    [layer removeFromSuperlayer];
    @try
    {
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    }
    @catch (NSException * __unused exception)
    {
        NSLog(@"Exception %@",exception);
        
    }
    @finally {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
        
    }
    playerItem=nil;
    
}

- (void)userNameTapped:(UITapGestureRecognizer*)sender
{
    NSDictionary *dict=[arrPlaceList objectAtIndex:sender.view.tag];
    
    if ([[NSString stringWithFormat:@"%@",[[dict objectForKey:@"user_data"] objectForKey:@"user_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]]])
    {
        [APPDELEGATE myTab].selectedIndex = 4;
        if (iPhone6)
            [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_5~667h"]];
        else
            [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_5"]];
    }
    else{
        [self performSegueWithIdentifier:@"otherUserProfileSegue" sender:[[dict objectForKey:@"user_data"] objectForKey:@"user_id"]];
    }
}

-(void)btnAddVideoToAlbumAction:(UIButton *)sender
{
    AlbumSelectionVC *objAlbumSelection = [STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumSelectionVC"];
    [[APPDELEGATE window].rootViewController addChildViewController:objAlbumSelection];
    objAlbumSelection.view.alpha = 0.0;
    [[APPDELEGATE window].rootViewController.view addSubview:objAlbumSelection.view];
    [UIView animateWithDuration:0.5 animations:^{
        objAlbumSelection.view.alpha = 1.0;
    }];
    UIButton *btn=(UIButton*)sender;
    objAlbumSelection.strPostId=[[arrPlaceList objectAtIndex:btn.tag] objectForKey:KEYPOSTID];
    objAlbumSelection.shouldAddVideoToAlbum=YES;
    objAlbumSelection.shouldAddVideoToAlbum=YES;
    objAlbumSelection.videoDelegate=self;
}

-(void)btnTitleAction:(UIButton *)sender
{
}

-(void)btnLikeDisLikeAction:(UIButton *)sender
{
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"likebyme"]];
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

-(void)btnMapAction:(UIButton *)sender
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"latitude"] forKey:@"latitude"];
    [dict setObject:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"longitude"] forKey:@"longitude"];
    [dict setObject:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"place"] forKey:@"place"];
    
    MapVC *mapVC = (MapVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"MapVC"];
    mapVC.dictMap=dict;
    [self.navigationController pushViewController:mapVC animated:YES];
}

-(void)btnReportOrEditAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    NSString *strUserId = [NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]];
    NSString *strPostUserId =[NSString stringWithFormat:@"%@",[[[arrPlaceList objectAtIndex:btn.tag] objectForKey:@"user_data"] objectForKey:KEYUSERID]];
    if([strUserId isEqualToString:strPostUserId])
    {
        [self performSegueWithIdentifier:@"editPostSegue" sender:[arrPlaceList objectAtIndex:sender.tag]];
    }
    else
    {
        //        viewShareAndReportPopUp.frame=CGRectMake(0, 0, [APPDELEGATE window].frame.size.width,[APPDELEGATE window].frame.size.height);
        //        [viewShareAndReportPopUp layoutIfNeeded];
        //
        //        [[APPDELEGATE window] addSubview:viewShareAndReportPopUp];
        //        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:viewShareAndReportPopUp];
        //
        //        viewInnerShareAndReportPopUp.tag=btn.tag;
        //        viewInnerShareAndReportPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
        //
        //        [UIView animateWithDuration:0.4 animations:^{
        //
        //            viewInnerShareAndReportPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        //        }];
        
        ShareAndReportVC *objShare = [STORYBOARD instantiateViewControllerWithIdentifier:@"ShareAndReportVC"];
        [[APPDELEGATE window].rootViewController addChildViewController:objShare];
        objShare.view.alpha = 0.0;
        [[APPDELEGATE window].rootViewController.view addSubview:objShare.view];
        [UIView animateWithDuration:0.5 animations:^{
            objShare.view.alpha = 1.0;
        }];
        objShare.getPostData=[arrPlaceList objectAtIndex:btn.tag];
    }
}

-(void)btnCommentAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    
    [self performSegueWithIdentifier:@"CommentSegue" sender:[[arrPlaceList objectAtIndex:btn.tag] objectForKey:@"post_id"]];
}
-(void)btnPlayVideoAction:(UIButton *)sender
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == YES)
    {
        @try
        {
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
            VideoPostCell *cell1 = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath1];
            cell1.btnPlayVideo.hidden=NO;
            cell1.videoActivityIndicator.hidden=YES;
            [self removeAvPlayerReference];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:sender.tag inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath];
            cell.btnPlayVideo.hidden=YES;
            //    avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"video"]]];
            
            //            if (playerItem != nil)
            //                [playerItem removeObserver:self forKeyPath:@"status"];
            
            if ([APPDELEGATE checkIfVideoExists:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"post_id"]])
            {
                NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *savedVideoPath = [NSString stringWithFormat:@"%@/%@.mov",paths1,[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"post_id"]];
                playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:savedVideoPath]];
            }
            else
            {
                playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"video"]]];
                
            }
            
            
            if(!avPlayer)
            {
                
                
                avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
            }
            else
            {
                //                [self removeObserverForStatusPlay];
                
                [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
            }
            
            
            
            //    [avPlayer replaceCurrentItemWithPlayerItem:[playerItem playerItemWithURL:[NSURL fileURLWithPath:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"video"]]]];
            
            layer = [[AVPlayerLayer alloc]  init];
            layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            layer.frame = cell.viewVideoPreview.bounds;
            [layer layoutIfNeeded];
            [cell.viewVideoPreview.layer addSublayer:layer];
            [avPlayer setVolume:7.0f];
            
            [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            [avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
            [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
            
            NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
            [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                    object:nil // any object can send
                                     queue:nil // the queue of the sending
                                usingBlock:^(NSNotification *note) {
                                    cell.btnPlayVideo.hidden=NO;
                                    [layer removeFromSuperlayer];
                                }];
            
            if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
            {
                [avPlayer play];
            }
            else if (avPlayer.currentItem.status == AVPlayerStatusFailed) {
                // something went wrong. player.error should contain some information
                //   NSLog(@"not fineee");
                //NSLog(@"Error fial is %@",avPlayer.error);
            }
            else
            {
                //   NSLog(@"Not ready");
                [cell.videoActivityIndicator setHidden:NO];
            }
            selectedPlayIndex=sender.tag;
        }
        @catch (NSException * __unused exception)
        {
            
        }
    }
    else
    {
        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Oops internet not availble. Please turn on internet."];
    }
    
}
//-(void)btnPlayVideoAction:(UIButton *)sender
//{
//
//    NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
//    VideoPostCell *cell1 = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath1];
//    cell1.btnPlayVideo.hidden=NO;
//    [avPlayer pause];
////    @try
////    {
////        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
////        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
////        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
////
////        [[NSNotificationCenter defaultCenter] removeObserver:self];
////    }
////    @catch (NSException * __unused exception)
////    {
////                NSLog(@"Exception %@",exception);
////
////    }
////    playerItem=nil;
//
//    if (playerItem != nil)
//        [playerItem removeObserver:self forKeyPath:@"status"];
//
//    [layer removeFromSuperlayer];
//
//    NSIndexPath *indePath=[NSIndexPath indexPathForRow:sender.tag inSection:0];
//    VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath];
//    cell.btnPlayVideo.hidden=YES;
//
//    playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrPlaceList objectAtIndex:sender.tag] objectForKey:@"video"]]];
//
//    if(!avPlayer)
//    {
//        avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
//    }
//    else
//    {
//        [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
//    }
//
//    layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
//    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    layer.frame = cell.viewVideoPreview.bounds;
//    [layer layoutIfNeeded];
//    [cell.viewVideoPreview.layer addSublayer:layer];
//    [avPlayer setVolume:7.0f];
//
//    [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    [avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
//    [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
//
//    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
//    [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
//                            object:nil // any object can send
//                             queue:nil // the queue of the sending
//                        usingBlock:^(NSNotification *note) {
//                            // holding a pointer to avPlayer to reuse it
//                            cell.btnPlayVideo.hidden=NO;
//                            [layer removeFromSuperlayer];
//                        }];
//
//    if (avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
//    {
//        [avPlayer play];
//    }
//    else if (avPlayer.currentItem.status == AVPlayerStatusFailed) {
//        // something went wrong. player.error should contain some information
//        NSLog(@"not fineee");
//        NSLog(@"Error fial is %@",avPlayer.error);
//    }
//    else
//    {
//        NSLog(@"Not ready");
//        [cell.videoActivityIndicator setHidden:NO];
//    }
//    selectedPlayIndex=sender.tag;
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (!avPlayer)
    {
        NSLog(@"not avplayer");
        return;
    }
    
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (avPlayer.currentItem.playbackBufferEmpty) {
            //Your code here
            NSLog(@"Empty");
        }
    }
    
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (avPlayer.currentItem.playbackLikelyToKeepUp)
        {
            //Your code here
            [avPlayer play];
            
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath1];
            [cell.videoActivityIndicator setHidden:YES];
            NSLog(@"Alive");
        }
    }
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferFull"])
    {
        if (avPlayer.currentItem.playbackBufferFull)
        {
            //Your code here
            NSLog(@"Buffer Full");
        }
    }
}



#pragma mark - Navigation -
- (void)UpdateCommentCount:(NSNotification *)note {
    //    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
    //        CommentVC *objDetail = segue.sourceViewController;
    
    NSDictionary *userInfo = note.userInfo;
    arrPlaceList= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrPlaceList), kCFPropertyListMutableContainersAndLeaves));
    
    [arrPlaceList enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        NSLog(@"post id-%@",[[obj valueForKey:@"post_id"] stringValue]);
        
        //            NSLog(@"%@",objDetail.strPostId);
        NSString *str1=[NSString stringWithFormat:@"%@",[obj valueForKey:KEYPOSTID]];
        NSString *str2=[NSString stringWithFormat:@"%@",[userInfo objectForKey:KEYPOSTID]];
        
        if([str1 isEqualToString:str2])
        {
            if ([userInfo objectForKey:KEYTOTALCOMMENTS]) {
                [obj setObject:[userInfo objectForKey:KEYTOTALCOMMENTS] forKey:KEYTOTALCOMMENTS];
            }
            
            @synchronized(arrPlaceList)
            {
                [arrPlaceList replaceObjectAtIndex:index withObject:obj];
                *stop = YES;
                return;
            }
            
        }
    }];
    
    //    }
    [tblPlaceList reloadData];
    NSLog(@"Received Notification ");
}

//-(IBAction)UnwindFromComment:(UIStoryboardSegue *)segue{
//    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
//        CommentVC *objDetail = segue.sourceViewController;
//        arrPlaceList= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrPlaceList), kCFPropertyListMutableContainersAndLeaves));
//        [arrPlaceList enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
//            NSLog(@"post id-%@",[[obj valueForKey:@"post_id"] stringValue]);
//
//            NSLog(@"%@",objDetail.strPostId);
//            NSString *str1=[NSString stringWithFormat:@"%@",[obj valueForKey:@"post_id"]];
//            NSString *str2=[NSString stringWithFormat:@"%@",objDetail.strPostId];
//
//            if([str1 isEqualToString:str2])
//            {
//                if (objDetail.strCommentCount) {
//                    [obj setObject:objDetail.strCommentCount forKey:@"total_comments"];
//                }
//                @synchronized(arrPlaceList)
//                {
//                    [arrPlaceList replaceObjectAtIndex:index withObject:obj];
//                    *stop = YES;
//                    return;
//                }
//
//            }
//        }];
//
//    }
//    [tblPlaceList reloadData];
//}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CommentSegue"])
    {
        CommentVC *objComment = segue.destinationViewController;
        objComment.isForPost=YES;
        objComment.strPostId=sender;
        
    }
    else  if ([segue.identifier isEqualToString:@"editPostSegue"]) {
        NewPostVC *newPostVC = segue.destinationViewController;
        newPostVC.performEdit=@"Edit";
        newPostVC.dictPostDetails=(NSDictionary *)sender;
        
    }
    else if ([segue.identifier isEqualToString:@"otherUserProfileSegue"])
    {
        OtherUserProfileVC *objOtherProfile = segue.destinationViewController;
        
        objOtherProfile.strUserID=(NSString *)sender;
    }
}

#pragma mark - Button actions -

- (IBAction)actionBack:(id)sender
{
    [APPDELEGATE clearCachedDirectory];
    [[ServerConnection sharedConnection] stopDownloadFor:@"PlaceVC"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionFollowPlace:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    if(btn.tag==2)
    {
        NSMutableDictionary * dictDeletePost=[[NSMutableDictionary alloc] init];
        [dictDeletePost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictDeletePost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictDeletePost setObject:[dictPlaceDetail objectForKey:@"album_id"] forKey:@"album_id"];
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIDELETEALBUM method:@"POST" data:dictDeletePost withImages:nil withVideo:nil];
    }
    else
    {
        NSMutableDictionary * dictFollowUnFollowPLace=[[NSMutableDictionary alloc] init];
        [dictFollowUnFollowPLace setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictFollowUnFollowPLace setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictFollowUnFollowPLace setObject:[dictPlaceDetail objectForKey:@"place"] forKey:@"place"];
        [dictFollowUnFollowPLace setObject:@"1" forKey:@"is_follow"];
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIFOLLOWUNFOLLOWPLACE method:@"POST" data:dictFollowUnFollowPLace withImages:nil withVideo:nil];
    }
    //    -is_follow(0-unfollow,1-follow)
    
}
#pragma mark - Cache Video From Server Method

-(void)downloadVideo // kandhal
{
    //download the file in a seperate thread.
    //    [self fillDocURlArr];
    if (IsPlayingAll == YES)
    {
        if (CountVideo < arrPlaceList.count)
        {
            [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrPlaceList objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrPlaceList objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrPlaceList];
            
        }else
        {
            //CountVideo = 0;
        }
    }else
    {       if(CountVideo<arrPlaceList.count)
        [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrPlaceList objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrPlaceList objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrPlaceList];
    }
}
#pragma mark - Fill Cached Video Url Method

-(void)fillCachedVideoURL
{
    arrURl = [[NSMutableArray alloc] init];
    for (int i = 0; i<arrPlaceList.count; i++)
    {
        NSString *strPostID = [[arrPlaceList objectAtIndex:i] objectForKey:@"post_id"];
        
        if ([APPDELEGATE checkIfVideoExists:strPostID])
        {
            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strPostID]];
            [arrURl addObject:savedVideoPath];
        }else
        {
            CountVideo = i;
            break;
        }
    }
}
-(void)getCountOfvideotoDownload
{
    NSMutableArray *ArrData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<arrPlaceList.count; i++)
    {
        NSString *strPostID = [[arrPlaceList objectAtIndex:i] objectForKey:@"post_id"];
        
        if ([APPDELEGATE checkIfVideoExists:strPostID])
        {
            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strPostID]];
            [ArrData addObject:savedVideoPath];
        }else
        {
            CountVideo = i;
            [self downloadVideo];
            break;
        }
    }
}
-(void)downloadDoneForUrl:(NSString*)strUrl indexAt:(int)index
{
    if (IsPlayingAll == YES)
    {
        //if ( maxPlayedElement - playingCount >= 2 && queuePlayer !=nil && strUrl != nil && queuePlayer.items.count >=2)
        //{
            __block NSString *strUrlForBlock = [strUrl substringFromIndex:6];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                AVPlayerItem *playerAllItem1;
                playerAllItem1=[AVPlayerItem playerItemWithURL: [NSURL fileURLWithPath:strUrlForBlock]];
                NSLog(@"%@",queuePlayer.items);
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(didEndVideoPlaying:)
                                                             name: AVPlayerItemDidPlayToEndTimeNotification
                                                           object: playerAllItem1];
               
                [queuePlayer insertItem:playerAllItem1 afterItem:[queuePlayer.items lastObject]];
                
                maxPlayedElement = maxPlayedElement +1 ;
            });
            //NSLog(@"downloaded video come for url%@",strUrl.description);
        //}
    }
    [self getCountOfvideotoDownload];
}

// called when category pop up open and download gets Failed
-(void)downloadFailedWithCategory {
    
    [self downloadFailedForUrl];
}



-(void)downloadFailedForUrl{
    [self getCountOfvideotoDownload];
}

//-(void)updateCounter{
//
//    NSLog(@"playingCount = %d",playingCount);
//    
//    //You can access currently played item by using currentItem property:
//    
//    AVPlayerItem *currentItem = queuePlayer.currentItem;
//    
//    //Then you can easily get the requested time values
//    
//    CMTime duration = currentItem.duration; //total time
//    CMTime currentTime = currentItem.currentTime; //playing time
//    
//    NSUInteger durationSeconds = (long)CMTimeGetSeconds(duration);
//    
//    NSLog(@"duration = %ld",durationSeconds);
//    
//    NSUInteger currentTimeInSeconds = (long)CMTimeGetSeconds(currentTime);
//    
//    NSLog(@"currentTime = %ld",currentTimeInSeconds);
//    
//    NSUInteger seconds = durationSeconds - currentTimeInSeconds;
//    
//    if (seconds == 1) {
//        
//        [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
//            [blurView setAlpha:1.f];
//        } completion:^(BOOL finished) {
//            NSLog(@"Complete");
//        }];
//    }
//}

#pragma mark - Play All Video Methods

- (IBAction)actionPlayAllVideo:(id)sender
{
    
    /*[avPlayer pause];
    IsPlayingAll = YES;
    if (!playerViewController)
        [self removeAvPlayerReference];
    
    [ServerConnection sharedConnection].isPlaying= IsPlayingAll;
    
    [self fillCachedVideoURL];*/
    
    if (arrURl.count > 0 ) {
        //NSLog(@"actionPlayAllVideo");
        [avPlayer pause];
        IsPlayingAll = YES;
        if (!playerViewController)
            [self removeAvPlayerReference];
        
        [ServerConnection sharedConnection].isPlaying= IsPlayingAll;
    }
    
    [self fillCachedVideoURL];
    
    if (resumeVideoCount < arrPlaceList.count)
    {
        playingCount = resumeVideoCount;
        
    }else
    {
        resumeVideoCount = 0;
        playingCount = 0;
    }
    if(arrPlaceList.count>0)
    {
        
        if (arrURl.count > 0)
        {
            [queuePlayer removeAllItems];
            //                playerViewController = nil;
            //                queuePlayer = nil;
            
            NSMutableArray *arrPlayerItem;
            AVPlayerItem *playerAllItem;
            
            arrPlayerItem=[[NSMutableArray alloc] init];
            
            
            
            queuePlayer = [[AVQueuePlayer alloc] init];
            // Check Weather All Video watched by user
            
            for(int i=resumeVideoCount;i<arrURl.count;i++)
            {
                
                //                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[arrURl objectAtIndex:i] options:nil];
                //                    NSArray *keys = @[@"playable"];
                //
                //                    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
                //                        [queuePlayer insertItem:[AVPlayerItem playerItemWithAsset:asset] afterItem:nil];
                //                    }];
                //
                AVAsset *asseitem = [AVAsset assetWithURL:[NSURL fileURLWithPath:[arrURl objectAtIndex:i]]];
                playerAllItem = [AVPlayerItem playerItemWithAsset:asseitem];
                
                
                
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(didEndVideoPlaying:)
                                                             name: AVPlayerItemDidPlayToEndTimeNotification
                                                           object: playerAllItem];
                
                //
                //                [playerAllItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
                //                [playerAllItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
                //                [playerAllItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
                //                                        [[[queuePlayer items] objectAtIndex:n] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                //                                        [[[queuePlayer items] objectAtIndex:n] addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
                //                                        [[[queuePlayer items] objectAtIndex:n] addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
                
                
                
                
                [queuePlayer insertItem:playerAllItem afterItem:nil];
                
                //                if([[arrURl objectAtIndex:i] isEqualToString:[[arrListOfPost objectAtIndex:i] objectForKey:@"video"]])
                //                {
                //                    playerAllItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[arrURl objectAtIndex:i]]];
                //
                //                }else
                //                {
                
                //                    AVAsset *asseitem = [AVAsset assetWithURL:[NSURL fileURLWithPath:[arrURl objectAtIndex:i]]];
                //                    playerAllItem = [AVPlayerItem playerItemWithAsset:asseitem];
                //                }
                
                
                
            }
            maxPlayedElement =(int)[queuePlayer.items count];
            playedCount=1;
            
            
//            if ([timer isValid]) {
//                [timer invalidate];
//            }
//            
//            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
            
            
            // queuePlayer = [AVQueuePlayer queuePlayerWithItems:arrPlayerItem];
            if (playerViewController)
            {
                [objPlayAllOverlayVC updateData:[arrPlaceList objectAtIndex:playingCount]];
                
                playerViewController.player = queuePlayer;
                [queuePlayer setVolume:7.0f];
                [queuePlayer play];
                
            }else
            {
                
                playerViewController = [AVPlayerViewController new];
                
                playerViewController.delegate=self;
                
                
                
                
                playerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
                
                playerViewController.player = queuePlayer;
                
                playerViewController.showsPlaybackControls = NO;
                
                [playerViewController supportedInterfaceOrientations];
                
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
                
                NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                
                NSLog(@"play all start ");
                [self presentViewController:playerViewController animated:YES completion:nil];
                [queuePlayer setVolume:7.0f];
                [queuePlayer play];
                
                // adding overlayview which contains like,description and location components.
                objPlayAllOverlayVC = [STORYBOARD instantiateViewControllerWithIdentifier:@"PlayAllOverlayVC"];
                objPlayAllOverlayVC.delegate = self;
                
                objPlayAllOverlayVC.view.frame = CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y, self.view.window.frame.size.width, self.view.window.frame.size.height);
                [self.view.window addSubview:objPlayAllOverlayVC.view];
                
//                blurView=[[UIView alloc]initWithFrame:objPlayAllOverlayVC.view.frame];
//                [blurView setBackgroundColor:[UIColor darkGrayColor]];
//                blurView.alpha = 0.0;
//                [objPlayAllOverlayVC.view addSubview:blurView];
                
                [objPlayAllOverlayVC updateData:[arrPlaceList objectAtIndex:playingCount]];
            }
            
            //[playerViewController addChildViewController:objPlayAllOverlayVC];
            
            // updating data to overlayviewcontroller
            
            // Adding notification for end of video to all player items.
            
        }else
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Please wait for few moments while caching video."];
            
        }
        
    }
    else
    {
        
        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Please start creating post so that you can view all video at one glance."];
    }
    
}


#pragma mark - End of Video Notification Methods

-(void)didEndVideoPlaying:(NSNotification*)notification
{
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [blurView setAlpha:1.0];
//    } completion:^(BOOL finished) {
//    }];
//
    
    if([queuePlayer.items lastObject] !=[notification object] && playedCount < maxPlayedElement&& playingCount < arrPlaceList.count)
    {
        
        playedCount++;
        playingCount++;
        resumeVideoCount++;
        
        //NSLog(@"post id : %@",[[arrPlaceList objectAtIndex:playingCount] objectForKey:KEYPOSTID]);
    
        //if (isAllVideoDownload == FALSE) {
        
        NSUInteger totalCount = 0;
        for (int i = 0; i<arrPlaceList.count; i++)
        {
            NSString *strPostID = [[arrPlaceList objectAtIndex:i] objectForKey:@"post_id"];
            
            if ([APPDELEGATE checkIfVideoExists:strPostID])
            {
                totalCount++;
            }
        }
        
        if (totalCount == arrPlaceList.count) {
            
            if (nextPage == 0) {
                isAllVideoDownload =  TRUE;
                //CountVideo = 0;
            }
            else {
                IsPlayingAll = YES;
                
                if([self.fromWhere isEqualToString:@"Profile"])
                {
                    
                }
                else if([self.fromWhere isEqualToString:@"Top Destination"])
                {
                    [self callListOfPostByCityWebService];
                    
                }
                else if([self.fromWhere isEqualToString:@"Album"])
                {
                    [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                    
                }
                else if([self.fromWhere isEqualToString:@"AlbumSearch"])
                {
                    //[self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                    [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
                    
                }
                else if([self.fromWhere isEqualToString:@"HashTag"])
                {
                    [self callListOfPostByHashTagWebservice];
                    
                }
                else
                {
                    [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
                }
                
            }
        }
        
        //}
        
        if (playingCount < arrPlaceList.count)
        {
            
            [objPlayAllOverlayVC updateData:[arrPlaceList objectAtIndex:playingCount]];
        }
        
        NSLog(@"completed update data");
    }
    
    
    else
    {
        resumeVideoCount = 0;
        playingCount = 0;
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self actionPlayAllVideo:nil];
        
    }
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [blurView setAlpha:0.0];
//    } completion:^(BOOL finished) {
//    }];
    


//    [UIView animateWithDuration:0.1 animations:^{
//        [blurView setAlpha:0.5];
//    } completion:^(BOOL finished) {
//        
//        [blurView setAlpha:0.0];
//        
//        
//    }];

    
    
}


#pragma mark -Push to Place  While Playing All Video screen Methods
-(void)goLocation
{
    //    for (int n =0; n<[queuePlayer items].count; n++)
    //    {
    //        @try
    //        {
    //
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackBufferFull"];
    //            // [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    //        }
    //        @catch (NSException * __unused exception)
    //        {
    //
    //
    //        }
    //        @finally {
    //            //        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //
    //        }
    //
    //    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    //        NSString *placeName=[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"place"];
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    [objPlayAllOverlayVC.view removeFromSuperview];
}
#pragma mark - Stop Playing Methods

-(void)donePlayer
{
    //    for (int n =0; n<[queuePlayer items].count; n++)
    //    {
    //        @try
    //        {
    //
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    //            [[queuePlayer.items objectAtIndex:n] removeObserver:self forKeyPath:@"playbackBufferFull"];
    //            // [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    //        }
    //        @catch (NSException * __unused exception)
    //        {
    //
    //
    //        }
    //        @finally {
    //            //        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //
    //        }
    //
    //    }
    
    if ([avPlayer.currentItem isPlaybackLikelyToKeepUp] == YES)
    {
        [tblPlaceList reloadData];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    NSString *strResumeCount = [NSString stringWithFormat:@"%d",resumeVideoCount];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    IsPlayingAll = NO;
    [ServerConnection sharedConnection].isPlaying = IsPlayingAll;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}
#pragma mark - Like Dislike While Playing Video Methods

-(void)actionLike
{
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrPlaceList objectAtIndex:playingCount] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrPlaceList objectAtIndex:playingCount] objectForKey:@"likebyme"]];
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

- (IBAction)actionSort:(id)sender
{
    viewSortPopUp.frame=CGRectMake(0, 0, [APPDELEGATE window].frame.size.width,[APPDELEGATE window].frame.size.height);
    [viewSortPopUp layoutIfNeeded];
    [[UIApplication sharedApplication].keyWindow addSubview:viewSortPopUp];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:viewSortPopUp];
    
    viewInnerSortPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    
    [UIView animateWithDuration:0.4 animations:^{
        
        viewInnerSortPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }];
    NSLog(@"window = %@", NSStringFromCGRect([APPDELEGATE window].frame));
    NSLog(@"viewSortPopUp = %@", NSStringFromCGRect(viewSortPopUp.frame));
    NSLog(@"viewInnerSortPopUp = %@", NSStringFromCGRect(viewInnerSortPopUp.frame));
}

- (IBAction)actionCloseSortPopUp:(id)sender
{
    [viewSortPopUp removeFromSuperview];
}

- (IBAction)actionCloseShareAndReportPopUp:(id)sender
{
    [viewShareAndReportPopUp removeFromSuperview];
}

- (IBAction)actionShareAndReport:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    if(btn.tag==1)
    {
        
    }
    else if (btn.tag==2)
    {
        //twitter
        NSData *videoData = [NSData dataWithContentsOfURL:[[arrPlaceList objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:@"video"] options:NSDataReadingUncached error:nil];
        [self shareOnTwitter:videoData title:[[arrPlaceList objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:@"post_description"]];
    }
    else
    {
        NSMutableDictionary *dictReportAbuse=[[NSMutableDictionary alloc] init];
        [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictReportAbuse setObject:[[arrPlaceList objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:KEYPOSTID] forKey:KEYPOSTID];
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIREPORTABUSE method:@"POST" data:dictReportAbuse withImages:nil withVideo:nil];
    }
    [viewShareAndReportPopUp setHidden:YES];
}

- (void) shareOnTwitter:(NSData*)videoData title:(NSString*)title
{
    [SVProgressHUD show];
    [TwitterVideoUpload instance].statusContent = title;
    BOOL status = [[TwitterVideoUpload instance] setVideo:videoData];
    if (status == FALSE)
    {
        //        [self addText:@"Failed reading video file"];
        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Failed reading video file"];
        [SVProgressHUD dismiss];
        
        return;
    }
    status = [[TwitterVideoUpload instance] upload:^(NSString* errorString)
              {
                  NSString* printStr = [NSString stringWithFormat:@"Share video: %@",
                                        (errorString == nil) ? @"Success" : errorString];
                  //                  [self addText:printStr];
                  [UIAlertView showAlertViewWithTitle:APPNAME message:@"Video shared successfully on twitter."];
                  [SVProgressHUD dismiss];
                  
              }];
    if (status == FALSE)
    {
        //        [self addText:@"No Twitter account. Please add twitter account to Settings app."];
        [UIAlertView showAlertViewWithTitle:APPNAME message:@"No Twitter account. Please add twitter account to Settings app."];
        [SVProgressHUD dismiss];
        
    }
}

- (IBAction)actionSortType:(id)sender
{
    [self removeAvPlayerReference];
    UIButton *btn=(UIButton*)sender;
    
    if(btn.tag==1)
    {
        strType=@"rating";
    }
    else if (btn.tag==2)
    {
        strType=@"Most recent";
    }
    else if (btn.tag==3)
    {
        strType=@"Likes";
    }
//    strCategoryName=@"all";

    arrPlaceList=[[NSMutableArray alloc] init];
    nextPage=0;
    resumeVideoCount = 0;
    tblPlaceList.hidden = YES;
    [tblPlaceList reloadData];
    
    if([self.fromWhere isEqualToString:@"Profile"])
    {
        
    }
    else if([self.fromWhere isEqualToString:@"Top Destination"])
    {
        [self callListOfPostByCityWebService];

    }
    else if([self.fromWhere isEqualToString:@"Album"])
    {
        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];

    }
    else if([self.fromWhere isEqualToString:@"AlbumSearch"])
    {
        [self callSearchAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
    }
    else if([self.fromWhere isEqualToString:@"HashTag"])
    {
        [self callListOfPostByHashTagWebservice];

    }
    else
    {
        [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
    }
    
    
    
    
//    if([self.fromWhere isEqualToString:@"Album"])
//    {
//        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
//    }
//    else if([self.fromWhere isEqualToString:@"Top Destination"])
//    {
//        [self callListOfPostByCityWebService];
//    }else if ([self.fromWhere isEqualToString:@"AlbumSearch"])
//    {
//        [self callAlbumVideoWebService:strCategoryName type:strType pageIndex:nextPage];
//    }
//    else
//    {
//        [self callListOfPostWebService:strCategoryName type:strType pageIndex:nextPage];
//    }
    [viewSortPopUp removeFromSuperview];
}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APIFOLLOWUNFOLLOWPLACE])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];
            
            [UIAlertView showAlertViewWithTitle:APPNAME message:[NSString stringWithFormat:@"You are now following '%@'",[[dictData objectForKey:@"data"] objectForKey:@"place"]]]; //You have
        }
        else if ([reqURL myContainsString:APILISTOFPOSTBYPLACE])
        {
            NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
            
            if (isRefresh==YES) {
                isRefresh=NO;
                CountVideo =0;
                resumeVideoCount = 0;
                playingCount = 0;
                arrPlaceList=[[NSMutableArray alloc] initWithArray:getListOfPostData];
            }
            else{
                if(getListOfPostData.count>0)
                {
                    [arrPlaceList addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                    totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                    
                    arrPlaceList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrPlaceList]];
                    
                }
                else
                {
                    
                    [tblPlaceList setHidden:YES];
                }
            }
            if (arrPlaceList.count>0)
            {
                //CountVideo =0;
                //resumeVideoCount = 0;
                //playingCount = 0;
                [[ServerConnection sharedConnection] stopDownloadFor:@"PlaceVC"];
                [self getCountOfvideotoDownload];
            }
            
            nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
            
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            [tblPlaceList reloadData];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];
            
            NSInteger indexOfMatchingDictionary = [arrPlaceList indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
                return [[obj valueForKey:@"post_id"] isEqual:[[dictData objectForKey:@"data"] objectForKey:@"post_id"]
                        ];
            }];
            
            NSMutableDictionary *tempDict=[[arrPlaceList objectAtIndex:indexOfMatchingDictionary] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"is_like"]] forKey:@"likebyme"];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"total_likes"]] forKey:@"total_likes"];
            [arrPlaceList replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
            
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblPlaceList cellForRowAtIndexPath:indePath];
            cell.lblNoOfLike.text=[NSString stringWithFormat:@"%@",[[arrPlaceList objectAtIndex:indexOfMatchingDictionary] objectForKey:@"total_likes"]];
            
            NSString *likePost=[NSString stringWithFormat:@"%@",[[arrPlaceList objectAtIndex:indexOfMatchingDictionary] objectForKey:@"likebyme"]];
            
            if([likePost isEqualToString:@"1"])
            {
                [cell.btnImgLikeDislike setSelected:YES];
            }
            else
            {
                [cell.btnImgLikeDislike setSelected:NO];
            }
            if (IsPlayingAll == YES)
            {
                [objPlayAllOverlayVC updateData:[arrPlaceList objectAtIndex:playingCount]];
                
            }
            //            [tblPlaceList beginUpdates];
            //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
            //            [tblPlaceList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            [tblPlaceList endUpdates];
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Post has been successfully Abused by you."];
        }
        else if ([reqURL myContainsString:APILISTOFPOSTBYCITY])
        {
            NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
            
            if (isRefresh==YES) {
                isRefresh=NO;
                CountVideo =0;
                resumeVideoCount = 0;
                playingCount = 0;
                arrPlaceList=[[NSMutableArray alloc] initWithArray:getListOfPostData];
            }
            else{
                if(getListOfPostData.count>0)
                {
                    [arrPlaceList addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                    totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                    
                    arrPlaceList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrPlaceList]];
                    
                }
                else
                {
                    [tblPlaceList setHidden:YES];
                }
            }
            if (arrPlaceList.count>0)
            {
                //CountVideo =0;
                //resumeVideoCount = 0;
                //playingCount = 0;
                [[ServerConnection sharedConnection] stopDownloadFor:@"PlaceVC"];
                [self getCountOfvideotoDownload];
            }
            
            nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
            
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            [tblPlaceList reloadData];
            
        }
        else if ([reqURL myContainsString:APILISTOFALBUMBYVIDEO])
        {
            NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
            
            if (isRefresh==YES) {
                isRefresh=NO;
                CountVideo =0;
                resumeVideoCount = 0;
                playingCount = 0;
                arrPlaceList=[[NSMutableArray alloc] initWithArray:getListOfPostData];
            }
            else{
                if(getListOfPostData.count>0)
                {
                    [arrPlaceList addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                    totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                    
                    arrPlaceList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrPlaceList]];
                    
                }
                else
                {
                    [tblPlaceList setHidden:YES];
                }
            }
            if (arrPlaceList.count>0)
            {
                //CountVideo =0;
                //resumeVideoCount = 0;
                //playingCount = 0;
                [[ServerConnection sharedConnection] stopDownloadFor:@"PlaceVC"];
                [self getCountOfvideotoDownload];
            }
            
            nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
            
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            [tblPlaceList reloadData];
            
//            arrPlaceList=[[NSMutableArray alloc] init];
//            arrPlaceList= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)([[dictData objectForKey:@"data"] objectForKey:@"posts"]), kCFPropertyListMutableContainersAndLeaves));
//            
//            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
//            [tblPlaceList reloadData]; old code
        }
        else if ([reqURL myContainsString:APILISTOFVIDEOBYSEARCHALBUM])
        {
            
            NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
            
            if (isRefresh==YES) {
                isRefresh=NO;
                CountVideo =0;
                resumeVideoCount = 0;
                playingCount = 0;
                arrPlaceList=[[NSMutableArray alloc] initWithArray:getListOfPostData];
            }
            else{
                if(getListOfPostData.count>0)
                {
                    [arrPlaceList addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                    totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                    
                    arrPlaceList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrPlaceList]];
                    
                }
                else
                {
                    [tblPlaceList setHidden:YES];
                }
            }
            if (arrPlaceList.count>0)
            {
                //CountVideo =0;
                //resumeVideoCount = 0;
                //playingCount = 0;
                [[ServerConnection sharedConnection] stopDownloadFor:@"PlaceVC"];
                [self getCountOfvideotoDownload];
            }
            
            nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
            
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            [tblPlaceList reloadData];
            
            
//            arrPlaceList=[[NSMutableArray alloc] init];
//            arrPlaceList= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)([[dictData objectForKey:@"data"] objectForKey:@"posts"]), kCFPropertyListMutableContainersAndLeaves));
//            
//            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
//            [tblPlaceList reloadData]; old code
        }
        else if ([reqURL myContainsString:APIDELETEALBUM])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];
            
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Album has been successfully deleted."];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([reqURL myContainsString:APILISTOFPOSTBYHASHTAG])
        {
            NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
            
            if (isRefresh==YES) {
                isRefresh=NO;
                CountVideo =0;
                resumeVideoCount = 0;
                playingCount = 0;
                arrPlaceList=[[NSMutableArray alloc] initWithArray:getListOfPostData];
            }
            else{
                if(getListOfPostData.count>0)
                {
                    [arrPlaceList addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                    totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                    arrPlaceList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrPlaceList]];
                    
                }
                else
                {
                    [tblPlaceList setHidden:YES];
                }
            }
            
            nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
            
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            [tblPlaceList reloadData];
            
        }
        
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APIFOLLOWUNFOLLOWPLACE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if([reqURL myContainsString:APILISTOFPOSTBYPLACE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
            
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            
        }
        else if ([reqURL myContainsString:APILISTOFALBUMBYVIDEO])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            
        }
        [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
        [tblPlaceList setHidden:NO];
        [tblPlaceList reloadData];
        
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
    [tblPlaceList reloadData];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
