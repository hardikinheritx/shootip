//
//  ServerConnection.m
//  TrainingPal
//
//  Created by  milap kundalia on 11/6/15.
//  Copyright (c) 2015 Inheritx. All rights reserved.
//


#import "ServerConnection.h"
#import "Constants.h"
#import "WelcomeVC.h"

@interface ServerConnection ()
@end

@implementation ServerConnection
@synthesize connectionDelegate;

static ServerConnection *sharedConnection = nil;

+(ServerConnection *)sharedConnection
{
    if (!sharedConnection) {
        sharedConnection = [[ServerConnection alloc] init];
    }
    return sharedConnection;
}

+(ServerConnection *)sharedConnectionWithDelegate:(id)delegate
{
    if (!sharedConnection)
    {
        sharedConnection = [[ServerConnection alloc]init];
    }
    sharedConnection.connectionDelegate = delegate;
    return sharedConnection;
}

+(BOOL)isConnected
{
    //  return [AFNetworkReachabilityManager sharedManager].reachable;
    if ([[AFNetworkReachabilityManager sharedManager]networkReachabilityStatus]!= AFNetworkReachabilityStatusNotReachable)
        return YES;
    else
        return NO;
}
-(BOOL)isInternetAvailable
{
    
    if ([[AFNetworkReachabilityManager sharedManager]networkReachabilityStatus]!= AFNetworkReachabilityStatusNotReachable)
    {
        return YES;
    }
    else
    {
        [SVProgressHUD dismiss];
        [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
        //        [CRToastManager showNotificationWithOptions:[self options]
        //                                    completionBlock:^{
        //
        //                                        NSLog(@"Completed");
        //                                    }];
        return NO;
    }
}
-(BOOL)connected
{
    
    __block BOOL reachable;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"No Internet Connection");
                reachable = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                reachable = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                reachable = YES;
                break;
            default:
                NSLog(@"Unkown network status");
                reachable = NO;
                break;
        }
    }];
    
    return reachable;
    
}
#pragma mark - Video Download Method -

