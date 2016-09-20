//
//  AppDelegate.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NotificationListVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize myTab,imagefooter;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//    NSString *str=[NSString stringWithFormat:@"%@ %@",@"2016-02-22",@"12:25 AM"];
//    NSLog(@"%@",str);//str cotain value like  2016-02-22 12:25 AM
//    
//    //set the formatter
//    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init] ;
//    
//    [formatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//    
//    NSDate *FinalDateTime=[formatter1 dateFromString:@"2016-02-20T03:00:00+05:30"];
//    
//    NSString *date= [formatter1 stringFromDate:FinalDateTime];
//    
//    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *date1= [formatter1 stringFromDate:FinalDateTime];
//    NSLog(@"%@",date1);
    
    //fb
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    // Override point for customization after application launch.
    
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];// remove before app release
    [GAI sharedInstance].dispatchInterval = 20;
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-74650663-1"];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-74741340-1"];
    
    [self tabbarImage];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
#pragma mark - Create dictionary for username and its information
    self.UserInfodict = [NSMutableDictionary
                         dictionaryWithObjects:@[@"Nicholas Murphy",@"243",@"42",@"2428"]
                         forKeys:@[@"name",@"Shootips",@"Albums",@"Lookouts"]];
    
    
#pragma mark - Create array for Album
    self.arrayAlbumList = @[
                            @{@"PlaceName" : @"Lake Wanka, New Zealand",
                              @"Rating" : @"1",
                              @"AlbumTitle" : @"News",
                              @"Date" : @"27 may 2015    10.29am",
                              @"Thumbnail" : @"img_01"},
                            @{@"PlaceName" : @"NZ Contract Bridge, New Zealand",
                              @"Rating" : @"5",
                              @"AlbumTitle" : @"Music",
                              @"Date" : @"28 may 2015    10.29am",
                              @"Thumbnail" : @"img_02"},
                            @{@"PlaceName" : @"Caroline Morse, New Zealand",
                              @"Rating" : @"4",
                              @"AlbumTitle" : @"Sports",
                              @"Date" : @"29 may 2015    10.29am",
                              @"Thumbnail" : @"img_03"},
                            @{@"PlaceName" : @"India Gate, India",
                              @"Rating" : @"2",
                              @"AlbumTitle" : @"Hollywood",
                              @"Date" : @"30 may 2015    10.29am",
                              @"Thumbnail" : @"img_01"},
                            ];
    
    
    
#pragma mark - Create array for Notification
    self.arrayNotificationList = @[
                                   @{@"Thumbnail" : @"img_01",
                                     @"Place" : @"Zion National Park",
                                     @"Country" : @"UTAH, USA",
                                     @"Description" : @"Awesome Lake\nZion National Park is a southwest Utah nature preserve distinguished by Zion Canyon’s steep red cliffs. Zion Canyon Scenic Drive cuts through its main section, leading to forest trails along the Virgin River. The river flows to the Emerald Pools, which have waterfalls and a hanging garden. Also along the river, partly through deep chasms, is Zion Narrows wading hike."},
                                   @{@"Thumbnail" : @"img_02",
                                     @"Place" : @"Chicago",
                                     @"Country" : @"UTAH, USA",
                                     @"Description" : @"Chicago Bulls\nChicago, on Lake Michigan in Illinois, is among the largest cities in the U.S. Famed for its bold architecture, it has a skyline bristling with skyscrapers such as the iconic John Hancock Center, sleek, 1,451-ft. Willis Tower and neo-Gothic Tribune Tower. The city is also renowned for its museums, including the Art Institute and its expansive collections, including noted Impressionist works."},
                                   @{@"Thumbnail" : @"img_03",
                                     @"Place" : @"Fort Worth",
                                     @"Country" : @"UTAH, USA",
                                     @"Description" : @"Trinity River\nFort Worth is a city in North Central Texas. In the late 19th century, it became an important trading post for cowboys at the end of the Chisholm Trail. Today, it's a modern city, with international art institutions like the Kimbell Art Museum. The Fort Worth Stockyards are home to rodeos, and the National Cowgirl Museum and Hall of Fame honors pioneers."},
                                   ];
    
