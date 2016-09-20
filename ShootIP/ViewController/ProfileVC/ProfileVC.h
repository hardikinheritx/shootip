//
//  ProfileVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileListCell.h"
#import "ProfileAlbumCell.h"
#import "LookoutsVC.h"
#import "SettingsVC.h"
#import "PlayAllVideoCell.h"
#import "AlbumListingVC.h"
#import "PlaceVC.h"
#import "UserProfileTableViewCell.h"
#import "ShareAndReportVC.h"
#import "CommentVC.h"

@interface ProfileVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITabBarDelegate,UITableViewDelegate,UITableViewDataSource,EDStarRatingProtocol,UITextFieldDelegate,AVPlayerViewControllerDelegate> {

}
-(void)downloadDoneForUrl:(NSString*)strUrl indexAt:(int)index ;// kandhal
-(void)downloadFailedForUrl;
-(void)goLocation;
-(void)actionLike;
-(void)donePlayer;
@property NSUInteger btnSelectIndex;


@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) UIAlertController *alertCtrl;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) IBOutlet UITableView *tblProfileList;
@property (strong, nonatomic) IBOutlet UIView *PopupViewEditProfile;
@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (nonatomic,strong)NSString *strOtherUserID;


-(void)reloadTableDataForVideoCount:(NSDictionary*)getVideoDetails;
- (IBAction)actionChooseProfileImage:(id)sender;
- (IBAction)actionTextLookouts:(id)sender;
- (IBAction)actionList:(id)sender;
- (IBAction)actionAlbumClicked:(id)sender;
- (IBAction)actionPopupOk:(id)sender;
- (IBAction)actionPopupCancel:(id)sender;
- (IBAction)actionSettings:(id)sender;
@end