-(void)downloadVideo:(NSString *)strUrl videoName:(NSString *)strVideoName indexAt:(int)index arrayUrls:(NSMutableArray*)arrUrl
{ // kandhal
    
    //NSLog(@"strUrl = %@",strUrl);
    NSLog(@"start video to download : %@",strVideoName);
    //NSLog(@"index %d",index);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    arrUrlTemp = [[NSMutableArray alloc] init];
    arrUrlTemp = arrUrl;
  
    __block int arrayIndex = index;
    
    if (arrUrlTemp.count>0)
    {

        if([APPDELEGATE checkIfVideoExists:strVideoName])
        {
            
            NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strVideoName]];
            if (_isPlaying == YES)
            {
                if ([connectionDelegate respondsToSelector:@selector(downloadDoneForUrl:indexAt:)])
                {
                    NSLog(@"index - %d",index);
                    [connectionDelegate downloadDoneForUrl:savedVideoPath indexAt:index];
                    
                }
            }
            else
            {
                arrayIndex = arrayIndex + 1;
                
                if (arrayIndex < arrUrlTemp.count)
                {
                    [self downloadVideo:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"video"] videoName:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"post_id"] indexAt:arrayIndex arrayUrls:arrUrlTemp];
                    
                }
            }
        }
        else
        {
            
            //NSLog(@"arrayIndex: %d",arrayIndex);

            
            //Configuring the session manager
            
            //urls string format so to convert them into an NSURL and then instantiate the actual request
            //NSLog(@"Download Video URL : %@",strUrl);

            NSURL *formattedURL = [NSURL URLWithString:strUrl];
            NSURLRequest *request = [NSURLRequest requestWithURL:formattedURL];
            
            //Watch the manager to see how much of the file it's downloaded
            [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite)
             {
                 //Convert totalBytesWritten and totalBytesExpectedToWrite into floats so that percentageCompleted doesn't get rounded to the nearest integer
                 NSString *strLoggedInStatus = [USERDEFAULTS objectForKey:KEYLOGGEDIN];
                 if ([strLoggedInStatus isEqualToString:@"0"] || strLoggedInStatus == nil)
                 {
                     [downloadTask suspend];
                     downloadTask = nil;
                 }
                 CGFloat written = totalBytesWritten;
                 CGFloat total = totalBytesExpectedToWrite;
                 CGFloat percentageCompleted = written/total;
                 //NSLog(@"%f",percentageCompleted);
                 
                 //Return the completed progress so we can display it somewhere else in app
                 //            progressBlock(percentageCompleted);
             }];
            
            
            //Start the download
            downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                            {
                                //Getting the path of the document directory
                                NSURL *documentsDirectoryURL = [FILEMANAGER URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                                
                                NSURL *fullURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strVideoName]];
                                return fullURL;
                                
                            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                            {
//                                NSLog(@"strVideoName : %@",strVideoName);
//                                NSLog(@"filePath : %@",filePath);
//                                NSLog(@"error : %@",error);
                                
                                if (!error)
                                {
                                    if (_isPlaying == YES)
                                    {
                                        if ([connectionDelegate respondsToSelector:@selector(downloadDoneForUrl:indexAt:)])
                                        {
                                            [connectionDelegate downloadDoneForUrl:filePath.absoluteString indexAt:index];
                                            
                                        }
                                    }
                                    else
                                    {
                                        arrayIndex = arrayIndex + 1;
                                        
                                        if (arrayIndex < arrUrlTemp.count)
                                        {
                                            [self downloadVideo:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"video"] videoName:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"post_id"] indexAt:arrayIndex arrayUrls:arrUrlTemp];
                                            
                                            /*if ([connectionDelegate respondsToSelector:@selector(downloadDoneForUrl:indexAt:)])
                                            {
                                                [connectionDelegate downloadDoneForUrl:filePath.absoluteString indexAt:index];
                                                
                                            }*/

                                        }
                                    }
    
                                } else
                                {
                                    NSLog(@"download error : %@",error);
                                    if (downloadTask)
                                    {
                                        [downloadTask suspend];
                                        downloadTask = nil;
                                    }
                                   
                                    if (arrUrlTemp.count > 0)
                                    {
                                        NSString *strLoggedInStatus = [USERDEFAULTS objectForKey:KEYLOGGEDIN];
                                        if ([strLoggedInStatus isEqualToString:@"0"] || strLoggedInStatus == nil)
                                        {
                                            [self stopDownloadFor:@""];

                                        }
                                        else
                                        {
                                            
                                            if ([connectionDelegate respondsToSelector:@selector(downloadFailedForUrl)]){
                                                 [connectionDelegate downloadFailedForUrl];
                                            }
                                            else{
                                                 if ([connectionDelegate respondsToSelector:@selector(downloadFailed)]){
                                                     [connectionDelegate downloadFailed];
                                                 }
                                            }
                                            
                                            
                                            //NSLog(@"%@",response);
                            
//                                            NSString *strTemp = [NSString stringWithFormat:@"%@",response.URL];
//                                            
//                                            int tempIndex = 0;
//                                            for (int i = 0; i < [arrUrlTemp count]; i++) {
//                                                NSString *strTempURL = [NSString stringWithFormat:@"%@",[[arrUrlTemp objectAtIndex:i] objectForKey:@"video"]];
//                                                
//                                                if (strTemp == strTempURL) {
//                                                    tempIndex = i;
//                                                    
//                                                    break;
//                                                }
//                                            }
                                            
                                            
                                          //  NSLog(@"tempIndex %d",tempIndex);

                                            
                                            //NSLog(@"%@ --- %@ --- %ld",[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"video"],[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"post_id"],(long)arrayIndex);
                                            
                                            //[self downloadVideo:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"video"] videoName:[[arrUrlTemp objectAtIndex:arrayIndex] objectForKey:@"post_id"] indexAt:arrayIndex arrayUrls:arrUrlTemp];
                                            
                                           // [self downloadVideo:[[arrUrlTemp objectAtIndex:index] objectForKey:@"video"] videoName:[[arrUrlTemp objectAtIndex:index] objectForKey:@"post_id"] indexAt:index arrayUrls:arrUrlTemp];
                                        }
                                    }
                                    
                                }
                                
                            }];
            
            [downloadTask resume];
        }

    }
    
}
-(void)stopDownloadFor:(NSString*)strScreenType
{
    // stop when logout from app. 
//    if(![strCurrentScreen isEqualToString:strScreenType])
//    {
        _isPlaying = NO;
        if (downloadTask)
        {
            [downloadTask suspend];
            downloadTask = nil;
        }
    
    NSMutableArray *arrStopToDownloadData = [[NSMutableArray alloc] init];
    [self downloadVideo:@"" videoName:@"stopVideoDownloading" indexAt:0 arrayUrls:arrStopToDownloadData];
    arrUrlTemp = [[NSMutableArray alloc] init];

//    }
}
#pragma mark - Normal Request Method -

