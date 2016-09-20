//
//  NewPostVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/13/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"
#import "RecentPlaces.h"
#import "AlbumSelectionVC.h"
#import "CategoryVC.h"



@interface NewPostVC : UIViewController<UITextViewDelegate,EDStarRatingProtocol,CategoryVCDelegate,FBSDKSharingDelegate>
{
    IBOutlet UIActivityIndicatorView *viewActivityIndicator;
    IBOutlet NSLayoutConstraint *consCategoryAspectRatio;
    IBOutlet UIView *viewCategory;
    IBOutlet UIButton *btnAddCategory;
    IBOutlet UIButton *btnDeletePost;
    IBOutlet UIButton *btnCreateOrSave;
    IBOutlet UILabel *lblNavBarTitle;
    IBOutlet UIView *viewNewAlbumName;
    IBOutlet UIView *viewAddToAlbum;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *lblAddDescription;
    IBOutlet UITextView *txtPostDescription;
    IBOutlet UIButton *btnTwitter;
    IBOutlet UIButton *btnAddLocation;
    IBOutlet UIButton *btnAddToAlbum;
    IBOutlet UIButton *btnFacebook;
    IBOutlet UITextField *txtAlbumName;
    IBOutlet EDStarRating *viewRating;
    IBOutlet UIButton *btnPlay;
    IBOutlet UIImageView *imagePlayerThumbnil;
    IBOutlet UIView *viewVideoPreview;
}
@property (nonatomic,strong)FBSDKShareVideoContent *content;


@property(strong, nonatomic) RecentPlaces *objRecentPlace;

@property (nonatomic,strong) NSDictionary *dictPostDetails;

@property (nonatomic, strong) NSString *performEdit;
@property(strong, nonatomic) NSDictionary *getAlbumInfo;
- (void)getDataFromAlbum:(NSDictionary*)getAlbumDict;
- (void)getDataFromCategory:(NSDictionary*)getCategoryDict;


- (IBAction)actionDeletePost:(id)sender;
- (IBAction)actionCreateOrEditPost:(id)sender;

- (IBAction)actionTwitterClicked:(id)sender;
- (IBAction)actionFacebookClicked:(id)sender;
- (IBAction)actionAddToAlbum:(id)sender;
- (IBAction)actionCreateNewAlbum:(id)sender;
- (IBAction)actionAddToExistingAlbum:(id)sender;
- (IBAction)actionCloseAddToAlbumView:(id)sender;
- (IBAction)actionAddLocation:(id)sender;
- (IBAction)actionPlayVideo:(id)sender;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionAddCategory:(id)sender;




@end
