//
//  ProfileVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()
{
    NSMutableDictionary * dictUserDetails;
    NSMutableArray *arrListOfPost;
    NSMutableArray *arrListOfAlbum;
    UILabel *messageLabel;
    NSInteger selectedPlayIndex;
    //    AVPlayer *avPlayer;
    AVPlayerItem *playerItem;
    AVPlayerLayer *layer;
    
    
    NSMutableArray *arrURl;// kandhal
    AVPlayerViewController *playerViewController;
    PlayAllOverlayVC *objPlayAllOverlayVC;
    int CountVideo;
    int playingCount;
    int playedCount;
    int maxPlayedElement;
    int  resumeVideoCount;
    AVQueuePlayer *queuePlayer;
    BOOL IsPlayingAll;
    
    BOOL isAllVideoDownload;
}
@end

@implementation ProfileVC

@synthesize btnSelectIndex,avPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isAllVideoDownload = FALSE;
    [self SetInitialtext];
   
    resumeVideoCount= 0;
    
    messageLabel = [[UILabel alloc] init];
    _strOtherUserID=[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UpdateCommentCount:)
                                                 name:UPDATECOMMENTCOUNTNOTIFICATION object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [APPDELEGATE myTab].tabBar.hidden=NO;
    [APPDELEGATE imagefooter].hidden=NO;
    
    [self.navigationController setNavigationBarHidden:YES];
    
#pragma mark -  Hide PopupViewEditProfile
    self.PopupViewEditProfile.hidden = YES;
    
    [self registerForKeyboardNotifications];
    [self GetUserDetails];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"User Profile Screen"];
    [APPDELEGATE setDropOffScreen:@"User Profile Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
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
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        @catch (NSException * __unused exception)
        {
            
            
        }
        playerItem=nil;
        avPlayer=nil;
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Set text to Text Field and Image to button
-(void)SetInitialtext {
    
    [self setupAlertCtrl];
    
    self.tblProfileList.backgroundColor = [UIColor clearColor];
    self.tblProfileList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.btnSelectIndex = 1;
}


-(void)GetUserDetails{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dict setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dict setObject:_strOtherUserID forKey:@"other_user_id"];
//    -user_id
//    -other_user_id
//    -auth_token
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIUSERDETAILS method:@"POST" data:dict withImages:nil withVideo:nil];
}
#pragma mark -  Open alertController for Browse Image
- (void) setupAlertCtrl
{
    self.alertCtrl = [UIAlertController alertControllerWithTitle:ALERT_SELECT_PROFILE_PIC
                                                         message:nil
                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    //Create an action
    UIAlertAction *camera = [UIAlertAction actionWithTitle:ALERT_CAMERA
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self handleCamera];
                             }];
    UIAlertAction *imageGallery = [UIAlertAction actionWithTitle:ALERT_SELECT_FROM_GALLERY
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [self handleImageGallery];
                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:ALERT_CANCEL
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    //Add action to alertCtrl
    [self.alertCtrl addAction:camera];
    [self.alertCtrl addAction:imageGallery];
    [self.alertCtrl addAction:cancel];
    
    
}


#pragma mark -  Action for Choose Image
- (IBAction)actionChooseProfileImage:(id)sender {
    
    [self presentViewController:self.alertCtrl animated:YES completion:nil];
}