- (void)alertAdminDeletedUser
{
    [Alerts showAlertWithMessage:@"User has been deleted by admin." withBlock:^(NSInteger buttonIndex) {
        [APPDELEGATE clearCachedDirectory];
        [self stopDownloadFor:@""];
        [SVProgressHUD dismiss];
        [USERDEFAULTS setObject:@"0" forKey:@"isLoggedIn"];
        [USERDEFAULTS synchronize];
        
        NSString *deviceToken=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        [USERDEFAULTS setObject:deviceToken forKey:KEYDEVICETOKEN];
        
        
        
        UINavigationController *navController = (UINavigationController *)APPDELEGATE.window.rootViewController;
        [navController popToRootViewControllerAnimated:YES];
        
        
        //        UIStoryboard *sub_storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
        //        WelcomeVC *objWelcome=(WelcomeVC *)[sub_storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
        //        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:objWelcome];
        //        navController.navigationBar.hidden=YES;
        //        navController.navigationBarHidden = YES;
        //        [UIView transitionWithView:[APPDELEGATE window]
        //                          duration:0.5
        //                           options:UIViewAnimationOptionTransitionCrossDissolve
        //                        animations:^{     [[APPDELEGATE window] setRootViewController:navController]; }
        //                        completion:nil];
        
        
    } andButtons:@"Ok", nil];
    
}