#pragma mark - Create array for Settings
    self.arraySettingsList = [[NSMutableArray alloc]initWithObjects:@"Notification", @"Change Password",@"Support",@"Terms and Service",@"Privacy Policy",@"Logout", nil];
    
#pragma mark - Create array for Top Destination
    self.arrayTopDestinationList = @[@{@"DestinationThumbnail" : @"London",@"DestinationName" : @"London"},@{@"DestinationThumbnail" : @"NYC",@"DestinationName" : @"NYC"},@{@"DestinationThumbnail" : @"Paris",@"DestinationName" : @"Paris"}];
    
#pragma mark - Create array for Search
    self.arraySearchData = @[@{@"Place" : @"Caroline Morse",@"Album" : @"Sports", @"Hashtag" : @"Name"},@{@"Place" : @"Chicago",@"Album" : @"Music", @"Hashtag" : @"U.S City"},@{@"Place" : @"Fort Worth",@"Album" : @"Hollywood", @"Hashtag" : @"City"},@{@"Place" : @"India Gate",@"Album" : @"Travel", @"Hashtag" : @"Kingsway"}, @{@"Place" : @"Lake Fianga",@"Album" : @"News", @"Hashtag" : @"Lake"},@{@"Place" : @"Lake Tanganyika",@"Album" : @"Great Lake Trip", @"Hashtag" : @"African Great Lake"},@{@"Place" : @"Lake Bamendjing",@"Album" : @"River Trip", @"Hashtag" : @"Noun River"},@{@"Place" : @"Lake Wanaka",@"Album" : @"Larget Lake Trip", @"Hashtag" : @"New Zealand's fourth largest lake"},@{@"Place" : @"NZ Contract Bridge",@"Album" : @"Bridge", @"Hashtag" : @"NZ Contract Bridge Association"},@{@"Place" : @"Zion National Park",@"Album" : @"Park Trip", @"Hashtag" : @"Park in Utah"}];
    
    [self requestForDeviceToken:application];
    [self autoLogin];
    
    
    
    
    //for fetching user location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"%@", [self deviceLocation]);
    _strLatitude=[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    _strLongitude=[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Drop Off"
                                                          action:nil
                                                           label:self.dropOffScreen
                                                           value:nil] build]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - CLLocationManagerDelegate -

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError: %@", error);
    NSString *errorString;
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            [UIAlertView showAlertViewWithTitle:@"" message:@"Please allow application to use your location from  Settings-> Privacy-> Location Services."];
            //[manager stopUpdatingLocation];
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            [UIAlertView showAlertViewWithTitle:@"Error" message:@"Failed to Get Your Location"];
            // [UIAlertView *errorAlert = [[UIAlertView alloc]
            //                     initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil //cancelButtonTitle:@"OK" otherButtonTitles:nil];
            // [errorAlert show];
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //NSLog(@"%@", [self deviceLocation]);
    _strLatitude=[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    _strLongitude=[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}


#pragma mark - PushNotification Method

-(void)requestForDeviceToken:(UIApplication *)application
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
#pragma GCC diagnostic pop
    }
}

