//
//  PlaceVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "KSToastView.h"
#import "CategoryVC.h"
#import "AlbumSelectionVC.h"
#import "PlayAllOverlayVC.h"
@class CBStoreHouseRefreshControl;

@interface PlaceVC : UIViewController<AVPlayerViewControllerDelegate,PlayAllOverlayVCDelegate,CategoryVCDelegate,VideoAddedDetailsDelegate>
{
    IBOutlet UITableView *tblPlaceList;
    IBOutlet NSLayoutConstraint *viewSortPlayFunctionHeightContraint;
    IBOutlet UILabel *lblNavTitle;
    IBOutlet UIButton *btnFollowPlace;
    IBOutlet UIView *viewSortPlayFunction;
    IBOutlet UIView *viewShareAndReportPopUp;
    IBOutlet UIView *viewInnerSortPopUp;
    IBOutlet UIView *viewInnerShareAndReportPopUp;
    IBOutlet UIView *viewSortPopUp;
    UILabel *messageLabel;

}
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;

@property(strong, nonatomic) NSString *fromWhere;
@property(strong, nonatomic) NSString *strTitle;
@property(strong, nonatomic) NSString *strOtherUserId;
@property(strong, nonatomic) NSDictionary *dictPlaceDetail;

- (void)getDataFromCategory:(NSDictionary*)getCategoryDict;
-(void)reloadTableDataForVideoCount:(NSDictionary*)getVideoDetails;

- (IBAction)actionBack:(id)sender;
- (IBAction)actionFollowPlace:(id)sender;

- (IBAction)actionSort:(id)sender;
- (IBAction)actionCloseSortPopUp:(id)sender;
- (IBAction)actionCloseShareAndReportPopUp:(id)sender;
- (IBAction)actionShareAndReport:(id)sender;
- (IBAction)actionSortType:(id)sender;
- (IBAction)actionPlayAllVideo:(id)sender;
- (IBAction)actionCategoryPopUp:(id)sender;

- (IBAction)actionDonePlayer:(id)sender;


@end
