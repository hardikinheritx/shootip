//
//  CaptureVideoVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "CaptureVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#include <AudioToolbox/AudioToolbox.h>

@interface CaptureVideoVC ()

{
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    float timerValue;
    NSTimer *timer;
    NSString *type;
    
    IBOutlet UIImageView *imgRecord;
    
}

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;


@end

@implementation CaptureVideoVC

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];

        // Do any additional setup after loading the view.
    _recorder = [SCRecorder recorder];
        _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
//    _recorder.captureSessionPreset = AVCaptureSessionPresetiFrame960x540;
    
    //    _recorder.maxRecordDuration=CMTimeMakeWithSeconds(5.0, 600);
    //    _recorder.fastRecordMethodEnabled = YES;
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    _recorder.previewView = cameraView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.hidesBottomBarWhenPushed=YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];

    [InfoView setHidden:NO];
    [self.view bringSubviewToFront:InfoView];
    timerValue=0.0;
    type=@"Capture";
    [progressView setShowValueString:timerValue];
    [progressView setProgressStrokeColor:[UIColor clearColor]];
    [progressView setProgressColor:[UIColor clearColor]];
    [progressView setValue:0 animateWithDuration:1.0];

    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;
    
    [imgRecord setHidden:YES];
    [btnCapture setHidden:YES];
    [btnCapture setUserInteractionEnabled:NO];
    
    [self prepareSession];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
    [progressView setProgressStrokeColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_recorder startRunning];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Capture Video Screen"];
    [APPDELEGATE setDropOffScreen:@"Capture Video Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recorder stopRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0UL), ^{
        [timer invalidate];
        timer = nil;
    });
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}


#pragma mark - Custom Method

- (void)prepareSession {
    if (_recorder.session == nil)
    {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    _recorder.maxRecordDuration=CMTimeMakeWithSeconds(5.0, 600);
}

-(void)GetLastVideoFromAssetLibrary
{
    ALAssetsLibrary* libraryFolder = [[ALAssetsLibrary alloc] init];
    [libraryFolder enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            
            //Filter videos
            
            NSArray *  videoArray = [self getContentFrom:group withAssetFilter:[ALAssetsFilter allVideos]];
            ALAsset *result =[videoArray lastObject];
            
            UIImage *image=[UIImage imageWithCGImage:result.thumbnail];

            [btnGallery setImage:image forState:UIControlStateNormal];

          //  NSLog(@"%@",[videoArray lastObject]);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error Description %@",[error description]);
    }];
}

-(void)startRecording
{
        [self performSelectorOnMainThread:@selector(playAudio) withObject:nil waitUntilDone:YES];
//        [self performSelector:@selector(recordVideo) withObject:nil afterDelay:0.75];
        [self performSelector:@selector(recordVideo) withObject:nil afterDelay:1.0];
}

-(void)playAudio
{
    AudioServicesPlaySystemSound(1117);
}

-(void)recordVideo
{
    [_recorder record];
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                               selector:@selector(updateModel:) userInfo:nil repeats:YES];
    }
    else {
        [timer fire];
    }
   
    NSLog(@"timer :> %@",timer);

    [progressView setProgressRotationAngle:50];
    [progressView setProgressStrokeColor:[UIColor whiteColor]];
    [progressView setEmptyLineColor:[UIColor clearColor]];
    [progressView setShowUnitString:NO];

}

-(void)updateModel:(NSTimer *)theTimer
{
    NSLog(@"%f",timerValue);
    if(timerValue<=4)
    {
        NSLog(@"if in value for timer : %f",timerValue);
        timerValue++;
        [progressView setShowValueString:timerValue];
        [progressView setValue:timerValue animateWithDuration:1.0];
        [progressView setMaxValue:5];

    }
    else
    {
        NSLog(@"else in value for timer : %f",timerValue);
        [_recorder pause:^{
            [self saveAndShowSession:_recorder.session];
        }];
        [timer invalidate];
//        [self performSelectorOnMainThread:@selector(playAudio) withObject:nil waitUntilDone:YES];
//
//        [timer invalidate];
//        timerValue=0;
//        [self.tabBarController hidesBottomBarWhenPushed];
//        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//        [self performSegueWithIdentifier:@"newPostSegue" sender:nil];
    }
}

-(void)retake
{
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
}

-(void)CameraAccesaryHiddenNo
{
    [progressView setShowValueString:timerValue];
    [imgRecord setHidden:NO];
    [btnCapture setHidden:NO];
}

-(void)checkPermissionForMicroPhone
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted)
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusDenied)
            {
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:nil message:@"Shootip does not have access to your camera. To enable access, tap Settings and turn on camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings",nil];
                [alert setTag:96];
                [alert show];
            }
            else
            {
                [InfoView setHidden:YES];
                [self retake];
                [self startRecording];
            }
        }
        else
        {
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:nil message:@"Shootip does not have access to your MicroPhone. To enable access, tap Settings and turn on camera." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings",nil];
            [alert setTag:96];
            [alert show];
        }
    }];
}

#pragma mark - Oreintation Changed Method