#pragma mark Pushnotification Delegate method

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //    Token will be generated from APNS.
    self.strDeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.strDeviceToken = [self.strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [USERDEFAULTS setObject:self.strDeviceToken forKey:KEYDEVICETOKEN];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mini" message:self.strDeviceToken delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *device=[USERDEFAULTS objectForKey:KEYDEVICETOKEN];
    NSLog(@"Device token is %@",device);
}
//
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    self.strDeviceToken = @"";
    [[NSUserDefaults standardUserDefaults] setObject:self.strDeviceToken forKey:KEYDEVICETOKEN];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [application setApplicationIconBadgeNumber:0];
    NSLog(@"userInfo:%@",userInfo);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        
    }
    else
    {
        if ([myTab.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *objNavController = (UINavigationController*)myTab.selectedViewController;
            [objNavController popToRootViewControllerAnimated:NO];
            
            myTab.selectedIndex=3;
//            [self setimage:3];
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_4~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_4"]];
        }
//        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"type" ]isEqualToString:@"Notification List"])
//        {
//            if ([myTab.selectedViewController isKindOfClass:[UINavigationController class]])
//            {
//                UINavigationController *objNavController = (UINavigationController*)myTab.selectedViewController;
//                [objNavController popToRootViewControllerAnimated:NO];
//            }
//
//        }
    }
}

#pragma mark - Tab Delegate Method

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [[tabBarController viewControllers] indexOfObject:viewController];
    
    switch (index)
    {
        case 0:
        {
            [self setimage:0];
            return YES;
        }
            break;
        case 1:
        {
            [self setimage:1];
                tabBarController.selectedIndex = index;
                [tabBarController.viewControllers[index] popToRootViewControllerAnimated:NO];
                
                return YES;
        }
            break;
        case 2:
        {
            [self setimage:2];
            tabBarController.selectedIndex = index;
            [tabBarController.viewControllers[index] popToRootViewControllerAnimated:NO];
            return YES;
        }
            break;
        case 3:
        {
            [self setimage:3];
            return YES;
        }
            break;
        case 4:
        {
            [self setimage:4];
            return YES;
        }
            break;
        default:
            return YES;
            break;
    }
}

-(void)setimage:(NSInteger)selectedindex
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        if(selectedindex==0){
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_1~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_1"]];
            
        }
        else if(selectedindex==1){
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_2~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_2"]];
            
        }
        else if(selectedindex==2){
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_3~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_3"]];
            
        }
        else if(selectedindex==3){
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_4~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_4"]];
            
        }
        else if(selectedindex==4){
            if (iPhone6)
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_5~667h"]];
            else
                [imagefooter setImage:[UIImage imageNamed:@"tabbar_5"]];
            
        }
    }
}

