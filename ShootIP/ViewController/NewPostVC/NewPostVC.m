  
//
//  NewPostVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/13/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "NewPostVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AlbumSelectionVC.h"
#import "AddLocationVC.h"
//#import <TwitterKit/TwitterKit.h>
#import "TwitterVideoUpload.h"
#import "GAIDictionaryBuilder.h"
#import "PermissionUtility.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface NewPostVC ()
{
    NSDictionary *dictAlbumDetails;
    NSDictionary *dictCategoryDetails;
    int videoDuration;
    AVPlayer *avPlayer;
    AVPlayerItem *playerItem;
    AVPlayerLayer *layer;
}

@end

@implementation NewPostVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dictCategoryDetails = [[NSMutableDictionary alloc] init];
    dictAlbumDetails = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    [viewAddToAlbum setHidden:YES];
    [viewNewAlbumName setHidden:YES];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    
    viewRating.starImage = [UIImage imageNamed:@"icn_star_unfill"];
    viewRating.starHighlightedImage = [UIImage imageNamed:@"icn_star"];
    viewRating.maxRating = 5.0;
    viewRating.delegate = self;
    viewRating.horizontalMargin = 12;
    viewRating.editable=YES;
    viewRating.displayMode=EDStarRatingDisplayFull;
    
    
    viewRating.rating= 3.0;
#pragma mark - Edit event View details -

    if([self.performEdit isEqualToString:@"Edit"])
    {
        [SVProgressHUD show];
        btnFacebook.hidden=YES;
        btnTwitter.hidden=YES;
        videoDuration = [[_dictPostDetails objectForKey:@"video_duration"] intValue];
        lblNavBarTitle.text=@"EDIT";
        [btnCreateOrSave setTitle:@"Save" forState:UIControlStateNormal];
        [btnDeletePost setHidden:NO];
        NSLog(@"dictPostDetails %@",_dictPostDetails);
        txtPostDescription.text=[_dictPostDetails objectForKey:@"post_description"];
        viewRating.rating=[[_dictPostDetails objectForKey:@"rating"] floatValue];
        [btnAddCategory setTitle:[_dictPostDetails objectForKey:@"category_name"] forState:UIControlStateNormal];
        [btnAddLocation setTitle:[_dictPostDetails objectForKey:@"place"] forState:UIControlStateNormal];
        
        NSString *albumTitle=[NSString stringWithFormat:@"%@",[_dictPostDetails objectForKey:@"album_title"]];
        if(albumTitle.length>0)
        {
            [btnAddToAlbum setTitle:[_dictPostDetails objectForKey:@"album_title"] forState:UIControlStateNormal];
        }
        
        _objRecentPlace = [[RecentPlaces alloc]init];
        _objRecentPlace.strAddress = [_dictPostDetails objectForKey:@"address"];
        _objRecentPlace.strCity = [_dictPostDetails objectForKey:@"city"];
        _objRecentPlace.strCountry = [_dictPostDetails objectForKey:@"country"];
        _objRecentPlace.strLatitude = [_dictPostDetails objectForKey:@"latitude"];
        _objRecentPlace.strLongitude = [_dictPostDetails objectForKey:@"longitude"];
        _objRecentPlace.strName = [_dictPostDetails objectForKey:@"place"];
        _objRecentPlace.coorDinate = CLLocationCoordinate2DMake([[_dictPostDetails objectForKey:@"latitude"] floatValue],[[_dictPostDetails objectForKey:@"longitude"] floatValue]);
        
        
        [dictAlbumDetails setValue:albumTitle forKey:@"album_title"];
        [dictAlbumDetails setValue:[_dictPostDetails objectForKey:@"album_id"] forKey:@"album_id"];
        
        
        [dictCategoryDetails setValue:[_dictPostDetails objectForKey:@"category_id"] forKey:@"category_id"];
       [dictCategoryDetails setValue:[_dictPostDetails objectForKey:@"category_name"] forKey:@"category_name"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_dictPostDetails objectForKey:@"video_thumb"]]];
        [imagePlayerThumbnil setImageWithURLRequest:request
                                      placeholderImage:nil
                                               success:nil failure:nil];
        imagePlayerThumbnil.contentMode = UIViewContentModeScaleAspectFill;
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSString *urlToDownload = [_dictPostDetails objectForKey:@"video"];
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            //          NSData *urlData = [NSData dataWithContentsOfURL:url];
            NSData *urlData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:nil];
            
            if (urlData)
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"Video.mov"];
                [urlData writeToFile:filePath atomically:YES];
                
                NSURL *bundleURL = [NSURL fileURLWithPath:filePath];
                NSLog(@"bundleURL %@",bundleURL);
                
            }
            
        });
        
        
