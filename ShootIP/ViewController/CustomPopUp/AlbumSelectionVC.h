//
//  AlbumSelectionVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/28/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPostVC.h"
#import "HomeVC.h"

@protocol NewPostVCDelegate<NSObject>

- (void)getDataFromAlbum:(NSDictionary*)getAlbumDict;

@end

@protocol VideoAddedDetailsDelegate<NSObject>

-(void)reloadTableDataForVideoCount:(NSDictionary*)getVideoDetails;

@end

@interface AlbumSelectionVC : UIViewController
{
    IBOutlet UITableView *tblAlbumListing;
    IBOutlet UITextField *txtAlbumName;
    IBOutlet UIView *viewCreateAlbum;
    IBOutlet UIView *viewExistingAlbumList;
    IBOutlet UIView *viewAddToAlbum;
}

@property (strong, nonatomic) id<NewPostVCDelegate>delegate;
@property (strong, nonatomic) id<VideoAddedDetailsDelegate>videoDelegate;

@property (strong, nonatomic) NSString *strPostId;
@property (nonatomic) BOOL shouldAddVideoToAlbum;

- (IBAction)actionCloseAlbumSelection:(id)sender;
- (IBAction)actionAddToExisting:(id)sender;
- (IBAction)actionCreateNewAlbum:(id)sender;
- (IBAction)actionOk:(id)sender;
- (IBAction)actionCloseExistingAlbumList:(id)sender;

@end
