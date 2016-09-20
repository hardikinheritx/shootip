//
//  HomeVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "HomeVC.h"
#import "VideoPostCell.h"
#import "AppDelegate.h"
#import "NewPostVC.h"
#import "NewPostVC.h"
#import "AlbumSelectionVC.h"
#import "CreateNewAlbumVC.h"
#import "ExistingAlbumListVC.h"
#import "CommentVC.h"
#import "PlaceVC.h"
#import "CBStoreHouseRefreshControl.h"
#import "ShareAndReportVC.h"
#import "OtherUserProfileVC.h"
#import "TopDestinationListCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+Toast.h"

@interface HomeVC ()
{
    NSMutableArray *arrURl;// kandhal
    AVPlayerViewController *playerViewController;
    PlayAllOverlayVC *objPlayAllOverlayVC;
    int CountVideo;
    int playingCount;
    int playedCount;
    int maxPlayedElement;
    int  resumeVideoCount;
    NSMutableArray *arrListOfPost;
    UILabel *messageLabel;
    AVQueuePlayer *queuePlayer;
    NSString *strCategoryName;
    NSString *strType;
    NSInteger totalPage;
    NSInteger nextPage;
    NSInteger selectedPlayIndex;
    //    AVPlayer *avPlayer;
    AVPlayerItem *playerItem;
    AVPlayerLayer *layer;
    UIRefreshControl *refreshControl;
    BOOL isRefresh;
    BOOL IsPlayingAll;
    BOOL iSOvelayViewShow;
 
    BOOL isAllVideoDownload;

}

@end


@implementation HomeVC
@synthesize avPlayer;
@synthesize strMainCategory;

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    isAllVideoDownload = FALSE;
    CountVideo = 0;
    resumeVideoCount = 0;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
//    queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                           selector:@selector(didEndVideoPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    UITapGestureRecognizer *dismissGestureRecognition = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissDoubleTap:)];
    dismissGestureRecognition.numberOfTapsRequired = 1;
    [_overlaySubView addGestureRecognizer:dismissGestureRecognition];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTriggered:) forControlEvents:UIControlEventValueChanged];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:0.337 green:0.659 blue:0.467 alpha:1.000];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..." attributes:attrsDictionary];
    refreshControl.attributedTitle = attributedTitle;
    // [tblHomePost addSubview:refreshControl];
    
    //    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:tblHomePost target:self refreshAction:@selector(refreshTriggered:) plist:@"ShootipRefresh" color:[UIColor whiteColor] lineWidth:1.5 dropHeight:50 scale:.7 horizontalRandomness:500 reverseLoadingAnimation:NO internalAnimationFactor:0.7];
    arrListOfPost=[[NSMutableArray alloc] init];
    
    strType=@"Most recent";
    strCategoryName=@"all";
    //NSLog(@"cat name : %@ type: %@ page no :%ld",strCategoryName,strType,(long)nextPage);
//    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage  showHud:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UpdateCommentCount:)
                                                 name:UPDATECOMMENTCOUNTNOTIFICATION object:nil];
    
}

- (void)UpdateCommentCount:(NSNotification *)note {
    //    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
    //        CommentVC *objDetail = segue.sourceViewController;
    
    NSDictionary *userInfo = note.userInfo;
    arrListOfPost= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrListOfPost), kCFPropertyListMutableContainersAndLeaves));
    
    [arrListOfPost enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        //NSLog(@"post id-%@",[[obj valueForKey:@"post_id"] stringValue]);
        
        //            NSLog(@"%@",objDetail.strPostId);
        NSString *str1=[NSString stringWithFormat:@"%@",[obj valueForKey:KEYPOSTID]];
        NSString *str2=[NSString stringWithFormat:@"%@",[userInfo objectForKey:KEYPOSTID]];
        
        if([str1 isEqualToString:str2])
        {
            if ([userInfo objectForKey:KEYTOTALCOMMENTS]) {
                [obj setObject:[userInfo objectForKey:KEYTOTALCOMMENTS] forKey:KEYTOTALCOMMENTS];
            }
            
            @synchronized(arrListOfPost)
            {
                [arrListOfPost replaceObjectAtIndex:index withObject:obj];
                *stop = YES;
                return;
            }
            
        }
    }];
    
    //    }
    [tblHomePost reloadData];
    NSLog(@"Received Notification ");
}

//- (void) dealloc
//{
//    // If you don't remove yourself as an observer, the Notification Center
//    // will continue to try and send notification objects to the deallocated
//    // object.
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//
//}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [btnSort setHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    
    nextPage=0;
    //    [tblHomePost reloadData];
    messageLabel = [[UILabel alloc] init];
    if ([USERDEFAULTS objectForKey:KEYISPOSTUPDATED])
    {
        tblHomePost.hidden=YES;
        
        [USERDEFAULTS removeObjectForKey:KEYISPOSTUPDATED];
        [USERDEFAULTS synchronize];
//        [arrListOfPost removeAllObjects];
//        [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
    }
    [arrListOfPost removeAllObjects];
    tblHomePost.hidden = YES;
    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];

    [tblHomePost reloadData];
    
    //        [tblHomePost reloadData];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    IsPlayingAll = NO;
    [ServerConnection sharedConnection].isPlaying = IsPlayingAll;

    // _player is an instance of AVPlayer
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
            
            //[[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self finishRefreshControl];
    [queuePlayer removeAllItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [APPDELEGATE setDropOffScreen:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
//    NSString *strMessage = [NSString stringWithFormat:@"Welcome video download"];
//    [self.navigationController.view makeToast:strMessage];

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
    //    [arrListOfPost removeAllObjects];
    //    [tblHomePost reloadData];
    isRefresh=YES;
    nextPage=0;
    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:NO];
    
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
        //        [arrListOfPost removeAllObjects];
        //        [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
    } else {
        NSLog(@"Unreachable");
    }
    
}