[SVProgressHUD dismiss];
//        imagePlayerThumbnil.contentMode=uiimage
    }
    else
    {
        imagePlayerThumbnil.image=[self generateThumbnail];

        lblNavBarTitle.text=@"NEW POST";
        [btnCreateOrSave setTitle:@"Create" forState:UIControlStateNormal];
        [btnDeletePost setHidden:YES];
//        NSString *path = [Constants getDocumentDirectoryPath];
//        path = [path stringByAppendingPathComponent:@"Video.mov"];
//
//        [self addTextToVideo:path atFrame:CGRectMake(0, 0, 0, 0) withText:@"Dhaval"];

    }


}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];

}

- (void)addTextToVideo:(NSString*)pstrVideoPath atFrame:(CGRect)pFrame withText:(NSString*)pstrText
{
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:pstrVideoPath] options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Audio Track
    AVMutableCompositionTrack *firstAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *arrTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    
    if (arrTracks.count > 0)
        [firstAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[arrTracks objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Video Track
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    CGSize videoSize = [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    CGRect objBounds = CGRectMake(0, 0, 0, 0);
    CGFloat fltLblYpostion = videoSize.height - ((videoSize.height * pFrame.origin.y) / objBounds.size.height);
    CGFloat fltWidth = (objBounds.size.width * videoSize.width) / pFrame.size.width;
    CGFloat fltLblXpostion = (videoSize.width - pFrame.size.width)/2;
    
    pFrame = CGRectMake(fltLblXpostion, fltLblYpostion, MIN(fltWidth,320), pFrame.size.height);
    
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = pstrText;
    titleLayer.fontSize = 22;
    titleLayer.alignmentMode = @"center";
    titleLayer.wrapped = YES;
    titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
    titleLayer.borderColor = [UIColor blackColor].CGColor;
    titleLayer.shadowOffset = CGSizeMake(0, -1);
    //    titleLayer.font = CFBridgingRetain([UIFont fontWithName:@"HelveticaNeue-Regular" size:19.0].fontName);
    
    titleLayer.alignmentMode = kCAAlignmentCenter;
    CGRect titleFrame = pFrame;
    titleFrame.size.height +=5;
//    titleLayer.frame = titleFrame;
    //    titleLayer.backgroundColor = [UIColor redColor].CGColor;
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:titleLayer];
    
    AVMutableVideoComposition* videoComp = [[AVMutableVideoComposition videoComposition] init];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];//AVAssetExportPresetPassthrough
    assetExport.videoComposition = videoComp;
    
    
    NSString *path = [Constants getDocumentDirectoryPath];
    path = [path stringByAppendingPathComponent:@"Video1.mov"];
    
    //    NSString *exportPath =[Helper getDocumentDirectoryPath:kVideoOutputFilename];
    NSString *exportPath =path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:exportPath isDirectory:nil])
    {
        NSLog(@"File doesn't exist");
    }
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = exportUrl;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        
        if (assetExport.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"session completed %@",[assetExport.outputURL absoluteString]);
            
            //            if (_completionBlock)
            //                _completionBlock(nil,YES);
        }
        else
        {
            NSLog(@"%d , Error -> %@",(int)assetExport.status,assetExport.error);
        }
    }];
    
}