#pragma mark -  Handle camera for Profile Picture
- (void)handleCamera
{
#if TARGET_IPHONE_SIMULATOR
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APPNAME
                                                                   message:ALERT_CAMERA_UNAVAILABLE
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:ALERT_OK
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                         {
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
#elif TARGET_OS_IPHONE
    //Some code for iPhone
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing=YES;
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
#endif
}

#pragma mark -  Handle Gallery for Profile Picture
- (void)handleImageGallery
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing=YES;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        UIImage   *userProfileImg=[info objectForKey:UIImagePickerControllerEditedImage];
        //        imgUserProfile.image=userProfileImg;
        
        
        userProfileImg =[Constants imageWithImage:[info objectForKey:UIImagePickerControllerEditedImage] scaledToSize:DefaultProfileImageSize];
        userProfileImg = [Constants scaleAndRotateImage:userProfileImg andMaxResolution:0];
        
        if (!userProfileImg)
        {
            return;
        }
        
        // Adjusting Image Orientation
        NSData *data = UIImagePNGRepresentation(userProfileImg);
        UIImage *tmp = [UIImage imageWithData:data];
        userProfileImg = [UIImage imageWithCGImage:tmp.CGImage scale:userProfileImg.scale orientation:userProfileImg.imageOrientation];
        
        
        
        //          [_btnProfilePic setImage:selectedImage forState:UIControlStateNormal];
        
        NSMutableDictionary *dictProfilePicture = [[NSMutableDictionary alloc]initWithObjectsAndKeys:userProfileImg,@"user_image",nil];
        NSMutableDictionary *dictEditProfile=[[NSMutableDictionary alloc] init];
        [dictEditProfile setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictEditProfile setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        //        [dictEditProfile setObject:result forKey:@"username"];
        
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIEDITPROFILE method:@"POST" data:dictEditProfile withImages:dictProfilePicture withVideo:nil];
        
        
    }];
    
}



#pragma mark - Action for Navigate to Lokouts Screen
- (IBAction)actionTextLookouts:(id)sender {
    
    [self performSegueWithIdentifier:@"LookoutsSegue" sender:_strOtherUserID];
    
}

#pragma mark - Action for show Upload Album and show album List
- (void)actionList:(id)sender
{
    btnSelectIndex = [sender tag];
    UIButton *btn=(UIButton *)sender;
    btn.selected=YES;
    
    if (btn.tag==1)
    {
        UIButton *btn=(UIButton *)[self.view viewWithTag:2];
        [btn setSelected:NO];
    }
    else
    {
        UIButton *btn=(UIButton *)[self.view viewWithTag:1];
        [btn setSelected:NO];
    }
    [self.tblProfileList reloadData];
    
}