#pragma mark - WebService Call -

-(void)GetAllPost:(NSString*)category type:(NSString*)type pageIndex:(NSInteger)index showHud:(BOOL)isHud
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == NO){
        [self finishRefreshControl];
        return;
    }
   

    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHud) {
            
            if(IsPlayingAll == NO){
                [SVProgressHUD show];
            }
            
            
        }
    });
 
    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictListOfPost setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:KEYPAGEINDEX];
    [dictListOfPost setObject:type forKey:@"type"];
    [dictListOfPost setObject:category forKey:@"category"];
    if ([strMainCategory isEqualToString:APIAROUNDME])
    {
        NSString *latitude = [APPDELEGATE strLatitude];
        NSString *longitude = [APPDELEGATE strLongitude];
        
        [dictListOfPost setObject:latitude forKey:@"latitude"];
        [dictListOfPost setObject:longitude forKey:@"longitude"];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIAROUNDME method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];

    
    }else
    {
        
    [dictListOfPost setObject:strMainCategory forKey:@"main_category"];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOST method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];

    }
    
}

#pragma mark - Table Datasource and delegate -


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrListOfPost.count>0){
        return arrListOfPost.count;
    }
    return 0;
    //   else{
    //        return [APPDELEGATE arrayTopDestinationList].count;
    //    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    messageLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    // Return the number of sections.
    if ([arrListOfPost count]!=0)
    {
        messageLabel.text=@"";
        viewSortAndPlayAll.hidden = NO;
        return 1;
    }
    else
    {
        viewSortAndPlayAll.hidden = NO;
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
    if (arrListOfPost.count>0){
        return 443;
    }else{
        return 200;
    }
    
    //    return 393;
    //    return 443;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //    if ([arrListOfPost count]>0)
    //    {
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
    
    [cell.btnLikeDisLike removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    [cell.btnLikeDisLike addTarget:self action:@selector(btnLikeDisLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnImgLikeDislike.exclusiveTouch=YES;
    [cell.btnAddVideoToAlbum addTarget:self action:@selector(btnAddVideoToAlbumAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnPlayVideo setHidden:NO];
    
    [cell.btnPlayVideo addTarget:self action:@selector(btnPlayVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSDictionary *dictPost=[arrListOfPost objectAtIndex:indexPath.row];
    
    [cell.btnReportOrEdit addTarget:self action:@selector(btnReportOrEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell ConfigureCell:[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"rating"]] postDict:dictPost];
    
    
    UITapGestureRecognizer *tapRecognizerUsername = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userNameTapped:)];
    cell.lblUserName.userInteractionEnabled=YES;
    [cell.lblUserName addGestureRecognizer:tapRecognizerUsername];
    
    
    cell.lblUserName.tag=cell.btnReportOrEdit.tag=cell.btnComment.tag=cell.btnTitle.tag=cell.btnLikeDisLike.tag=cell.btnAddVideoToAlbum.tag=cell.btnPlayVideo.tag=cell.btnMap.tag=indexPath.row;
    [cell.imgVideoThumbnail layoutIfNeeded];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    // }
    //    else
    //    {
    //
    //        NSDictionary *dicTopDestination = [[APPDELEGATE arrayTopDestinationList] objectAtIndex:indexPath.row];
    //
    //        static NSString *cellID =  @"TopDestinationListCellIdentifier";
    //
    //        TopDestinationListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    //
    //        if (cell == nil)
    //        {
    //            cell = [[TopDestinationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    //        }
    //
    //
    //        cell.imgDestination.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dicTopDestination objectForKey:@"DestinationThumbnail"]]];
    //
    //        cell.lblDestinationName.text = [NSString stringWithFormat:@"%@",[dicTopDestination objectForKey:@"DestinationName"]];
    //        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //
    //        return cell;
    //    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([arrListOfPost count]==0) {
        PlaceVC *objPlaceVC = [STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
        objPlaceVC.fromWhere=@"Top Destination";
        objPlaceVC.strTitle=[[[APPDELEGATE arrayTopDestinationList] objectAtIndex:indexPath.row] objectForKey:@"DestinationName"];
        [self.navigationController pushViewController:objPlaceVC animated:YES];
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == arrListOfPost.count && arrListOfPost.count > 1)
    {
        if(nextPage==0)
        {
            
        }
        else
        {
            [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        if(selectedPlayIndex==indexPath.row)
        {
            if ([arrListOfPost count]>0) {
                VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indexPath];
                cell.btnPlayVideo.hidden=NO;
                [layer removeFromSuperlayer];
                [avPlayer pause];
                @try
                {
                    
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
                    
                    
                    //  [[NSNotificationCenter defaultCenter] removeObserver:self];
                }
                @catch (NSException * __unused exception)
                {
                    
                }
                @finally {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                    
                }
                playerItem=nil;
            }
            
            
        }
    }
}

#pragma mark - Notifying refresh control of scrolling -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.storeHouseRefreshControl scrollViewDidScroll];
    //    [self removeAvPlayerReference];
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

-(void)checkWhichVideoToEnable
{
    for(VideoPostCell *cell in [tblHomePost visibleCells])
    {
        if([cell isKindOfClass:[VideoPostCell class]])
        {
            NSIndexPath *indexPath = [tblHomePost indexPathForCell:cell];
            CGRect cellRect = [tblHomePost rectForRowAtIndexPath:indexPath];
            UIView *superview = tblHomePost.superview;
            
            CGRect convertedRect=[tblHomePost convertRect:cellRect toView:superview];
            CGRect intersect = CGRectIntersection(tblHomePost.frame, convertedRect);
            float visibleHeight = CGRectGetHeight(intersect);
            
            if(visibleHeight>443*0.6) // only if 60% of the cell is visible
            {
                @try
                {
                    NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
                    
                    if(!(selectedPlayIndex==indePath.row))
                    {
                        VideoPostCell *cell1 = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath1];
                        cell1.btnPlayVideo.hidden=NO;
                        cell1.videoActivityIndicator.hidden=YES;
                        [self removeAvPlayerReference];
                        
                        VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath];
                        cell.btnPlayVideo.hidden=YES;
                        //    avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"video"]]];
                        
                        if ([APPDELEGATE checkIfVideoExists:[[arrListOfPost objectAtIndex:indePath.row] objectForKey:@"post_id"]])
                        {
                            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                            
                            NSString *savedVideoPath = [NSString stringWithFormat:@"%@/%@.mov",paths1,[[arrListOfPost objectAtIndex:indePath.row] objectForKey:@"post_id"]];
                            playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:savedVideoPath]];
                        }
                        else
                        {
                            playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrListOfPost objectAtIndex:indePath.row] objectForKey:@"video"]]];
                            
                        }
                        
                        if(!avPlayer)
                        {
                            avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
                        }
                        else
                        {
                            [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
                        }
                        
                        
                        
                        //    [avPlayer replaceCurrentItemWithPlayerItem:[playerItem playerItemWithURL:[NSURL fileURLWithPath:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"video"]]]];
                        
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

#pragma mark - Custom Action -

- (void)userNameTapped:(UITapGestureRecognizer*)sender
{
    NSDictionary *dict=[arrListOfPost objectAtIndex:sender.view.tag];
    
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
                  //                  NSString* printStr = [NSString stringWithFormat:@"Share video: %@",
                  //                                        (errorString == nil) ? @"Success" : errorString];
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

-(void)btnTitleAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    //    NSString *placeName=[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"place"];
    
    NSMutableDictionary *dictPlace=[[NSMutableDictionary alloc] init];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"place"] forKey:@"place"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"city"] forKey:@"city"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"country"] forKey:@"country"];
    
    [self performSegueWithIdentifier:@"placeSegue" sender:dictPlace];
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
    objAlbumSelection.strPostId=[[arrListOfPost objectAtIndex:btn.tag] objectForKey:KEYPOSTID];
    objAlbumSelection.shouldAddVideoToAlbum=YES;
    objAlbumSelection.videoDelegate=self;
}