- (void)exportDidFinish:(AVAssetExportSession *)session1
{
    if(session1.status == AVAssetExportSessionStatusCompleted)
        NSLog(@"session completed %@",[session1.outputURL absoluteString]);
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
//                  [UIAlertView showAlertViewWithTitle:APPNAME message:@"Video shared successfully on twitter."];
                  [KSToastView ks_showToast:@"Video shared successfully on twitter." duration:2.0f];

                  [SVProgressHUD dismiss];
                  
              }];
    if (status == FALSE)
    {
        //        [self addText:@"No Twitter account. Please add twitter account to Settings app."];
        [UIAlertView showAlertViewWithTitle:APPNAME message:@"No Twitter account. Please add twitter account to Settings app."];
        [SVProgressHUD dismiss];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Capture Video Screen"];
    [APPDELEGATE setDropOffScreen:@"Capture Video Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [viewActivityIndicator setHidden:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [Constants setTextFieldPadding:txtAlbumName paddingValue:5];
    [Constants placeholdercolorchange:txtAlbumName];
    
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],doneButton, nil]];
    txtPostDescription.inputAccessoryView = keyboardDoneButtonView;
    btnPlay.hidden=NO;
    [btnPlay setSelected:NO];
}


-(void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    if ([avPlayer respondsToSelector:@selector(setAllowsExternalPlayback:)]) {
        // iOS 6+
        avPlayer.allowsExternalPlayback = NO;
        [avPlayer pause];
        
    }
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

    avPlayer=nil;
    playerItem=nil;
    [layer removeFromSuperlayer];
}

#pragma mark - Custom methods -


-(UIImage*)generateThumbnail
{
    NSURL *videoURL;
    NSString *videoPath=[NSString stringWithFormat:@"%@/Video.mov",[Constants getDocumentDirectoryPath]];
    NSLog(@"videoPath %@",videoPath);
    videoURL=[NSURL fileURLWithPath:videoPath];
    
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:videoURL];
    CMTime time = [avUrl duration];
    videoDuration = ceil(time.value/time.timescale);
    NSLog(@"Duration of video :%d",videoDuration);
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    time = [asset duration];
    CMTime thumbTime = CMTimeMakeWithSeconds(2,10);
    time.value = 10000;
    
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:NULL error:NULL];
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];

    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    

    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    //{414, 250}
    //CGSize newSize = CGSizeMake(imagePlayerThumbnil.frame.size.width, imagePlayerThumbnil.frame.size.height);
//    CGFloat scale = [[UIScreen mainScreen]scale];
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
//    if (thumbnail.size.width>thumbnail.size.height)
//        [thumbnail drawInRect:CGRectMake(0, 0,thumbnail.size.width*newSize.height/thumbnail.size.height,newSize.height)];
//    else
//        [thumbnail drawInRect:CGRectMake(0, 0, newSize.width, thumbnail.size.height*newSize.width/thumbnail.size.width)];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    
//    return thumbnail;
    return thumbnail;
}

//-(void)playCapturedVideo:(BOOL)btnSelected
-(void)playCapturedVideo
{
//    if(btnSelected)
//    {
        [btnPlay setHidden:YES];
        NSURL *videoURL;
        NSString *videoPath=[NSString stringWithFormat:@"%@/Video.mov",[Constants getDocumentDirectoryPath]];
        [self removeAllAvPLayerReference];

        if ([self.performEdit isEqualToString:@"Edit"]) {
            videoURL=[NSURL URLWithString:[_dictPostDetails objectForKey:@"video"]];
        }
        else{
        videoURL=[NSURL fileURLWithPath:videoPath];
        }
    
        playerItem=[[AVPlayerItem alloc] initWithURL:videoURL];
        
        if(!avPlayer)
        {
            avPlayer=[[AVPlayer alloc] initWithPlayerItem:playerItem];
        }
        else
        {
            [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        }
        //        avPlayer = [AVPlayer playerWithURL:videoURL];
        layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.frame = viewVideoPreview.bounds;
        [layer layoutIfNeeded];
        [viewVideoPreview.layer addSublayer: layer];
        
        __block AVPlayer *avPlayer1=avPlayer;

        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
        NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
        [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                object:nil // any object can send
                                 queue:nil // the queue of the sending
                            usingBlock:^(NSNotification *note) {
                                // holding a pointer to avPlayer to reuse it
                                [btnPlay setSelected:NO];
                                btnPlay.hidden=NO;

                                [avPlayer1 pause];
                                [layer removeFromSuperlayer];
                            }];
        
        //    [btnPlay setHidden:YES];
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
            [viewActivityIndicator setHidden:NO];
        }
    }
