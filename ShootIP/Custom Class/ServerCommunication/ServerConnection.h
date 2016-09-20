//
//  ServerConnection.h
//  TrainingPal
//
//  Created by  milap kundalia on 11/6/15.
//  Copyright (c) 2015 Inheritx. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JSON.h"

@protocol ConnectionDelegate <NSObject>

- (void)ConnectionDidFinishRequestURL: (NSString*)reqURL Data:(NSMutableDictionary*) dictData;
- (void)ConnectionDidFailRequestURL: (NSString*)reqURL  Data: (NSString*)nData;
@optional
- (void)downloadDoneForUrl:(NSString*)strUrl indexAt:(int)index;
- (void)downloadFailedForUrl;
-(void)downloadFailed;
@end

@interface ServerConnection : NSObject
{
    @private
        id<ConnectionDelegate> connectionDelegate;
    AFHTTPSessionManager *searchManager;
    NSURLSessionDownloadTask *downloadTask;
    NSString *strCurrentScreen;
    NSMutableArray *arrUrlTemp;
    
    
}
@property BOOL isPlaying;
@property (nonatomic,strong) id connectionDelegate;
-(void)requestWithURL:(NSString *)URLString method:(NSString*)method data:(NSMutableDictionary*)dataDict withImages:(NSMutableDictionary *)dictImages withVideo:(NSDictionary *)dictVideo;
+ (ServerConnection*)sharedConnectionWithDelegate:(id)delegate;
+ (ServerConnection*)sharedConnection;
+ (BOOL)isConnected;
-(BOOL)isInternetAvailable;
-(void)downloadVideo:(NSString *)strUrl videoName:(NSString *)strVideoName indexAt:(int)index arrayUrls:(NSMutableArray*)arrUrl; // kandhal
-(void)stopDownloadFor:(NSString*)strScreenType;

@end