- (IBAction)actionAlbumClicked:(id)sender
{


    AlbumListingVC *albumListVC = (AlbumListingVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumListingVC"];
    albumListVC.strOtherUserID=_strOtherUserID;
    [self.navigationController pushViewController:albumListVC animated:YES];


//    AlbumListingVC *albumListVC = (AlbumListingVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumListingVC"];
//    [self.navigationController pushViewController:albumListVC animated:YES];
    
//    [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in next milestone."];
}


#pragma mark - Action on Edit button for username
- (void)editUserName:(id)sender {
    
#pragma mark - Show PopupViewEditProfile
    self.PopupViewEditProfile.hidden = NO;
    
    
    self.txtUserName.text = [NSString stringWithFormat:@"%@",[dictUserDetails objectForKey:@"username"]];
    
    [self.txtUserName becomeFirstResponder];
}


#pragma mark - Action for ok button on Popup View
- (IBAction)actionPopupOk:(id)sender {
    
    NSString* result = [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([result length] == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:APPNAME
                                                                       message:ALERTNAMEBLANK
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:ALERT_OK
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UIKeyboardDidHideNotification" object:self];
        
        //         -user_id
        //        -username
        //        -email
        //        -user_image
        //        -auth_token
        
        NSMutableDictionary *dictEditProfile=[[NSMutableDictionary alloc] init];
        [dictEditProfile setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
        [dictEditProfile setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
        [dictEditProfile setObject:result forKey:@"username"];
        
        [SVProgressHUD show];
        [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIEDITPROFILE method:@"POST" data:dictEditProfile withImages:nil withVideo:nil];
        
        [self.txtUserName resignFirstResponder];
        
        
#pragma mark - Hide PopupViewEditProfile
        self.PopupViewEditProfile.hidden = YES;
        
        self.lblUserName.text = [NSString stringWithFormat:@"%@",self.txtUserName.text];
        
    }
    
}

#pragma mark - Action for Cancel button on Popup View
- (IBAction)actionPopupCancel:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UIKeyboardDidHideNotification" object:self];
    
    [self.txtUserName resignFirstResponder];
    
#pragma mark - Hide PopupViewEditProfile
    self.PopupViewEditProfile.hidden = YES;
    
}

#pragma mark - Action for Navigate to Settings Screen
- (IBAction)actionSettings:(id)sender {
    
    [self performSegueWithIdentifier:@"SettingsSegue" sender:nil];
}

#pragma mark - Table Datasource and delegate

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    messageLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    if (btnSelectIndex==1 ? [dictUserDetails objectForKey:@"albums"] : [dictUserDetails objectForKey:@"posts"])
    {
        messageLabel.text=@"";
        return 2;
    }
    else
    {
        // Display a message when the table is empty
        NSString *str;
        //        btnSelectIndex=1?str=@"No post found":str=@"No album found";
        if (btnSelectIndex==1) {
            str=@"No post found";
        }
        else {
            str=@"No album found";
        }
        messageLabel.text = str;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return 2;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==0)
    {
        return 0;
    }
    else
    {
        if (btnSelectIndex == 1)
        {
            return 39;
        }
        else {
            return 0.0;
        }
        
    }
    
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString * CellIdentifier = @"PlayAllVideoCell";
    PlayAllVideoCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [headerView.btnPlayAllVideo  addTarget:self action:@selector(playAllVideo) forControlEvents:UIControlEventTouchUpInside];
    if (headerView == nil)
    {
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return headerView;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return 1;
    }
    else
    {
        if (btnSelectIndex==1) {
            return [arrListOfPost count];
        }
        else if (btnSelectIndex==2){
            return [arrListOfAlbum count];
        }
        return 1;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section==0)
    {
        return 200;
    }
    else
    {
        if (btnSelectIndex == 1)
        {
            return 443;
        }
        else {
            return 60;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        static NSString *cellID =  @"UserProfileTableViewCell";
        
        UserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil)
        {
            cell = [[UserProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [cell.btnEdit addTarget:self action:@selector(editUserName:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.btnAlbumsList addTarget:self action:@selector(actionList:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnShootIpsList addTarget:self action:@selector(actionList:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([dictUserDetails objectForKey:@"total_post_count"]) {
            cell.lblShootIPsCount.text=[NSString stringWithFormat:@"%@",[dictUserDetails objectForKey:@"total_post_count"]];

        }
        if ([dictUserDetails objectForKey:@"total_lookouts_count"]) {
            cell.lblLookoutsCount.text=[NSString stringWithFormat:@"%@",[dictUserDetails objectForKey:@"total_lookouts_count"]];

        }
        if ([dictUserDetails objectForKey:@"total_album_count"]) {
            cell.lblAlbumCount.text=[NSString stringWithFormat:@"%@",[dictUserDetails objectForKey:@"total_album_count"]];

        }
        cell.lblUserName.text=[dictUserDetails objectForKey:@"username"];
        NSURLRequest *userProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dictUserDetails objectForKey:@"user_image"]]];
        UIImage *placeholderImage = [UIImage imageNamed:@"user_placeholder_icon"];
        
        [cell.imgUserProfilePic setImageWithURLRequest:userProfileRequest
                                      placeholderImage:placeholderImage
                                               success:nil
                                               failure:nil];

        return cell;
    }
    
    else{
        if (btnSelectIndex == 1)
        {
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
            
            [cell ConfigureCell:[NSString stringWithFormat:@"%@",[dictPost objectForKey:@"rating"]] postDict:dictPost];
            
            
            
            [cell.btnReportOrEdit addTarget:self action:@selector(btnReportOrEditAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
//            UITapGestureRecognizer *tapRecognizerUsername = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userNameTapped:)];
//            cell.lblUserName.userInteractionEnabled=YES;
//            [cell.lblUserName addGestureRecognizer:tapRecognizerUsername];
            
            
            cell.lblUserName.tag=cell.btnReportOrEdit.tag=cell.btnComment.tag=cell.btnTitle.tag=cell.btnLikeDisLike.tag=cell.btnAddVideoToAlbum.tag=cell.btnPlayVideo.tag=cell.btnMap.tag=indexPath.row;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            return cell;
        }
        
        else {
            static NSString *cellID =  @"ProfileAlbumCellIdentifier";
            
            ProfileAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (cell == nil)
            {
                cell = [[ProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            
            NSDictionary *dictAlbum = [arrListOfAlbum objectAtIndex:indexPath.row];
            cell.lblAlbumName.text = [NSString stringWithFormat:@"%@",[dictAlbum objectForKey:@"album_title"]];
            
            cell.imgAlbumIcon.image = [UIImage imageNamed:@"img_01"];
            
            
            
            NSURLRequest *userProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dictAlbum objectForKey:@"album_thumb_image"]]];
            UIImage *placeholderImage = [UIImage imageNamed:@"user_placeholder_icon"];
            
            [cell.imgAlbumIcon setImageWithURLRequest:userProfileRequest
                                     placeholderImage:placeholderImage
                                              success:nil
                                              failure:nil];
            
            
#pragma mark -  Make Image Rounded -
            cell.imgAlbumIcon.layer.cornerRadius = cell.imgAlbumIcon.frame.size.width / 2;
            cell.imgAlbumIcon.layer.borderWidth = 1.0f;
            cell.imgAlbumIcon.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.imgAlbumIcon.clipsToBounds = YES;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
        }
    }
}

#pragma mark - Cache Video From Server Method

-(void)downloadVideo // kandhal
{
    //download the file in a seperate thread.
    //    [self fillDocURlArr];
    if (IsPlayingAll == YES)
    {
        if (CountVideo < arrListOfPost.count)
        {
            [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrListOfPost];
            
        }else
        {
            //CountVideo = 0;
        }
    }else
    {      if(CountVideo<arrListOfPost.count)
        [[ServerConnection sharedConnectionWithDelegate:self] downloadVideo:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"video"] videoName:[[arrListOfPost objectAtIndex:CountVideo] objectForKey:@"post_id"] indexAt:CountVideo arrayUrls:arrListOfPost];
    }
}

#pragma mark - Fill Cached Video Url Method

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
-(void)fillCachedVideoURL
{
    arrURl = [[NSMutableArray alloc] init];
    for (int i = 0; i<arrListOfPost.count; i++)
    {
        NSString *strPostID = [[arrListOfPost objectAtIndex:i] objectForKey:@"post_id"];
        
        if ([APPDELEGATE checkIfVideoExists:strPostID])
        {
            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strPostID]];
            [arrURl addObject:savedVideoPath];
        }else
        {
            break;
        }
    }
}

#pragma mark -  Play All Video -

-(void)playAllVideo
{
    /*[avPlayer pause];
    if (!playerViewController)
    [self removeAvPlayerReference];
   
    IsPlayingAll = YES;
    
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

    
    if (resumeVideoCount < arrListOfPost.count)
    {
        playingCount = resumeVideoCount;
        
    }else
    {
        resumeVideoCount = 0;
        playingCount = 0;
    }
    if(arrListOfPost.count>0)
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
            //                queuePlayer = [AVQueuePlayer queuePlayerWithItems:arrPlayerItem];
            if (playerViewController) {
                
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
                
            }
            
            //[playerViewController addChildViewController:objPlayAllOverlayVC];
            
            // updating data to overlayviewcontroller
            [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];
            
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
    
//    @try
//    {
//        
//        [queuePlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//        [queuePlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//        [queuePlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
//        // [[NSNotificationCenter defaultCenter] removeObserver:self];
//        
//    }
//    @catch (NSException * __unused exception)
//    {
//        
//        
//    }
//    @finally {
//        //        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//        
//    }
//    
    if([queuePlayer.items lastObject] !=[notification object] && playedCount < maxPlayedElement&& playingCount < arrListOfPost.count)
    {
        NSLog(@" inner Value of i is :%d",playedCount);
        playedCount++;
        playingCount++;
        resumeVideoCount++;
        
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
                
                isAllVideoDownload =  TRUE;
            }
            
        }

        
        NSLog(@"post id : %@",[[arrListOfPost objectAtIndex:playingCount] objectForKey:KEYPOSTID]);
        if (playingCount < arrListOfPost.count)
        {
            [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];

        }
        
        NSLog(@"completed update data");
        
    }
    else
    {
        //   NSLog(@"Exist");
        
//        NSString *strResumeCount = [NSString stringWithFormat:@"%d",resumeVideoCount];
      
        resumeVideoCount = 0;
        playingCount = 0;
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self playAllVideo];
//        IsPlayingAll = NO;
//        [ServerConnection sharedConnection].isPlaying = IsPlayingAll;
//        
//        playingCount = 0;
//        playedCount=1;
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//        [playerViewController dismissViewControllerAnimated:YES completion:nil];
//        [objPlayAllOverlayVC.view removeFromSuperview];
//        queuePlayer = nil;
//        
//        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
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
            NSLog(@"downloaded video come for url%@",strUrl.description);
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
    
    [playerViewController dismissViewControllerAnimated:YES completion:nil];
    playerViewController = nil;
    queuePlayer = nil;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    
    NSMutableDictionary *dictPlace=[[NSMutableDictionary alloc] init];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"place"] forKey:@"place"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"city"] forKey:@"city"];
    [dictPlace setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"country"] forKey:@"country"];
    
    PlaceVC *objPlace = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
    objPlace.dictPlaceDetail=dictPlace;
    [self.navigationController pushViewController:objPlace animated:YES];
    
    //        NSString *placeName=[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"place"];
  
    
//    PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
//    placeVC.fromWhere=@"Album";
//    placeVC.strTitle=[NSString stringWithFormat:@"%@",[[arrListOfAlbum objectAtIndex:playingCount] objectForKey:@"album_title"]];
//    
//    placeVC.dictPlaceDetail=[arrListOfAlbum objectAtIndex:playingCount];
//    [self.navigationController pushViewController:placeVC animated:YES];
//    [self performSegueWithIdentifier:@"placeSegue" sender:dictPlace];
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
        [_tblProfileList reloadData];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
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
    [dictLikeDislike setObject:[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"post_id"] forKey:@"id"];
    [dictLikeDislike setObject:@"post" forKey:@"type"];
    
    NSString *strLike=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:playingCount] objectForKey:@"likebyme"]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
//    if (btnSelectIndex==1)
//    {
//        [self playAllVideo];
////        [UIAlertView showAlertViewWithTitle:APPNAME message:@"Will be delivered in next milestone."];
//
//    }else
    if(btnSelectIndex==2)
    {
        PlaceVC *placeVC = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
        placeVC.fromWhere=@"Album";
        placeVC.strTitle=[NSString stringWithFormat:@"%@",[[arrListOfAlbum objectAtIndex:indexPath.row] objectForKey:@"album_title"]];
        placeVC.dictPlaceDetail=[arrListOfAlbum objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:placeVC animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        if(selectedPlayIndex==indexPath.row)
        {
            if(btnSelectIndex==1 && indexPath.row!=0)
            {
            if ([arrListOfPost count]>0) {
                VideoPostCell *cell = (VideoPostCell*)[self.tblProfileList cellForRowAtIndexPath:indexPath];
                cell.btnPlayVideo.hidden=NO;
                [layer removeFromSuperlayer];
                [avPlayer pause];
                @try
                {
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
                    [avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                }
                @catch (NSException * __unused exception)
                {
                    
                }
                playerItem=nil;
            }
            
            
        }
        }
    }
}


#pragma mark - Register for Keyboard Notifications
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

#pragma mark - DeRegister for Keyboard Notifications
- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
}

#pragma mark - keyboardWillShow
- (void) keyboardWillShow:(NSNotification *)note {
    
    if (iPhone4) {
        
        // move the view up by 90 pts
        CGRect frame = self.view.frame;
        frame.origin.y = -90;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = frame;
        }];
    }
}

#pragma mark - keyboardDidHide
- (void) keyboardDidHide:(NSNotification *)note {
    
    if (iPhone4) {
        
        // move the view back to the origin
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = frame;
        }];
    }
}
#pragma mark - Custom Action

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
    
    PlaceVC *objPlace = (PlaceVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"PlaceVC"];
    objPlace.dictPlaceDetail=dictPlace;
    [self.navigationController pushViewController:objPlace animated:YES];
    
    //    [self performSegueWithIdentifier:@"placeSegue" sender:dictPlace];
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
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException * __unused exception)
    {
        
        
    }
    playerItem=nil;
    
}

-(void)btnPlayVideoAction:(UIButton *)sender
{
    if ([[ServerConnection sharedConnection] isInternetAvailable] == YES)
    {
        @try
        {
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:1];
            VideoPostCell *cell1 = (VideoPostCell*)[_tblProfileList cellForRowAtIndexPath:indePath1];
            cell1.btnPlayVideo.hidden=NO;
            cell1.videoActivityIndicator.hidden=YES;
            [self removeAvPlayerReference];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:sender.tag inSection:1];
            VideoPostCell *cell = (VideoPostCell*)[_tblProfileList cellForRowAtIndexPath:indePath];
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
                NSLog(@"not fineee");
                NSLog(@"Error fial is %@",avPlayer.error);
            }
            else
            {
                NSLog(@"Not ready");
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
            
            NSIndexPath *indePath1=[NSIndexPath indexPathForRow:selectedPlayIndex inSection:1];
            VideoPostCell *cell = (VideoPostCell*)[_tblProfileList cellForRowAtIndexPath:indePath1];
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

-(void)btnReportOrEditAction:(UIButton *)sender
{
    UIButton *btn=(UIButton*)sender;
    NSString *userID =[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:KEYUSERID]];
    NSString *strPostId = [NSString stringWithFormat:@"%@",[[[arrListOfPost objectAtIndex:btn.tag] objectForKey:@"user_data"] objectForKey:KEYUSERID]];// kandhal
    if([userID isEqualToString:strPostId])
    {
        
        NewPostVC *newPostVC = (NewPostVC *)[STORYBOARD instantiateViewControllerWithIdentifier:@"NewPostVC"];
        newPostVC.performEdit=@"Edit";
        newPostVC.dictPostDetails=[arrListOfPost objectAtIndex:sender.tag];
        [self.navigationController pushViewController:newPostVC animated:YES];
        
        
        //   [self performSegueWithIdentifier:@"editPostSegue" sender:[arrListOfPost objectAtIndex:sender.tag]];
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
- (void)userNameTapped:(UITapGestureRecognizer*)sender {
    NSDictionary *dict=[arrListOfPost objectAtIndex:sender.view.tag];
    
    if ([[[dict objectForKey:@"user_data"] objectForKey:@"user_id"]isEqualToString:[USERDEFAULTS objectForKey:KEYUSERID]])
    {
        [APPDELEGATE myTab].selectedIndex = 4;
        if (iPhone6)
            [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_5~667h"]];
        else
            [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_5"]];
    }
    else{
        [self performSegueWithIdentifier:@"otherUserProfileSegue" sender:nil];
    }
    
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
    
    
    NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:1];
    VideoPostCell *cell = (VideoPostCell*)[_tblProfileList cellForRowAtIndexPath:indePath];
    
    cell.lblNoOfVideoShared.text=[NSString stringWithFormat:@"%@",[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] objectForKey:@"video_added_count"]];
}

#pragma mark - Server connection delegate methods -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    //NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APIUSERDETAILS])
        {
            
            dictUserDetails =[[NSMutableDictionary alloc] initWithDictionary:[dictData objectForKey:@"data"]];
            arrListOfPost=[[NSMutableArray alloc] initWithArray:[dictUserDetails objectForKey:@"posts"]];
            arrListOfAlbum = [[NSMutableArray alloc] initWithArray:[dictUserDetails objectForKey:@"albums"]];
            if (arrListOfPost.count > 0)
            {
                [[ServerConnection sharedConnection] stopDownloadFor:@"ProfileVC"];
                [self getCountOfvideotoDownload];
            }else
            {
                [_tblProfileList reloadData];
            }
        }
        
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
            [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];

            // NSLog(@"dictData = %@",dictData);
            NSInteger indexOfMatchingDictionary = [arrListOfPost indexOfObjectPassingTest:^BOOL(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
                return [[obj valueForKey:@"post_id"] isEqual:[[dictData objectForKey:@"data"] objectForKey:@"post_id"]
                        ];
            }];
            
            NSMutableDictionary *tempDict=[[arrListOfPost objectAtIndex:indexOfMatchingDictionary] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"is_like"]] forKey:@"likebyme"];
            [tempDict setObject:[NSString stringWithFormat:@"%@",[[dictData objectForKey:@"data"] objectForKey:@"total_likes"]] forKey:@"total_likes"];
            [arrListOfPost replaceObjectAtIndex:indexOfMatchingDictionary withObject:tempDict];
            
            NSIndexPath *indePath=[NSIndexPath indexPathForRow:indexOfMatchingDictionary inSection:1];
            VideoPostCell *cell = (VideoPostCell*)[_tblProfileList cellForRowAtIndexPath:indePath];
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
            [objPlayAllOverlayVC updateData:[arrListOfPost objectAtIndex:playingCount]];

            
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Post has been successfully abused by you."];
        }
        else if ([reqURL myContainsString:APIEDITPROFILE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:@"Profile Updated successfully....."];
            [self GetUserDetails];
        }
        [_tblProfileList reloadData];
        [SVProgressHUD dismiss];
    }
    else
    {
        if([reqURL myContainsString:APIUSERDETAILS])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        else if ([reqURL myContainsString:APILIKEDISLIKEPOSTALBUM])
        {
//            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
            
        }
        else if ([reqURL myContainsString:APIREPORTABUSE])
        {
            
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}


#pragma mark - Navigation
- (void)UpdateCommentCount:(NSNotification *)note {
    //    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
    //        CommentVC *objDetail = segue.sourceViewController;
    
    NSDictionary *userInfo = note.userInfo;
    arrListOfPost= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrListOfPost), kCFPropertyListMutableContainersAndLeaves));
    
    [arrListOfPost enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        NSLog(@"post id-%@",[[obj valueForKey:@"post_id"] stringValue]);
        
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
    [_tblProfileList reloadData];
    NSLog(@"Received Notification ");
}

//-(IBAction)UnwindFromComment:(UIStoryboardSegue *)segue{
//    if ([segue.sourceViewController isKindOfClass:[CommentVC class]]) {
//        CommentVC *objDetail = segue.sourceViewController;
//        arrListOfPost= (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(arrListOfPost), kCFPropertyListMutableContainersAndLeaves));
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
//                    [obj setObject:objDetail.strCommentCount forKey:@"total_comments"];
//                }
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
//    [_tblProfileList reloadData];
//}

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
        objComment.strPostId=(NSString *)sender;
    }
    else if ([segue.identifier isEqualToString:@"mapSegue"])
    {
        MapVC *objMap = segue.destinationViewController;
        objMap.dictMap=(NSDictionary *)sender;
    }
    else if ([segue.identifier isEqualToString:@"placeSegue"])
    {
        PlaceVC *objPlaceVC = segue.destinationViewController;
        objPlaceVC.dictPlaceDetail=(NSDictionary *)sender;
    }
    else if ([segue.identifier isEqualToString:@"LookoutsSegue"])
    {
        LookoutsVC *objLookOut = segue.destinationViewController;
        objLookOut.strOtherUserID=(NSString *)sender;
    }
}


@end