-(void)removeAvPlayerReference
{
    [avPlayer pause];
    [layer removeFromSuperlayer];
    @try
    {
        
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        
        // [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    @catch (NSException * __unused exception)
    {
        
        
    }
    @finally
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    playerItem=nil;
}

-(void)btnPlayVideoAction:(UIButton *)sender
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == YES)
    {
        @try
        {
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
            VideoPostCell *cell1 = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath1];
            cell1.btnPlayVideo.hidden=NO;
            cell1.videoActivityIndicator.hidden=YES;
            [self removeAvPlayerReference];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:sender.tag inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath];
            cell.btnPlayVideo.hidden=YES;
            //    avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"video"]]];
            if ([APPDELEGATE checkIfVideoExists:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"post_id"]])
            {
                NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *savedVideoPath = [NSString stringWithFormat:@"%@/%@.mov",paths1,[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"post_id"]];
                playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:savedVideoPath]];
                
                
                
            }
            else
            {
                playerItem=[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"video"]]];
                
            }
            
            if(!avPlayer)
            {
                avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
            }
            else
            {
                [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
            }
            
            
            
            //    [avPlayer replaceCurrentItemWithPlayerItem:[playerItem playerItemWithURL:[NSURL fileURLWithPath:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"video"]]]];
            
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
                [queuePlayer removeObserver:AVPlayerItemDidPlayToEndTimeNotification forKeyPath:@"status"];
                
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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
   
//    NSLog(@"in observer %d",playedCount);
//    if (object == [queuePlayer.items lastObject]) {
//        NSLog(@"Exit");
//    }
//    if (object == queuePlayer.currentItem)
//    {
//        NSLog(@"from current%@",keyPath);
//        NSLog(@"%@",change);
//        NSLog(@"%@",object);
//
//    }else
//    {
//        NSLog(@"from other%@",keyPath);
//        NSLog(@"%@",change);
//        NSLog(@"%@",object);
//
//
//    }
//    NSLog(@"%@",keyPath);
    if (!avPlayer)
    {
        //  NSLog(@"not avplayer");
        return;
    }
    
//    if (object == queuePlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    if (object == queuePlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {   //yes->check it...
        //AVPlayerItem *item = (AVPlayerItem *)object;
        
        
        if (object == queuePlayer.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (queuePlayer.currentItem.playbackBufferEmpty) {
                //Your code here
                  NSLog(@"Empty");
            }
        }
        
        else if (object == queuePlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            if (queuePlayer.currentItem.playbackLikelyToKeepUp)
            {
                //Your code here
//                [avPlayer play];
//                
//                NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
//                VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath1];
//                [cell.videoActivityIndicator setHidden:YES];
                        NSLog(@"Alive");
            }
        }
        else if (object == queuePlayer.currentItem && [keyPath isEqualToString:@"playbackBufferFull"])
        {
            if (queuePlayer.currentItem.playbackBufferFull)
            {
                //Your code here
                   NSLog(@"Buffer Full");
            }
        }

//        switch(item.status)
//        {
//            case AVPlayerItemStatusFailed:
//            {
//                
//                NSError *error = [item error];
//                NSLog(@"playback error is %@", error);
//                break;
//            }
//            case AVPlayerItemStatusReadyToPlay:
//                
//                NSLog(@"player item status is ready to play");
//                
//                break;
//            case AVPlayerItemStatusUnknown:
//            {
//                NSLog(@"AV STATUS UNKNOWN");
//                
//                break;
//            }
//        }
    }
    
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (avPlayer.currentItem.playbackBufferEmpty) {
            //Your code here
            //  NSLog(@"Empty");
        }
    }
    
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (avPlayer.currentItem.playbackLikelyToKeepUp)
        {
            //Your code here
            [avPlayer play];
            
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath1];
            [cell.videoActivityIndicator setHidden:YES];
            //        NSLog(@"Alive");
        }
    }
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferFull"])
    {
        if (avPlayer.currentItem.playbackBufferFull)
        {
            //Your code here
            //   NSLog(@"Buffer Full");
        }
    }
}