-(void)tabbarImage{
    imagefooter=[[UIImageView alloc] init];
    if (iPhone6)
        [imagefooter setImage:[UIImage imageNamed:@"tabbar_1~667h"]];
    else
        [imagefooter setImage:[UIImage imageNamed:@"tabbar_1"]];
    //
    //    NSLog(@"bounds.origin.x: %f", self.window.bounds.origin.x);
    //    NSLog(@"bounds.origin.y: %f", self.window.bounds.origin.y);
    //    NSLog(@"bounds.size.width: %f", self.window.bounds.size.width);
    //    NSLog(@"bounds.size.height: %f", self.window.bounds.size.height);
    //    NSLog(@"bounds = %@", NSStringFromCGRect(self.window.bounds));
    
    
    CGRect windowFrame= self.window.frame;
    
    if (windowFrame.size.width>windowFrame.size.height)
    {
        //        x = x + y;  // x now becomes 15
        //        y = x - y;  // y becomes 10
        //        x = x - y;  // x becomes 5
        //  swap two numbers without using a temporary variable
        windowFrame.size.width = windowFrame.size.width + windowFrame.size.height;
        windowFrame.size.height = windowFrame.size.width - windowFrame.size.height;
        windowFrame.size.width = windowFrame.size.width - windowFrame.size.height;
    }
    imagefooter.frame = CGRectMake(0,windowFrame.size.height - imagefooter.image.size.height,windowFrame.size.width,imagefooter.image.size.height);
    
    //    imagefooter.frame = CGRectMake(0,self.window.frame.size.height - imagefooter.image.size.height,self.window.frame.size.width,imagefooter.image.size.height);
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

-(BOOL)checkIfVideoExists:(NSString *)videoName // kandhal
{
    NSString* paths1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *savedVideoPath = [paths1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",videoName]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savedVideoPath];
    return fileExists;
}
- (void)clearCachedDirectory
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mainPath    = [myPathList  objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:mainPath error:nil];
    for (NSString *filename in fileArray)  {
        [fileMgr removeItemAtPath:[mainPath stringByAppendingPathComponent:filename] error:NULL];
    }
}
-(void)removeVideoFileWithName:(NSString*)strName
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mainPath    = [myPathList  objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:[mainPath stringByAppendingPathComponent:strName] error:NULL];
}
-(NSString *)UTCtoDeviceTimeZone:(NSString *)UTCTime
{
    NSString* input = UTCTime;
    NSString* format1 = @"yyyy-MM-dd HH:mm:ss";
//    NSString* format2 = @"yyyy-MM-dd HH:mm a";
    
    
    // Set up an NSDateFormatter for UTC time zone
    NSDateFormatter* formatterUtc = [[NSDateFormatter alloc] init];
    [formatterUtc setDateFormat:format1];
    [formatterUtc setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Cast the input string to NSDate
    NSDate* utcDate = [formatterUtc dateFromString:input];
    
    // Set up an NSDateFormatter for the device's local time zone
    NSDateFormatter* formatterLocal = [[NSDateFormatter alloc] init];
    //    [formatterLocal setDateFormat:format2];
    [formatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
    
    //    NSLog(@"utc:   %@", utcDate);
    //    return [formatterLocal stringFromDate:utcDate];
    
    [formatterLocal setDateFormat:@"yyyy"];
    NSString *year=[formatterLocal stringFromDate:utcDate];
    [formatterLocal setDateFormat:@"MMM"];
    NSString *month=[formatterLocal stringFromDate:utcDate];
    [formatterLocal setDateFormat:@"dd"];
    NSString *day=[formatterLocal stringFromDate:utcDate];
    [formatterLocal setDateFormat:@"HH:mm"];
    NSString *time=[formatterLocal stringFromDate:utcDate];
    
    NSString *completeDate=[NSString stringWithFormat:@"%@ %@ %@   %@",day,month,year,time];
    return completeDate;
}

-(void)autoLogin
{
    if([[USERDEFAULTS objectForKey:KEYLOGGEDIN] isEqualToString:@"1"])
    {
        [self PushToNextView:YES];
    }
}

-(void)PushToNextView:(BOOL)shouldAnimate
{
    UIStoryboard *sub_storyboard = [UIStoryboard storyboardWithName:@"MainApplication" bundle:nil];
    myTab=(UITabBarController *)[sub_storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    
    myTab.delegate=self;
    if (iPhone6)
        [imagefooter setImage:[UIImage imageNamed:@"tabbar_1~667h"]];
    else
        [imagefooter setImage:[UIImage imageNamed:@"tabbar_1"]];
    
    [myTab.view addSubview:imagefooter];
    //    myTab.view.clipsToBounds=YES;
    [(UINavigationController *)self.window.rootViewController pushViewController:myTab animated:shouldAnimate];
    
    //    NSLog(@"height %f",myTab.tabBar.frame.size.height);
    
    //    [myTab.tabBar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //
    //        UITabBarItem *tabBarItem = (UITabBarItem*)obj;
    //        NSString *strNormalImageName = [NSString stringWithFormat:@"tab_%lu.png",(unsigned long)idx+1];
    //        NSString *strSelectedImageName = [NSString stringWithFormat:@"tab_%lu_selected.png",(unsigned long)idx+1];
    //        tabBarItem.image = [[UIImage imageNamed:strNormalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //        tabBarItem.selectedImage = [[UIImage imageNamed:strSelectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //        tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    //
    //    }];
    //    myTab.tabBar.backgroundImage = [UIImage imageNamed:@"bottom_bar.png"];
    //    myTab.tabBar.layer.borderColor = myTab.tabBar.tintColor.CGColor;
}


@end