- (void)alertAuthTokenNotValid
{
    [Alerts showAlertWithMessage:@"You are login from other device please login again." withBlock:^(NSInteger buttonIndex)
     {
         [APPDELEGATE clearCachedDirectory];
         [self stopDownloadFor:@""];

         [SVProgressHUD dismiss];
         [USERDEFAULTS setObject:@"0" forKey:@"isLoggedIn"];
         [USERDEFAULTS synchronize];
         
         //    [Constants RemoveImageFromDocumentDirectory:@"savedUserImage.png"];   //Clear user profile image from document directory
         
         NSString *deviceToken=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
         NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
         [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
         
         [USERDEFAULTS setObject:deviceToken forKey:KEYDEVICETOKEN];
         
         UINavigationController *navController = (UINavigationController *)APPDELEGATE.window.rootViewController;
         [navController popToRootViewControllerAnimated:YES];
         
         //         UIStoryboard *sub_storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
         //         WelcomeVC *objWelcome=(WelcomeVC *)[sub_storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
         //         UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:objWelcome];
         //         navController.navigationBar.hidden=YES;
         //         navController.navigationBarHidden = YES;
         //         [UIView transitionWithView:[APPDELEGATE window]
         //                           duration:0.5
         //                            options:UIViewAnimationOptionTransitionCrossDissolve
         //                         animations:^{     [[APPDELEGATE window] setRootViewController:navController]; }
         //                         completion:nil];
         
         
     } andButtons:@"Ok", nil];
}

- (void)printRequestPramsJson:(NSMutableDictionary *)dataDict URLString:(NSString *)URLString
{
    //                if ([[USERDEFAULTS objectForKey:KEYLOGINUSERDETAIL] objectForKey:KAUTHTOKEN]) {
    //                    [manager.requestSerializer setValue:[[USERDEFAULTS objectForKey:KEYLOGINUSERDETAIL] objectForKey:KAUTHTOKEN] forHTTPHeaderField:KAUTHTOKEN];
    //                    NSLog(@"auth_token %@ ", [[USERDEFAULTS objectForKey:KEYLOGINUSERDETAIL] objectForKey:KAUTHTOKEN]);
    //
    //                }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    NSLog(@"URL %@ :: request %@ ",URLString, jsonStr);
}

-(void)requestWithURL:(NSString *)URLString method:(NSString*)method data:(NSMutableDictionary*)dataDict withImages:(NSMutableDictionary *)dictImages withVideo:(NSDictionary *)dictVideo
{
    if ([[AFNetworkReachabilityManager sharedManager]networkReachabilityStatus]!= AFNetworkReachabilityStatusNotReachable)
    {
        
        if ([method isEqualToString:@"GET"])
        {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            //    NSLog(@"URL %@ :: request %@ ",URLString, [dataDict JSONRepresentation]);
            NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
            
            NSLog(@"URL %@ :: request %@ ",URLString, jsonStr);
            
            [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject)
             {
                 NSMutableDictionary *dictResp = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                 
                 if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFinishRequestURL:Data:)])
                 {
                     [connectionDelegate ConnectionDidFinishRequestURL:[operation.response.URL absoluteString] Data:dictResp];
                 }
                 
             } failure:^(NSURLSessionTask *operation, NSError *error) {
                 if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFailRequestURL:Data:)])
                 {
                     if ([error code] == -1009 || [error code] == -1003)
                     {
                         [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
                     }
                     else if ([error code] == -1001)
                     {
                         [UIAlertView showAlertViewWithTitle:APPNAME message:@"Request timed out! Please try again."];
                     }
                     else if ([error code] == -1005)
                     {
                         [UIAlertView showAlertViewWithTitle:APPNAME message:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
                     }
                     else
                     {
                         [connectionDelegate ConnectionDidFailRequestURL:[operation.response.URL absoluteString] Data:[error localizedDescription]];
                     }
                     [SVProgressHUD dismiss];
                 }
             }];
            
        }
        else
        {
            URLString = [BASEURL stringByAppendingString:URLString];
            
            if (dictImages && dictVideo==nil)
            {
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                [manager.requestSerializer setTimeoutInterval:240.0];
                [self printRequestPramsJson:dataDict URLString:URLString];
                
                
                [manager POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                 {
                     NSArray *arrKeys = [dictImages allKeys];
                     for (int i = 0; i < [arrKeys count]; i++)
                     {
                         NSData *tempData = UIImagePNGRepresentation([dictImages objectForKey:[arrKeys objectAtIndex:i]]);
                         if (tempData)
                         {
                             [formData appendPartWithFileData:tempData name:[arrKeys objectAtIndex:i] fileName:[NSString stringWithFormat:@"%@.png",[arrKeys objectAtIndex:i]] mimeType:@"image/png"];
                         }
                     }
                     
                     for (NSString * key in [dataDict allKeys])
                     {
                         id value = dataDict[key];
                         if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
                         {
                             [formData appendPartWithFormData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                         }
                         else if ([value isKindOfClass:[NSArray class]]||[value isKindOfClass:[NSDictionary class]])
                         {
                             [formData appendPartWithFormData:[[value JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                         }
                         
                     }
                     
                 }
                     progress:nil success:^(NSURLSessionTask *operation, id responseObject)
                 {
                     NSMutableDictionary *dictResp = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                     
                     if ([[dictResp objectForKey:@"success"] intValue] == -1) {
                         
                         [self alertAdminDeletedUser];
                         return;
                     }
                     else if ([[dictResp objectForKey:@"success"] intValue]==-2){
                         [self alertAuthTokenNotValid];
                         return;
                         
                     }
                     
                     
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFinishRequestURL:Data:)])
                     {
                         [connectionDelegate ConnectionDidFinishRequestURL:[operation.response.URL absoluteString] Data:dictResp];
                     }
                 }
                      failure:^(NSURLSessionTask *operation, NSError *error)
                 {
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFailRequestURL:Data:)])
                     {
                         if ([error code] == -1009 || [error code] == -1003)
                         {
                             [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
                         }
                         else if ([error code] == -1001)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:@"Request timed out! Please try again."];
                         }
                         else if ([error code] == -1005)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
                         }
                         else
                         {
                             [connectionDelegate ConnectionDidFailRequestURL:[operation.response.URL absoluteString] Data:[error localizedDescription]];
                         }
                         [SVProgressHUD dismiss];
                     }
                     
                 }];
            }
            else if (dictVideo) {
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                [manager.requestSerializer setTimeoutInterval:240.0];
                [self printRequestPramsJson:dataDict URLString:URLString];
                [manager POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                 {
                     NSString *videoPath=[NSString stringWithFormat:@"%@/Video.mov",[Constants getDocumentDirectoryPath]];
                     NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:videoPath]];
                     if (videoData)
                     {
                         [formData appendPartWithFileData:videoData name:@"video" fileName:@"Video.mov" mimeType:@"video/quicktime"];
                     }
                     NSArray *arrKeys = [dictImages allKeys];
                     for (int i = 0; i < [arrKeys count]; i++)
                     {
                         NSData *tempData = UIImagePNGRepresentation([dictImages objectForKey:[arrKeys objectAtIndex:i]]);
                         if (tempData)
                         {
                             [formData appendPartWithFileData:tempData name:[arrKeys objectAtIndex:i] fileName:[NSString stringWithFormat:@"%@.png",[arrKeys objectAtIndex:i]] mimeType:@"image/png"];
                         }
                     }
                     
                     
                     for (NSString * key in [dataDict allKeys])
                     {
                         id value = dataDict[key];
                         if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
                         {
                             [formData appendPartWithFormData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                         }
                         else if ([value isKindOfClass:[NSArray class]]||[value isKindOfClass:[NSDictionary class]])
                         {
                             [formData appendPartWithFormData:[[value JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                         }
                         
                     }
                     
                 }
                     progress:nil success:^(NSURLSessionTask *operation, id responseObject)
                 {
                     NSMutableDictionary *dictResp = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                     
                     if ([[dictResp objectForKey:@"success"] intValue] == -1) {
                         
                         [self alertAdminDeletedUser];
                         return;
                     }
                     else if ([[dictResp objectForKey:@"success"] intValue]==-2){
                         [self alertAuthTokenNotValid];
                         return;
                     }
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFinishRequestURL:Data:)])
                     {
                         [connectionDelegate ConnectionDidFinishRequestURL:[operation.response.URL absoluteString] Data:dictResp];
                     }
                 }
                      failure:^(NSURLSessionTask *operation, NSError *error)
                 {
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFailRequestURL:Data:)])
                     {
                         if ([error code] == -1009 || [error code] == -1003)
                         {
                             [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
                         }
                         else if ([error code] == -1001)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:@"Request timed out! Please try again."];
                         }
                         else if ([error code] == -1005)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
                         }
                         else
                         {
                             [connectionDelegate ConnectionDidFailRequestURL:[operation.response.URL absoluteString] Data:[error localizedDescription]];
                         }
                         [SVProgressHUD dismiss];
                     }
                     
                 }];
            }
            else
            {
                //                AFHTTPSessionManager *manager;
                //                if ([URLString myContainsString:APISEARCH])
                //                {
                //                    if (!searchManager)
                //                    {
                //                        searchManager = [AFHTTPSessionManager manager];
                //                    }
                //                    manager = searchManager;
                //                    [manager.operationQueue cancelAllOperations];
                //                }
                //                else
                //                {
                //                    manager = [AFHTTPSessionManager manager];
                //                }
                
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                [manager.requestSerializer setTimeoutInterval:240.0];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
                
                [self printRequestPramsJson:dataDict URLString:URLString];
                [manager POST:URLString
                   parameters:dataDict progress:nil
                      success:^(NSURLSessionTask *operation, id responseObject)
                 {
                     NSMutableDictionary *dictResp = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                     
                     if ([[dictResp objectForKey:@"success"] intValue] == -1) {
                         [self alertAdminDeletedUser];
                         return;
                         
                     }
                     else if ([[dictResp objectForKey:@"success"] intValue]==-2){
                         [self alertAuthTokenNotValid];
                         return;
                         
                     }
                     
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFinishRequestURL:Data:)])
                     {
                         [connectionDelegate ConnectionDidFinishRequestURL:[operation.response.URL absoluteString] Data:dictResp];
                     }
                 }
                      failure:^(NSURLSessionTask *operation, NSError *error)
                 {
                     if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFailRequestURL:Data:)])
                     {
                         if ([error code] == -1009 || [error code] == -1003)
                         {
                             [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
                         }
                         else if ([error code] == -1001)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:@"Request timed out! Please try again."];
                         }
                         else if ([error code] == -1005)
                         {
                             [UIAlertView showAlertViewWithTitle:APPNAME message:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
                         }
                         else
                         {
                             //NSLog(@"operation.responseString %@ ",operation.responseString);
                             [connectionDelegate ConnectionDidFailRequestURL:[operation.response.URL absoluteString] Data:[error localizedDescription]];
                         }
                         [SVProgressHUD dismiss];
                     }
                 }];
            }
        }
    }
    else
    {
        if ([connectionDelegate respondsToSelector:@selector(ConnectionDidFailRequestURL:Data:)])
        {
            [Alerts showAlertWithMessage:@"Oops! Internet connection not available. Please try again later." withBlock:nil andButtons:@"Ok", nil];
            [SVProgressHUD dismiss];
        }
    }
}
@end