- (void)orientationChanged:(NSNotification *)note
{
        UIDevice * device = note.object;
        switch(device.orientation)
        {
            case UIDeviceOrientationPortrait:
            {
                NSLog(@"UIDeviceOrientationPortrait");
                
                [self setForPortrait];
                break;
            }
            case UIDeviceOrientationLandscapeLeft :{
                NSLog(@"UIDeviceOrientationLandscapeLeft");
                [self setForLandscape];
                break;
            }
            case UIDeviceOrientationLandscapeRight :
            {
                NSLog(@"UIDeviceOrientationLandscapeRight");
                [self setForLandscape];
                break;
            }
            case  UIDeviceOrientationPortraitUpsideDown:
            {
                [self setForPortrait];
                break;
            }
            default:
            {
                [self setForPortrait];
            }
                break;
        };
}

-(void)setForPortrait
{
    [InfoView setHidden:NO];
    [self.view bringSubviewToFront:InfoView];
    [imgRecord setHidden:YES];
    [btnCapture setHidden:YES];
    [timer invalidate];
    timer=nil;
    timerValue=0;
    [self retake];
    [progressView setShowValueString:timerValue];
    [progressView setProgressStrokeColor:[UIColor clearColor]];
    [progressView setValue:timerValue animateWithDuration:0];
}

-(void)setForLandscape
{
    [timer invalidate];
    timer=nil;
    timerValue=0;
    
    [self CameraAccesaryHiddenNo];
    //                [self performSelector:@selector(checkPermissionForMicroPhone) withObject:nil afterDelay:1];
    [self checkPermissionForMicroPhone];
    [progressView setValue:timerValue animateWithDuration:0];

}

#pragma mark - SCRecorder

- (void)finishSession:(SCRecordSession *)recordSession
{
//    [recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error)
//     {
//         [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
//         _recordSession = recordSession;
//         //[self showVideo];
//         [self prepareCamera];
//     }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    //    [self showVideo];
    
    [self performSelectorOnMainThread:@selector(playAudio) withObject:nil waitUntilDone:YES];
    
    [timer invalidate];
    timerValue=0;
    [self.tabBarController hidesBottomBarWhenPushed];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self performSegueWithIdentifier:@"newPostSegue" sender:nil];
}


- (void) handleRetakeButtonTapped:(id)sender
{
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    //    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    //    [self updateGhostImage];
}

- (void)updateTimeRecordedLabel
{
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    [progressView setShowValueString:[NSString stringWithFormat:@"%f", CMTimeGetSeconds(currentTime)]];
    [progressView setValue:CMTimeGetSeconds(currentTime)+1 animateWithDuration:1.0];
    [progressView setMaxValue:5];
    //    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.2f sec", CMTimeGetSeconds(currentTime)];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    //    [self updateTimeRecordedLabel];
}


- (void)didReceiveMemoryWarning
{
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



#pragma mark - Action Method

- (IBAction)actionCapture:(id)sender
{
    [self startRecording];
}

- (IBAction)actionCloseCamera:(id)sender
{
    [APPDELEGATE myTab].selectedIndex=0;
    if (iPhone6)
        [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_1~667h"]];
    else
        [[APPDELEGATE imagefooter] setImage:[UIImage imageNamed:@"tabbar_1"]];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


- (IBAction)selectAsset:(id)sender
{
 //   ALAssetsLibrary* libraryFolder = [[ALAssetsLibrary alloc] init];
//    [libraryFolder addAssetsGroupAlbumWithName:@"My Album" resultBlock:^(ALAssetsGroup *group)
//    {
//        NSLog(@"Adding Folder:'My Album', success: %s", group.editable ? "Success" : "Already created: Not Success");
//    } failureBlock:^(NSError *error)
//    {
//        NSLog(@"Error: Adding on Folder");
//    }];

    
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = YES;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}



-(NSMutableArray *) getContentFrom:(ALAssetsGroup *) group withAssetFilter:(ALAssetsFilter *)filter
{
    NSMutableArray *contentArray = [NSMutableArray array];
    [group setAssetsFilter:filter];
    
    
    
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        //ALAssetRepresentation holds all the information about the asset being accessed.
        if(result)
        {
            //Add the values to photos array.
            [contentArray addObject:result];
  
        }
    }];
    return contentArray;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    [self cropVideo:url];
//    self.asset = [AVAsset assetWithURL:url];
    
//    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    
//    self.player = [AVPlayer playerWithPlayerItem:item];
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
//    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self performSegueWithIdentifier:@"newPostSegue" sender:nil];
    self.videoPlaybackPosition = 0;
}
-(void)cropVideo:(NSURL*)videoToTrimURL{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoToTrimURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"Video.mov"];
    

    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTime start = CMTimeMakeWithSeconds(1.0, 600); // you will modify time range here
    CMTime duration = CMTimeMakeWithSeconds(5.0, 600);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:
              //   [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                 NSLog(@"Export Complete %ld %@", (long)exportSession.status, exportSession.error);
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 break;
             default:
                 break;
         }
         [self clearTmpDirectory];
         //[exportSession release];
     }];
    
}
- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}
#pragma mark - AlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 96)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
        }
    }
}


@end