-(void)btnReportOrEditAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    
    if([[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]] isEqualToString:[NSString stringWithFormat:@"%@",[[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"user_data"] objectForKey:KEYUSERID]]])
    {
        [self performSegueWithIdentifier:@"editPostSegue" sender:[arrListOfPost objectAtIndex:sender.tag]];
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
        objShare.getPostData=[arrListOfPost objectAtIndex:btn.tag];
    }
}

-(void)btnLikeDisLikeAction:(UIButton *)sender
{
    //    VideoPostCell* cell = (VideoPostCell*)[[[[[sender superview] superview] superview] superview] superview];
    //    cell.btnImgLikeDislike.selected=!cell.btnImgLikeDislike.selected;
    
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"likebyme"]];
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
    [dict setObject:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"latitude"] forKey:@"latitude"];
    [dict setObject:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"longitude"] forKey:@"longitude"];
    [dict setObject:[[arrListOfPost objectAtIndex:sender.tag] objectForKey:@"place"] forKey:@"place"];
    
    [self performSegueWithIdentifier:@"mapSegue" sender:dict];
}

-(void)btnCommentAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    [self performSegueWithIdentifier:@"CommentSegue" sender:[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"post_id"]];
}

#pragma mark - Category delegate method -

- (void)getDataFromCategory:(NSDictionary*)getCategoryDict
{
    //    NSLog(@"%@",getCategoryDict);
    
    //    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    //    [dictListOfPost setObject:@"0" forKey:KEYPAGEINDEX];
    //    [dictListOfPost setObject:@"all" forKey:@"type"];
    
    [self removeAvPlayerReference];
    strCategoryName=[getCategoryDict objectForKey:@"category_name"];
    //    [dictListOfPost setObject:strCategoryName forKey:@"category"];
    
    //    [SVProgressHUD show];
    //    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOST method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
    
    arrListOfPost=[[NSMutableArray alloc] init];
    tblHomePost.hidden = YES;

    [tblHomePost reloadData];
    
    nextPage=0;
    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
}

