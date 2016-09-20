//
//  HomeVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePostCell.h"
#import "VideoPostCell.h"
#import "CategoryVC.h"
#import "AlbumSelectionVC.h"
#import "PlayAllOverlayVC.h"


@class CBStoreHouseRefreshControl;

@interface HomeVC : UIViewController<AVPlayerViewControllerDelegate,PlayAllOverlayVCDelegate,CategoryVCDelegate,AVAudioPlayerDelegate>
{
    IBOutlet UIView *viewShareAndReportPopUp;
    IBOutlet UIView *viewInnerSortPopUp;
    IBOutlet UIView *viewInnerShareAndReportPopUp;
    __weak IBOutlet UIView *viewSortAndPlayAll;
    IBOutlet UIView *viewSortPopUp;
    IBOutlet UITableView *tblHomePost;
    IBOutlet UIButton *btnSort;
    IBOutlet UIButton *btnPlayAll;
    IBOutlet UIButton *btnCategory;
    __weak IBOutlet UIImageView *imgViewLikeDislike;

    
}
@property (weak, nonatomic) IBOutlet UIView *overlaySubView;
@property (weak, nonatomic) IBOutlet UIView *viewOverlyPlayer;
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIView *lowerView;
-(void)downloadDoneForUrl:(NSString*)strUrl indexAt:(int)index ;// kandhal
- (void)downloadFailedForUrl; 
- (void)getDataFromCategory:(NSDictionary*)getCategoryDict;
-(void)reloadTableDataForVideoCount:(NSDictionary*)getVideoDetails;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
- (IBAction)actionSort:(id)sender;
- (IBAction)actionCloseSortPopUp:(id)sender;
- (IBAction)actionCloseShareAndReportPopUp:(id)sender;
- (IBAction)actionShareAndReport:(id)sender;
- (IBAction)actionSortType:(id)sender;
- (IBAction)actionPlayAllVideo:(id)sender;
- (IBAction)actionCategoryPopUp:(id)sender;
- (IBAction)actionPostDetail:(id)sender;
- (IBAction)actionLike:(id)sender;
- (IBAction)actionDonePlayer:(id)sender;
- (IBAction)actionBack:(id)sender;


-(void)goLocation;
-(void)actionLike;
-(void)donePlayer;

@property (weak, nonatomic) IBOutlet UIButton *btnLikeDislike;
@property (weak, nonatomic) IBOutlet UIButton *actionDone;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (nonatomic,strong) NSString *strMainCategory;


@property (strong, nonatomic) AVPlayer *avPlayer;

@end