//    else
//    {
//        btnPlay.hidden=NO;
//        [avPlayer pause];
////        avPlayer = nil;
//        [btnPlay setSelected:NO];
//    }
//}

-(void)resetVideo
{
    [btnPlay setSelected:NO];
    btnPlay.hidden=NO;
    [avPlayer pause];
    [layer removeFromSuperlayer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (!avPlayer)
    {
        //  NSLog(@"not avplayer");
        return;
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
            
                        [viewActivityIndicator setHidden:YES];
            //        NSLog(@"Alive");
        }
    }
    else if (object == avPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferFull"])
    {
        if (avPlayer.currentItem.playbackBufferFull)
        {
            //Your code here
            //   NSLog(@"Buffer Full");
            [avPlayer play];
        }
    }
}


-(void)removeAllAvPLayerReference
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
    @finally {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    playerItem=nil;
}

#pragma mark - KeyboardNotification Delegates -

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, kbSize.height, 0)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kbSize.height, 0)];
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view layoutIfNeeded];
}

#pragma mark - BSKeyboardControl Delegates -

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    //    [self.keyboardControls.activeField resignFirstResponder];
    [txtPostDescription resignFirstResponder];
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
    
    if ([segue.identifier isEqualToString:@"addLocationSegue"]) {
        AddLocationVC *objAddLocation = segue.destinationViewController;
        
        if (_objRecentPlace)
        {
            objAddLocation.objSelectedRecentPlace = _objRecentPlace;
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)unwindFromAddPlace:(UIStoryboardSegue *)unwindSegue
{
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[AddLocationVC class]])
    {
        AddLocationVC *objLocation=unwindSegue.sourceViewController;
        
        _objRecentPlace=objLocation.objRecentPlace;
        [btnAddLocation setTitle:_objRecentPlace.strName forState:UIControlStateNormal];
    }
}

#pragma mark - Action Delegates -

- (IBAction)actionDeletePost:(id)sender {
    [Alerts showAlertWithMessage:@"Are you sure you want to Delete the post" withBlock:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0:
            {
                [self deletePostWebCall];
            }
                break;
                
            default:
                break;
        }
    } andButtons:ALERT_OK,ALERT_CANCEL, nil];
}

- (void)createNewPostWebCall
{

    NSMutableDictionary *dictNewPost =[[NSMutableDictionary alloc] init];
    
    [dictNewPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictNewPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictNewPost setObject:txtPostDescription.text forKey:@"post_description"];
    [dictNewPost setObject:[NSNumber numberWithFloat:viewRating.rating] forKey:@"rating"];
    
    if(!([dictAlbumDetails objectForKey:@"album_id"]==nil))
    [dictNewPost setObject:[dictAlbumDetails objectForKey:@"album_id"] forKey:@"album_id"];
    [dictNewPost setObject:_objRecentPlace.strLatitude forKey:@"latitude"];
    [dictNewPost setObject:_objRecentPlace.strLongitude forKey:@"longitude"];
    [dictNewPost setObject:_objRecentPlace.strName forKey:@"place"];
    [dictNewPost setObject:_objRecentPlace.strAddress forKey:@"address"];
    
    if ([_objRecentPlace.strCity length]!=0) {
    [dictNewPost setObject:_objRecentPlace.strCity forKey:@"city"];
    }
    if ([_objRecentPlace.strCountry length]!=0) {
        [dictNewPost setObject:_objRecentPlace.strCountry forKey:@"country"];
 
    }
    
    //    [dictNewPost setObject:_objRecentPlace.strAddress forKey:@"address"];
    
    videoDuration = 5 ;
    [dictNewPost setObject:[NSNumber numberWithInt:videoDuration] forKey:@"video_duration"];
    [dictNewPost setObject:[dictCategoryDetails objectForKey:@"category_id"] forKey:@"category_id"];
    
    NSDictionary * dictVideo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"",@"video",nil];
    NSMutableDictionary * dictThumbnail = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self generateThumbnail],@"video_thumb",nil];
    
    [SVProgressHUD show];
    NSLog(@"create post dictionary : %@",dictNewPost);
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APICREATEPOST method:@"POST" data:dictNewPost withImages:dictThumbnail withVideo:dictVideo];
}