-(void)reloadTableDataForVideoCount:(NSMutableDictionary*)getVideoDetails;
{
    NSInteger indexOfMatchingDictionary = [arrListOfPost indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
        return [[obj valueForKey:@"post_id"] isEqual:[getVideoDetails objectForKey:@"post_id"]
                ];
    }];
    NSMutableDictionary *tempDict=[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] mutableCopy];
    [tempDict setObject:[NSString stringWithFormat:@"%@",[getVideoDetails objectForKey:@"video_added_count"]] forKey:@"video_added_count"];
    [arrListOfPost replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
    
    
    NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
    VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath];
    
    cell.lblNoOfVideoShared.text=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] objectForKey:@"video_added_count"]];
}
//-(IBAction)UnwindFromComment:(UIStoryboardSegue *)segue{
//    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
//        CommentVC *objDetail = segue.sourceViewController;
//        arrListOfPost= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrListOfPost), kCFPropertyListMutableContainersAndLeaves));
//
//        if (objDetail.strPostId) {
//
//        }
//        [arrListOfPost enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
//            NSLog(@"post id-%@",[[obj valueForKey:@"post_id"] stringValue]);
//
//            NSLog(@"%@",objDetail.strPostId);
//            NSString *str1=[NSString stringWithFormat:@"%@",[obj valueForKey:@"post_id"]];
//            NSString *str2=[NSString stringWithFormat:@"%@",objDetail.strPostId];
//
//            if([str1 isEqualToString:str2])
//            {
//                if (objDetail.strCommentCount) {
//                [obj setObject:objDetail.strCommentCount forKey:@"total_comments"];
//                }
//
//                @synchronized(arrListOfPost)
//                {
//                    [arrListOfPost replaceObjectAtIndex:index withObject:obj];
//                    *stop = YES;
//                    return;
//                }
//
//            }
//        }];
//
//    }
//    [tblHomePost reloadData];
//}
#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    tblHomePost.hidden=NO;
    //NSLog(@"Response %@",dictData);
    
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APILISTOFPOST] || [reqURL myContainsString:APIAROUNDME])
        {
            if([[dictData objectForKey:@"data"] objectForKey:@"posts"])
            {
                NSMutableArray *getListOfPostData=[[NSMutableArray alloc]initWithArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                
                if (isRefresh==YES)
                {
                    playingCount = 0;

                    resumeVideoCount = 0;
                  
                    arrListOfPost=[[NSMutableArray alloc] initWithArray:getListOfPostData];
                    CountVideo=0;
                    [[ServerConnection sharedConnection] stopDownloadFor:strMainCategory];
                    [self getCountOfvideotoDownload];
                    tblHomePost.hidden = NO;
                    isRefresh=NO;
                }
                else
                {
                    if(getListOfPostData.count>0)
                    {
                        //resumeVideoCount = 0;
                        //playingCount = 0;
 
                        [arrListOfPost addObjectsFromArray:[[dictData objectForKey:@"data"] objectForKey:@"posts"]];
                        totalPage=[[[dictData objectForKey:@"data"] objectForKey:@"total_pages"] integerValue];
                        nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
                        arrListOfPost = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:arrListOfPost]];
                        //CountVideo = 0;
                        [[ServerConnection sharedConnection] stopDownloadFor:strMainCategory];
                        [self getCountOfvideotoDownload];
                        tblHomePost.hidden = NO;

                    }
                    else
                    {
                        tblHomePost.hidden = YES;
                        //   [tblHomePost setHidden:YES];
                    }
                }
               
               
                NSLog(@"arrListOfPost count %lu",(unsigned long)arrListOfPost.count);
                [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
                nextPage=[[[dictData objectForKey:@"data"] objectForKey:@"next_page_index"] integerValue];
                [tblHomePost setHidden:NO];
                [tblHomePost reloadData];
                
                if (IsPlayingAll == NO) {
                    
                    if(arrListOfPost.count>0)
                    {
                        selectedPlayIndex=4;
                        [self checkWhichVideoToEnable];
                        for (UIRefreshControl *subView in [tblHomePost subviews])
                        {
                            if ([subView isKindOfClass:[UIRefreshControl class]])
                            {
                                
                            }
                            else
                            {
                                [tblHomePost addSubview:refreshControl];
                            }
                        }
                        btnPlayAll.hidden=NO;
                    }
                    else{
                        
                        btnPlayAll.hidden=YES;
                        btnSort.hidden=YES;
                        [refreshControl removeFromSuperview];
                    }
                }
                
             
            }
            else
            {
                //  [tblHomePost setHidden:YES];
            }
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
           
            
            NSLog(@"dictData = %@",dictData);
            
            NSInteger indexOfMatchingDictionary = [arrListOfPost indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
                return [[obj valueForKey:@"post_id"] isEqual:[[dictData objectForKey:@"data"] objectForKey:@"post_id"]
                        ];
            }];
            
            NSMutableDictionary *tempDict=[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"is_like"]] forKey:@"likebyme"];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"total_likes"]] forKey:@"total_likes"];
            [arrListOfPost replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
            VideoPostCell *cell = (VideoPostCell*)[tblHomePost cellForRowAtIndexPath:indePath];
            cell.lblNoOfLike.text=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] objectForKey:@"total_likes"]];
            
            NSString *likePost=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] objectForKey:@"likebyme"]];
            
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
                [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];
                
            }
            //            [tblHomePost beginUpdates];
            //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:0];
            //            [tblHomePost reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            [tblHomePost endUpdates];
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Post has been successfully abused by you."];
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APILISTOFPOST])
        {
//            btnPlayAll.hidden=YES;
//            btnSort.hidden=YES;
            viewSortAndPlayAll.hidden = NO;
            
            [refreshControl removeFromSuperview];
            [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
            arrListOfPost = [[NSMutableArray alloc] init];
            [tblHomePost reloadData];
            // [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
//            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            
        }
    }
    //    [SVProgressHUD dismiss];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
    [tblHomePost reloadData];
    
    [SVProgressHUD dismiss];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"editPostSegue"])
    {
        NewPostVC *newPostVC = segue.destinationViewController;
        newPostVC.performEdit=@"Edit";
        newPostVC.dictPostDetails=(NSDictionary *)sender;
    }
    else if ([segue.identifier isEqualToString:@"CommentSegue"])
    {
        CommentVC *objComment = segue.destinationViewController;
        objComment.isForPost=YES;
        objComment.strPostId=sender;
    }
    else if ([segue.identifier isEqualToString:@"mapSegue"])
    {
        MapVC *objMap = segue.destinationViewController;
        objMap.dictMap=sender;
    }
    else if ([segue.identifier isEqualToString:@"placeSegue"])
    {
        PlaceVC *objPlaceVC = segue.destinationViewController;
        objPlaceVC.dictPlaceDetail=sender;
    }
    else if ([segue.identifier isEqualToString:@"otherUserProfileSegue"])
    {
        OtherUserProfileVC *objOtherProfile = segue.destinationViewController;
        
        objOtherProfile.strUserID=(NSString *)sender;
    }
    
}


#pragma mark - Button actions -

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
    //    NSLog(@"window = %@", NSStringFromCGRect([APPDELEGATE window].frame));
    //    NSLog(@"viewSortPopUp = %@", NSStringFromCGRect(viewSortPopUp.frame));
    //    NSLog(@"viewInnerSortPopUp = %@", NSStringFromCGRect(viewInnerSortPopUp.frame));
}

- (IBAction)actionCloseSortPopUp:(id)sender
{
    [viewSortPopUp removeFromSuperview];
}

- (IBAction)actionCloseShareAndReportPopUp:(id)sender
{
    [viewShareAndReportPopUp removeFromSuperview];
    //    viewInnerShareAndReportPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    //
    //    [UIView animateWithDuration:0.4 animations:^{
    //        viewInnerShareAndReportPopUp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    //    }];
}

- (IBAction)actionSortType:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    
    //    NSMutableDictionary * dictListOfPost=[[NSMutableDictionary alloc] init];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    //    [dictListOfPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    //    [dictListOfPost setObject:@"0" forKey:KEYPAGEINDEX];
    
    if(btn.tag==1)
    {
        //        [dictListOfPost setObject:@"rating" forKey:@"type"];
        strType=@"rating";
    }
    else if (btn.tag==2)
    {
        //        [dictListOfPost setObject:@"recent" forKey:@"type"];
        strType=@"Most recent";
    }
    else if (btn.tag==3)
    {
        //        [dictListOfPost setObject:@"popularity" forKey:@"type"];
        strType=@"Likes";
    }
