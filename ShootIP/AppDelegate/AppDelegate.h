//
//  AppDelegate.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>



@property (nonatomic,strong) NSString *strLatitude;
@property (nonatomic,strong) NSString *strLongitude;
@property(nonatomic, retain) CLLocationManager *locationManager;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *myTab;
@property (strong, nonatomic) UIImageView *imagefooter;
-(void)PushToNextView:(BOOL)shouldAnimate;
-(NSString *)UTCtoDeviceTimeZone:(NSString *)UTCTime;

//By Paras
@property(strong,nonatomic)NSMutableDictionary *UserInfodict;
@property(strong,nonatomic)NSArray *arrayAlbumList;
@property(strong,nonatomic)NSArray *arrayNotificationList;
@property (strong, nonatomic) NSMutableArray *arraySettingsList;
@property(strong,nonatomic)NSArray *arrayTopDestinationList;
@property(strong,nonatomic)NSArray *arraySearchData;
//By Paras
//kandhal
-(BOOL)checkIfVideoExists:(NSString *)videoName;
- (void)clearCachedDirectory;
-(void)removeVideoFileWithName:(NSString*)strName;

@property(nonatomic,retain)NSString *strDeviceToken;
@property(nonatomic,retain)NSString *strVideoURL;
@property(nonatomic,retain)NSString *dropOffScreen;


@end

