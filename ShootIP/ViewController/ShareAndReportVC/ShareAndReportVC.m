//
//  ShareAndReportVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 2/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "ShareAndReportVC.h"
#import "TwitterVideoUpload.h"
#import "PermissionUtility.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface ShareAndReportVC ()

@end

@implementation ShareAndReportVC
@synthesize getPostData;

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - FB Sharing Method -
-(BOOL)getSharePermissions
{
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"])
    {
        return NO;
    }
    return YES;
}
- (IBAction)actionShareOnFacebook:(id)sender
{
    //    http://inheritxdev.net/shootip/api/web/../../uploads/posts/56bae07cc50d7.mp4
    void (^shareVideoBlock)(void) = ^{
        _content = [[FBSDKShareVideoContent alloc] init];

        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSString *urlToDownload = [getPostData objectForKey:@"video"];
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            //          NSData *urlData = [NSData dataWithContentsOfURL:url];
            NSData *urlData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:nil];
            
            if (urlData)
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mov"];
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved !");
                    //                  NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"thefile" withExtension:@"mp4"];
                    NSURL *bundleURL = [NSURL fileURLWithPath:filePath];
                    NSLog(@"bundleURL %@",bundleURL);
                    _content.video = [FBSDKShareVideo videoWithVideoURL:bundleURL];
                   // [[FBSDKShareAPI shareWithContent:_content delegate:self] share];
                    FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
                    shareAPI.delegate = self;


                    shareAPI.shareContent = _content;
                    [shareAPI share];
                    
                });
            }
            
        });
    };
    
    if (![self getSharePermissions]) {
        EnsureWritePermission(self, @"publish_actions", shareVideoBlock);
        
    }
    else{
    shareVideoBlock();
    }
    
//    EnsureWritePermission(self, nil, shareVideoBlock);
   // [self removeViewFromParent];
}
#pragma mark - FBSDKSharingDelegate -
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [self _serializeJSONObject:results];
    if (resultString) {
        [KSToastView ks_showToast:@"Share success" duration:2.0f];
    } else {
        [KSToastView ks_showToast:@"Some thing went wroing" duration:2.0f];
    }
    [SVProgressHUD dismiss];
    [self removeViewFromParent];
    sharer.delegate = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [KSToastView ks_showToast:@"Share fail" duration:2.0f];

    [self removeViewFromParent];
    sharer.delegate = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [SVProgressHUD dismiss];
    [KSToastView ks_showToast:@"Share cancelled" duration:2.0f];

    [self removeViewFromParent];

    sharer.delegate = nil;
}
#pragma mark - Custom Action -

- (IBAction)actionShareOnTwitter:(id)sender
{
    NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[getPostData objectForKey:@"video"]]] options:NSDataReadingUncached error:nil];
    [self shareOnTwitter:videoData title:[getPostData objectForKey:@"post_description"]];
    [self GoogleAnalyticsForShareTwitter];
    [self removeViewFromParent];
}

- (IBAction)actionReportAbuse:(id)sender
{
    NSMutableDictionary *dictReportAbuse=[[NSMutableDictionary alloc] init];
    [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
    [dictReportAbuse setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
    [dictReportAbuse setObject:[getPostData objectForKey:KEYPOSTID] forKey:KEYPOSTID];
    [SVProgressHUD show];
    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIREPORTABUSE method:@"POST" data:dictReportAbuse withImages:nil withVideo:nil];
    [self removeViewFromParent];
}

- (IBAction)actionClose:(id)sender
{
    [self removeViewFromParent];
}

-(void)GoogleAnalyticsForShareTwitter
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    
//    NSString *targetUrl = @"https://twitter.com";
    NSString *targetUrl = @"https://developers.google.com/analytics";

    [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"Twitter"           // Social network (required)
                                                          action:@"Share"             // Social action (required)
                                                          target:targetUrl] build]];  // Social target
}

#pragma mark - Custom Action -
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
//                  [KSToastView ks_showToast:@"Video shared successfully on twitter." duration:2.0f];

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

-(void)removeViewFromParent
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - WebService -

- (void)ConnectionDidFinishRequestURL:(NSString*)reqURL Data:(NSMutableDictionary*) dictData
{
    //
    if ([[dictData objectForKey:@"success"] intValue] == 1)
    {
        if ([reqURL myContainsString:APIREPORTABUSE])
        {
            [UIAlertView showAlertViewWithTitle:APPNAME message:[dictData objectForKey:@"message"]];
        }
        [SVProgressHUD dismiss];
    }
    else
    {
        if ([reqURL myContainsString:APIREPORTABUSE])
        {
            
        }
    }
    [SVProgressHUD dismiss];
}

- (void)ConnectionDidFailRequestURL:(NSString*)reqURL  Data: (NSString*)nData
{
    [SVProgressHUD dismiss];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



@end