-(void)deletePostWebCall
{
    NSMutableDictionary *dictDeletePost =[[NSMutableDictionary alloc] init];
    [dictDeletePost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictDeletePost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictDeletePost setObject:[_dictPostDetails objectForKey:@"post_id"] forKey:@"post_id"];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIDELETEPOST method:@"POST" data:dictDeletePost withImages:nil withVideo:nil];
    
}
-(void)editPostWebCall
{
    NSMutableDictionary *dictEditPost =[[NSMutableDictionary alloc] init];
    
    [dictEditPost setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictEditPost setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictEditPost setObject:txtPostDescription.text forKey:@"post_description"];
    [dictEditPost setObject:[NSNumber numberWithFloat:viewRating.rating] forKey:@"rating"];
    
    if(!([dictAlbumDetails objectForKey:@"album_id"]==nil))
    [dictEditPost setObject:[dictAlbumDetails objectForKey:@"album_id"] forKey:@"album_id"];
    
    [dictEditPost setObject:_objRecentPlace.strLatitude forKey:@"latitude"];
    [dictEditPost setObject:_objRecentPlace.strLongitude forKey:@"longitude"];
    [dictEditPost setObject:_objRecentPlace.strName forKey:@"place"];
    [dictEditPost setObject:_objRecentPlace.strAddress forKey:@"address"];
    [dictEditPost setObject:_objRecentPlace.strCity forKey:@"city"];
    [dictEditPost setObject:_objRecentPlace.strCountry forKey:@"country"];
    [dictEditPost setObject:_objRecentPlace.strAddress forKey:@"address"];
    
    
    [dictEditPost setObject:[NSNumber numberWithInt:videoDuration] forKey:@"video_duration"];
    [dictEditPost setObject:[dictCategoryDetails objectForKey:@"category_id"] forKey:@"category_id"];
    
    [dictEditPost setObject:[_dictPostDetails objectForKey:@"post_id"] forKey:@"post_id"];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIEDITPOST method:@"POST" data:dictEditPost withImages:nil withVideo:nil];
    
}

