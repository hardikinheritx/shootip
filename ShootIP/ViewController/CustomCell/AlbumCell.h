//
//  SearchAlbumDetailsCell.h
//  ShootIP
//
//  Created by Paras Modi on 1/18/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgAlbumIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblAlbumName;
@property (strong, nonatomic) IBOutlet UIButton *btnAlbumName;
@property (strong, nonatomic) IBOutlet UILabel *lblAlbumPostDate;
@property (strong, nonatomic) IBOutlet UILabel *lblAlbumDuration;
@property (strong, nonatomic) IBOutlet UIImageView *imgAlbum;
@property (strong, nonatomic) IBOutlet UIButton *btnCommentAlbum;
@property (strong, nonatomic) IBOutlet UIButton *btnLikeAlbum;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalComment;
@property (strong, nonatomic) IBOutlet UIButton *btnImgLikeAlbum;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalLike;
@property (strong, nonatomic) IBOutlet UIButton *btnReport;
@property (strong, nonatomic) IBOutlet UIImageView *imgPostUser;
@property (strong, nonatomic) IBOutlet UILabel *lblPostUserName;

@end
