//
//  VideoPostCell.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/19/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"
#import "EDStarRating.h"
@interface VideoPostCell : UITableViewCell <EDStarRatingProtocol>
@property (strong, nonatomic) IBOutlet UIButton *btnComment;
@property (strong, nonatomic) IBOutlet UIButton *btnReportOrEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (strong, nonatomic) IBOutlet UIButton *btnImgLikeDislike;
@property (strong, nonatomic) IBOutlet EDStarRating *starView;
@property (strong, nonatomic) IBOutlet UIButton *btnAddVideoToAlbum;
@property (strong, nonatomic) IBOutlet UIImageView *imgLikeDislike;
@property (strong, nonatomic) IBOutlet UIButton *btnLikeDisLike;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;

@property (strong, nonatomic) IBOutlet UILabel *lblNoOfComment;
@property (strong, nonatomic) IBOutlet UILabel *lblNoOfVideoShared;
@property (strong, nonatomic) IBOutlet UILabel *lblNoOfLike;
@property (strong, nonatomic) IBOutlet UILabel *lblPlaceName;
@property (strong, nonatomic) IBOutlet UILabel *lblPostCreatedDateAndTime;
@property (strong, nonatomic) IBOutlet UIButton *btnPlayVideo;
@property (strong, nonatomic) IBOutlet UIImageView *imgVideoThumbnail;

@property (strong, nonatomic) IBOutlet UIView *viewVideoPreview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *videoActivityIndicator;

-(void)ConfigureCell:(NSString *)rating postDict:(NSDictionary *)dictPost;

-(void)btnMapAction:(UIButton *)sender;

@end