- (IBAction)actionCreateOrEditPost:(id)sender
{
    NSString *strPostDescription = [txtPostDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([strPostDescription isEqualToString:@"Add Description..."])
    {
        txtPostDescription.text = @"";
        strPostDescription=@"";
    }
    
//    if ([strPostDescription length]==0)
//    {
//        [Alerts showAlertWithMessage:@"Please enter post description." withBlock:nil andButtons:ALERT_OK, nil];
//        txtPostDescription.text = @"Add Description...";
//
//        return;
//    }
    if (_objRecentPlace==nil)
    {
        [Alerts showAlertWithMessage:@"Please select location" withBlock:nil andButtons:ALERT_OK, nil];
        return;
    }
    
    if ([btnAddCategory.titleLabel.text isEqualToString:@"Add Category"])
    {
        [Alerts showAlertWithMessage:@"Please select category" withBlock:nil andButtons:ALERT_OK, nil];
        return;
    }
//    if (dictAlbumDetails.count==0)
//    {
//        [Alerts showAlertWithMessage:@"Please select album" withBlock:nil andButtons:ALERT_OK, nil];
//        return;
//    }
//    if (dictCategoryDetails.count==0)
//    {
//        [Alerts showAlertWithMessage:@"Please select Category" withBlock:nil andButtons:ALERT_OK, nil];
//        return;
//    }
    
    if ([self.performEdit isEqualToString:@"Edit"]) {
        [self editPostWebCall];
    }
    else{
        [self createNewPostWebCall];
    }
    
}

- (IBAction)actionTwitterClicked:(id)sender
{
    btnTwitter.selected=!btnTwitter.selected;
}

- (IBAction)actionFacebookClicked:(id)sender
{
    btnFacebook.selected=!btnFacebook.selected;
}

- (IBAction)actionAddToAlbum:(id)sender
{
    //    [self.view endEditing:YES];
    //    [viewAddToAlbum setHidden:NO];
    //    [self.view bringSubviewToFront:viewAddToAlbum];
    
    
    AlbumSelectionVC *objAlbumSelection = [STORYBOARD instantiateViewControllerWithIdentifier:@"AlbumSelectionVC"];
    [[APPDELEGATE window].rootViewController addChildViewController:objAlbumSelection];
    objAlbumSelection.view.alpha = 0.0;
    objAlbumSelection.delegate=self;
    [[APPDELEGATE window].rootViewController.view addSubview:objAlbumSelection.view];
    [UIView animateWithDuration:0.5 animations:^{
        objAlbumSelection.view.alpha = 1.0;
    }];
}

//- (IBAction)actionOkClicked:(id)sender
//{
//    if(txtAlbumName.text.length==0)
//    {
//        [Alerts showAlertWithMessage:@"Please enter album name." withBlock:^(NSInteger buttonIndex) {
//
//        } andButtons:@"OK", nil];
//    }
//    else
//    {
//        [viewNewAlbumName setHidden:YES];
//        [txtAlbumName resignFirstResponder];
//        if (iPhone4 || iPhone5)
//        {
//            CGRect frame = self.view.frame;
//            frame.origin.y = 0;
//
//            [UIView animateWithDuration:0.3 animations:^{
//                self.view.frame = frame;
//            }];
//        }
//        [btnAddToAlbum setTitle:txtAlbumName.text forState:UIControlStateNormal];
//    }
//}


- (IBAction)actionCreateNewAlbum:(id)sender
{
    [self.view endEditing:YES];
    [viewAddToAlbum setHidden:YES];
    [viewNewAlbumName setHidden:NO];
    [txtAlbumName becomeFirstResponder];
}

- (IBAction)actionAddToExistingAlbum:(id)sender
{
    
}

- (IBAction)actionCloseAddToAlbumView:(id)sender
{
    [viewAddToAlbum setHidden:YES];
}

//- (IBAction)actionCloseNewAlbumNameVIew:(id)sender
//{
//    [viewNewAlbumName setHidden:YES];
//    [txtAlbumName resignFirstResponder];
//    if (iPhone4 || iPhone5)
//    {
//        CGRect frame = self.view.frame;
//        frame.origin.y = 0;
//
//        [UIView animateWithDuration:0.3 animations:^{
//            self.view.frame = frame;
//        }];
//    }
//}

- (IBAction)actionAddLocation:(id)sender
{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"addLocationSegue" sender:nil];
}

- (IBAction)actionPlayVideo:(id)sender
{
    
//    UIButton *btn=(UIButton*)sender;
//    
//    btn.selected=!btn.selected;
//    [self playCapturedVideo:btn.selected];
    [self playCapturedVideo];

}

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAddCategory:(id)sender
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

#pragma mark - Category delegate method -

- (void)getDataFromCategory:(NSDictionary*)getCategoryDict
{
    
    dictCategoryDetails=[getCategoryDict mutableCopy];
    [btnAddCategory setTitle:[[dictCategoryDetails objectForKey:@"category_name"] capitalizedString] forState:UIControlStateNormal];
}

#pragma mark - Album delegate method -
- (void)getDataFromAlbum:(NSDictionary*)getAlbumDict
{
    NSLog(@"%@",getAlbumDict);
    dictAlbumDetails=[getAlbumDict mutableCopy];
    [btnAddToAlbum setTitle:[getAlbumDict objectForKey:@"album_title"] forState:UIControlStateNormal];
}

#pragma mark - WebService -

- (void)popToHomeVC
{
    [APPDELEGATE myTab].selectedIndex = 0;
    [[APPDELEGATE myTab].viewControllers[0] popToRootViewControllerAnimated:YES];
    if (iPhone6)
        [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_1~667h"]];
    else
        [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_1"]];
}
#pragma mark - FBSDKSharingDelegate -
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [self _serializeJSONObject:results];
    if (resultString) {
          [KSToastView ks_showToast:@"Share success" duration:2.0f];
//        [Alerts showAlertWithMessage:@"Share success" withBlock:nil andButtons:ALERT_OK, nil];
    } else {
          [KSToastView ks_showToast:@"Some thing went wroing" duration:2.0f];
//        [Alerts showAlertWithMessage:@"Some thing went wroing" withBlock:nil andButtons:ALERT_OK, nil];
    }
    [SVProgressHUD dismiss];
    
    sharer.delegate = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [KSToastView ks_showToast:@"Share fail" duration:2.0f];

    
    sharer.delegate = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [SVProgressHUD dismiss];
    [KSToastView ks_showToast:@"Share cancelled" duration:2.0f];

//    [Alerts showAlertWithMessage:@"Share cancelled" withBlock:nil andButtons:ALERT_OK, nil];
    
    
    sharer.delegate = nil;
}
#pragma mark - Helper Method -

- (NSString *)_serializeJSONObject:(id)results
{
    if (![NSJSONSerialization isValidJSONObject:results]) {
        NSLog(@"Invalid JSON Object");
        return nil;
    }
    NSError *error;
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:results options:0 error:&error];
    if (!resultData) {
        NSLog(@"Serialize JSON Object Fail");
        return nil;
    }
    return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
}