//    strCategoryName=@"all";

    //    [SVProgressHUD show];
    //    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILISTOFPOST method:@"POST" data:dictListOfPost withImages:nil withVideo:nil];
    arrListOfPost=[[NSMutableArray alloc] init];
    tblHomePost.hidden = YES;
    [tblHomePost reloadData];
    nextPage=0;
    resumeVideoCount = 0;
    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
    [viewSortPopUp removeFromSuperview];
}
- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    
    NSLog(@"movieFinishedCallback");
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        // Dismiss the view controller
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)downloadDoneForUrl:(NSString*)strUrl indexAt:(int)index
{
        //NSLog(@"queue Path : %@",strUrl);

    NSLog(@"downloadDoneForUrl");

    if (IsPlayingAll == YES)
    {
        
        //if (maxPlayedElement - playingCount >= 2 && queuePlayer !=nil && strUrl != nil && queuePlayer.items.count >=2)
        //{
             __block NSString *strUrlForBlock = [strUrl substringFromIndex:6];
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
                AVPlayerItem *playerAllItem1;
                playerAllItem1 = [AVPlayerItem playerItemWithURL: [NSURL fileURLWithPath:strUrlForBlock]];
                
                
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(didEndVideoPlaying:)
                                                             name: AVPlayerItemDidPlayToEndTimeNotification
                                                           object: playerAllItem1];
                
                [queuePlayer insertItem:playerAllItem1 afterItem:[queuePlayer.items lastObject]];
                
                
                maxPlayedElement = maxPlayedElement +1 ;
                
                
            });

        //}
    }
    
    //NSLog(@"CountVideo = %d",CountVideo);
    

    //Print Toast Messages
//    NSString *strMessage = [NSString stringWithFormat:@"%d video downloaded",index+1];
//    
//    if (IsPlayingAll == YES) {
//        [objPlayAllOverlayVC.view makeToast:strMessage];
//    }
//    else {
//        [self.view makeToast:strMessage];
//    }
//
    CountVideo =  index+1;
    [self downloadVideo];

}

// called when category pop up open and download gets Failed
-(void)downloadFailedWithCategory {
    
    [self downloadFailedForUrl];
}

-(void)downloadFailedForUrl{
   
    NSLog(@"downloadFailedForUrl");
    

    for (int i = 0; i<arrListOfPost.count; i++)
    {
        NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
        //NSLog(@"strPostID = %@",strPostID);
        if ([APPDELEGATE checkIfVideoExists:strPostID])
        {
            //NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            //NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strPostID]];
            //[arrURl addObject:savedVideoPath];
            //NSLog(@"arrURl = %@",arrURl);
        }else
        {
            
//            NSString *strMessage = [NSString stringWithFormat:@"%d video download Failed",i+1];
//            
//            if (IsPlayingAll == YES) {
//                [objPlayAllOverlayVC.view makeToast:strMessage];
//            }
//            else {
//                [self.view makeToast:strMessage];
//            }

            
            CountVideo = i;
        
            break;
        }
    }
    
    [self downloadVideo];
}

#pragma mark - Cache Video From Server Method

-(void)downloadVideo // kandhal
{
    NSLog(@"downloadVideo");
    //NSLog(@"countVideo = %ld",(long)CountVideo);
    if (IsPlayingAll == YES)
    {
        //NSLog(@"CountVideo = %d",CountVideo);
        
        if (CountVideo < arrListOfPost.count)
        {
           
            [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrListOfPost];
            
        }
        else
        {
            
//            if (nextPage == 0) {
//                isAllVideoDownload = TRUE;
//                CountVideo = 0;
//            }
//            else {
//                [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
//            }
            
            //CountVideo = 0;
        
        }
    }
    else
    {

        //NSLog(@"CountVideo = %d",CountVideo);
        if(CountVideo<arrListOfPost.count)
        [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrListOfPost];
        
    }
}
#pragma mark - Fill Cached Video Url Method

-(void)fillCachedVideoURL
{
    //NSLog(@"fillCachedVideoURL");
    arrURl = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<arrListOfPost.count; i++)
    {
        NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
        //NSLog(@"strPostID = %@",strPostID);
        if ([APPDELEGATE checkIfVideoExists:strPostID])
        {
            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strPostID]];
            [arrURl addObject:savedVideoPath];
             //NSLog(@"arrURl = %@",arrURl);
        }else
        {
            break;
        }
    }
}