-(BOOL)getSharePermissions
{
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"])
    {
        return NO;
    }
    return YES;
}
- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    UIViewController *previousVC=[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    NSLog(@"%@",previousVC);
    
    NSLog(@"dictData = %@",dictData);
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        [USERDEFAULTS setBool:YES  forKey:KEYISPOSTUPDATED];
        [USERDEFAULTS synchronize];
        [SVProgressHUD dismiss];
        if ([reqURL myContainsString:APICREATEPOST])
        {
            NSURL *videoURL;
            NSString *videoPath=[NSString stringWithFormat:@"%@/Video.mov",[Constants getDocumentDirectoryPath]];
            videoURL=[NSURL fileURLWithPath:videoPath];

            if(btnTwitter.selected)
            {
                
                NSData* videoData = [NSData dataWithContentsOfURL:videoURL options:NSDataReadingUncached error:nil];
                [self shareOnTwitter:videoData title:txtPostDescription.text];
            }
            if (btnFacebook.selected) {
                void (^shareVideoBlock)(void) = ^{
                    _content = [[FBSDKShareVideoContent alloc] init];
                    [SVProgressHUD show];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            //saving is done on main thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _content.video = [FBSDKShareVideo videoWithVideoURL:videoURL];
                                // [[FBSDKShareAPI shareWithContent:_content delegate:self] share];
                                FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
                                shareAPI.delegate = self;
                                shareAPI.shareContent = _content;
                                [shareAPI share];
                            });
                    });
                };
                
                if (![self getSharePermissions]) {
                    EnsureWritePermission(self, @"publish_actions", shareVideoBlock);
                    
                }
                else{
                    shareVideoBlock();
                }
            }
            
            [self popToHomeVC];
            
        }
        if ([reqURL myContainsString:APIDELETEPOST])
        {
            [Alerts showAlertWithMessage:[dictData objectForKey:@"message"] withBlock:^(NSInteger buttonIndex) {

                if ([previousVC isKindOfClass:[HomeVC class]]) {

                    [self popToHomeVC];
                }
                else{
                [self.navigationController popViewControllerAnimated:YES];
                }
                NSString *strFileName = [NSString stringWithFormat:@"%@.mov",[[dictData objectForKey:@"data"] objectForKey:@"post_id"]];
                [APPDELEGATE removeVideoFileWithName:strFileName];


            } andButtons:ALERT_OK, nil];
            
        }
        if ([reqURL myContainsString:APIEDITPOST])
        {
            
            [Alerts showAlertWithMessage:[dictData objectForKey:@"message"] withBlock:^(NSInteger buttonIndex) {
                if ([previousVC isKindOfClass:[HomeVC class]]) {
                    [self popToHomeVC];
                }
                else{
                    [self.navigationController popViewControllerAnimated:YES];
                }

            } andButtons:ALERT_OK, nil];
        }
        
        
    }
    else
    {
        if([reqURL myContainsString:APICREATEPOST])
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


#pragma mark - Textfield Delegates -

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==txtAlbumName)
    {
        if (iPhone4 || iPhone5)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = -55;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;
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
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;
            }];
        }
    }
    
    return YES;
}

#pragma mark - TextView Delegates -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add Description..."])
    {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
    
    CGRect r = [textView convertRect:textView.frame toView:scrollView];
    r.origin.y = 250;
    [scrollView scrollRectToVisible:r animated:YES];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Add Description...";
    }
    [textView resignFirstResponder];
}


@end