-(void)getCountOfvideotoDownload
{
    
    NSMutableArray *ArrData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<arrListOfPost.count; i++)
    {
        NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
        
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

#pragma mark - Play All Video Methods

- (IBAction)actionPlayAllVideo:(id)sender
{

    if (arrURl.count > 0 ) {
        //NSLog(@"actionPlayAllVideo");
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [avPlayer pause];
        IsPlayingAll = YES;
        if (!playerViewController)
            [self removeAvPlayerReference];
        
        [ServerConnection sharedConnection].isPlaying= IsPlayingAll;
    }
    
    [self fillCachedVideoURL];
    if (resumeVideoCount < arrListOfPost.count)
    {
        playingCount = resumeVideoCount;
        
    }else
    {
        resumeVideoCount = 0;
        playingCount = 0;
    }
    //NSLog(@"playingCount = %d",playingCount);
    
    if(arrListOfPost.count>0)
    {
        
        if (arrURl.count > 0)
        {
            
            [queuePlayer removeAllItems];
            
            NSMutableArray *arrPlayerItem;
            AVPlayerItem *playerAllItem;
            
            arrPlayerItem=[[NSMutableArray alloc] init];
            
        
            queuePlayer = [[AVQueuePlayer alloc] init];
            // Check Weather All Video watched by user
            
            for(int i=resumeVideoCount;i<arrURl.count;i++)
            {
                
                
                NSLog(@"i = %d and Play with URL : %@", i,[arrURl objectAtIndex:i]);
                
                AVAsset *asseitem = [AVAsset assetWithURL:[NSURL fileURLWithPath:[arrURl objectAtIndex:i]]];
                playerAllItem = [AVPlayerItem playerItemWithAsset:asseitem];

            
                [queuePlayer insertItem:playerAllItem afterItem:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(didEndVideoPlaying:)
                                                             name: AVPlayerItemDidPlayToEndTimeNotification
                                                           object: playerAllItem];
                
            }
            

            maxPlayedElement =(int)[queuePlayer.items count];
            playedCount=1;
            
            // queuePlayer = [AVQueuePlayer queuePlayerWithItems:arrPlayerItem];
            if (playerViewController)
            {
                
                NSLog(@"Repeat : %ld",(long)playingCount);
                
                [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];

                playerViewController.player = queuePlayer;
                [queuePlayer play];
                [queuePlayer setVolume:7.0f];
                
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
                
                //NSLog(@"play all start ");
                
                
                [self presentViewController:playerViewController animated:YES completion:nil];
                [queuePlayer play];
                [queuePlayer setVolume:7.0f];
                
                // adding overlayview which contains like,description and location components.
                objPlayAllOverlayVC = [STORYBOARD instantiateViewControllerWithIdentifier:@"PlayAllOverlayVC"];
                objPlayAllOverlayVC.delegate = self;
                
                objPlayAllOverlayVC.view.frame = CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y, self.view.window.frame.size.width, self.view.window.frame.size.height);
                [self.view.window addSubview:objPlayAllOverlayVC.view];
                
                NSLog(@"Start : %ld",(long)playingCount);
                
                [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];
            }
            
            
//            //For finding total count of video which is in Cache - By Paras - 2016/08/03
//            NSUInteger totalCount = 0;
//            for (int i = 0; i<arrListOfPost.count; i++)
//            {
//                NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
//                
//                if ([APPDELEGATE checkIfVideoExists:strPostID])
//                {
//                    totalCount++;
//                }
//            }
//            
//            if (totalCount == arrListOfPost.count) {
//                
//                if (nextPage == 0) {
//                    CountVideo = 0;
//                }
//                else {
//                    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
//                }
//            }
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
    
    if([queuePlayer.items lastObject] !=[notification object] && playedCount < maxPlayedElement && playingCount < arrListOfPost.count)
    {
        
        NSLog(@"called notification %@",notification);
        
        //NSLog(@"called notification %d",playingCount);
        
        //NSLog(@" inner Value of i is :%d",playedCount);
        playedCount++;  //2 at end of first video
        resumeVideoCount++; //1 at end of first video
        playingCount++; //1 at end of first video
        
        if (isAllVideoDownload == FALSE) {
         
            NSUInteger totalCount = 0;
            for (int i = 0; i<arrListOfPost.count; i++)
            {
                NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
                
                if ([APPDELEGATE checkIfVideoExists:strPostID])
                {
                    totalCount++;
                }
            }
            
            if (totalCount == arrListOfPost.count) {
                
                if (nextPage == 0) {
                    isAllVideoDownload =  TRUE;
                    //CountVideo = 0;
                }
                else {
                    IsPlayingAll = YES;
                    [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
                }
            }
            
        }

       
        NSLog(@"post id : %@",[[arrListOfPost objectAtIndex:playingCount] objectForKey:KEYPOSTID]);
        if (playingCount < arrListOfPost.count)
        {
            [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];
        }
        
        //NSLog(@"completed update data");
        
    }
    else
    {
        resumeVideoCount = 0;
        playingCount = 0;
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        
        [self actionPlayAllVideo:nil];
        
        //For finding total count of video which is in Cache - By Paras - 2016/08/03
//        NSUInteger totalCount = 0;
//        for (int i = 0; i<arrListOfPost.count; i++)
//        {
//            NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
//            
//            if ([APPDELEGATE checkIfVideoExists:strPostID])
//            {
//                totalCount++;
//            }
//        }
//        
//        if (totalCount == arrListOfPost.count) {
//            
//            if (nextPage == 0) {
//                CountVideo = 0;
//            }
//            else {
//                [self GetAllPost:strCategoryName type:strType pageIndex:nextPage showHud:YES];
//            }
//        }
    }
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

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    NSMutableDictionary *dictPlace=[[NSMutableDictionary alloc] init];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"place"] forKey:@"place"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"city"] forKey:@"city"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"country"] forKey:@"country"];
    
    [self performSegueWithIdentifier:@"placeSegue" sender:dictPlace];
}
#pragma mark - Stop Playing Methods

-(void)donePlayer
{
//    for (int n =playedCount; n<[queuePlayer items].count; n++)
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
    //NSString *strResumeCount = [NSString stringWithFormat:@"%d",resumeVideoCount];
   
    if ([avPlayer.currentItem isPlaybackLikelyToKeepUp] == YES)
    {
        [tblHomePost reloadData];

    }
    NSLog(@"%d",resumeVideoCount);
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    IsPlayingAll = NO;
    [ServerConnection sharedConnection].isPlaying = IsPlayingAll;

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    
}
#pragma mark - Like Dislike While Playing Video Methods

-(void)actionLike
{
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"likebyme"]];
    if([strLike isEqualToString:@"0"])
    {
        [dictLikeDislike setObject:@"like" forKey:@"action"];
        imgViewLikeDislike.image = [UIImage imageNamed:@"icn_tumbup_sel"];
        //        [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup_sel"] forState:UIControlStateNormal];
        
    }
    else
    {
        imgViewLikeDislike.image = [UIImage imageNamed:@"icn_tumbup"];
        [dictLikeDislike setObject:@"dislike" forKey:@"action"];
        //        [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup"] forState:UIControlStateNormal];
        
    }
    
    //    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILIKEDISLIKEPOSTALBUM method:@"POST" data:dictLikeDislike withImages:nil withVideo:nil];
    
}

#pragma mark - Oreintation Changed Method
- (void) orientationChanged:(NSNotification *)note
{
}
//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    NSLog(@"HURRAY...............................");
//    return [self.navigationController preferredInterfaceOrientationForPresentation];
//}
//- (void)playVideo:(NSString*)aVideoUrl
//{
//    // Initialize the movie player view controller with a video URL string
//
//
//    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:aVideoUrl]];
//
//    // Remove the movie player view controller from the "playback did finish" notification observers
//    [[NSNotificationCenter defaultCenter] removeObserver:playerVC
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:playerVC.moviePlayer];
//
//    // Register this class as an observer instead
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(movieFinishedCallback:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:playerVC.moviePlayer];
//
//    // Set the modal transition style of your choice
//    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//
//    // Present the movie player view controller
//    [self presentModalViewController:playerVC animated:YES];
//
//    // Start playback
//    [playerVC.moviePlayer prepareToPlay];
//    [playerVC.moviePlayer play];
//}
//
//- (void)movieFinishedCallback:(NSNotification*)aNotification
//{
//    // Obtain the reason why the movie playback finished
//    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
//
//    // Dismiss the view controller ONLY when the reason is not "playback ended"
//    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
//    {
//        MPMoviePlayerController *moviePlayer = [aNotification object];
//
//        // Remove this class from the observers
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                      object:moviePlayer];
//
//        // Dismiss the view controller
//        [self dismissModalViewControllerAnimated:YES];
//    }
//}


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


//- (IBAction)actionComment:(id)sender
//{
//
//    [self performSegueWithIdentifier:@"CommentSegue" sender:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"post_id"]];
//}

- (IBAction)actionAddToAlbum:(id)sender
{
    AlbumSelectionVC *objAlbumSelection = [STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumSelectionVC"];
    [[APPDELEGATE window].rootViewController addChildViewController:objAlbumSelection];
    objAlbumSelection.view.alpha = 0.0;
    [[APPDELEGATE window].rootViewController.view addSubview:objAlbumSelection.view];
    [UIView animateWithDuration:0.5 animations:^{
        objAlbumSelection.view.alpha = 1.0;
    }];
    objAlbumSelection.strPostId=[[arrListOfPost objectAtIndex:playingCount] objectForKey:KEYPOSTID];
    objAlbumSelection.shouldAddVideoToAlbum=YES;
    objAlbumSelection.shouldAddVideoToAlbum=YES;
    objAlbumSelection.videoDelegate=self;
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
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:@"video"]]] options:NSDataReadingUncached error:nil];
        [self shareOnTwitter:videoData title:[[arrListOfPost objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:@"post_description"]];
    }
    else
    {
        NSMutableDictionary *dictReportAbuse=[[NSMutableDictionary alloc] init];
        [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictReportAbuse setObject:[[arrListOfPost objectAtIndex:viewInnerShareAndReportPopUp.tag] objectForKey:KEYPOSTID] forKey:KEYPOSTID];
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIREPORTABUSE method:@"POST" data:dictReportAbuse withImages:nil withVideo:nil];
    }
    [viewShareAndReportPopUp removeFromSuperview];
}
- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController
{
    
}
#pragma mark - Dead Code Methods

- (IBAction)actionLike:(id)sender
{
    NSMutableDictionary *dictLikeDislike =[[NSMutableDictionary alloc] init];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictLikeDislike setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictLikeDislike setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"likebyme"]];
    if([strLike isEqualToString:@"0"])
    {
        [dictLikeDislike setObject:@"like" forKey:@"action"];
        imgViewLikeDislike.image = [UIImage imageNamed:@"icn_tumbup_sel"];
        //        [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup_sel"] forState:UIControlStateNormal];
        
    }
    else
    {
        imgViewLikeDislike.image = [UIImage imageNamed:@"icn_tumbup"];
        [dictLikeDislike setObject:@"dislike" forKey:@"action"];
        //        [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup"] forState:UIControlStateNormal];
        
    }
    
    //    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APILIKEDISLIKEPOSTALBUM method:@"POST" data:dictLikeDislike withImages:nil withVideo:nil];
    
}


- (IBAction)actionDonePlayer:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    //NSString *strResumeCount = [NSString stringWithFormat:@"%d",resumeVideoCount];
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    IsPlayingAll = NO;
    [ServerConnection sharedConnection].isPlaying = IsPlayingAll;

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    _viewOverlyPlayer.hidden = YES;

    
}

- (IBAction)actionBack:(id)sender
{
    [APPDELEGATE clearCachedDirectory];
    [[ServerConnection sharedConnection] stopDownloadFor:strMainCategory];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionPostDetail:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    //        NSString *placeName=[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"place"];
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    _viewOverlyPlayer.hidden = YES;
    NSMutableDictionary *dictPlace=[[NSMutableDictionary alloc] init];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"place"] forKey:@"place"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"city"] forKey:@"city"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"country"] forKey:@"country"];
    
    [self performSegueWithIdentifier:@"placeSegue" sender:dictPlace];
}
- (void)handleDismissDoubleTap:(UIGestureRecognizer*)tap
{
    
    [UIView animateWithDuration:0.4 animations:^{
        
        if (_upperView.frame.origin.y == -40)
        {
            iSOvelayViewShow = YES;
            _upperView.frame=CGRectMake(_upperView.frame.origin.x, 0,_upperView.frame.size.width ,_upperView.frame.size.height);
            [_upperView layoutIfNeeded];
            _lowerView.frame=CGRectMake(_lowerView.frame.origin.x, _overlaySubView.frame.size.height-40,_lowerView.frame.size.width ,_lowerView.frame.size.height);
            [_lowerView layoutIfNeeded];
        }
        else
        {
            iSOvelayViewShow = NO;
            _upperView.frame=CGRectMake(_upperView.frame.origin.x, -40,_upperView.frame.size.width ,_upperView.frame.size.height);
            [_upperView layoutIfNeeded];
            _lowerView.frame=CGRectMake(_lowerView.frame.origin.x, _overlaySubView.frame.size.height+40,_lowerView.frame.size.width ,_lowerView.frame.size.height);
            [_lowerView layoutIfNeeded];
            
        }
    }];
    
}


@end
