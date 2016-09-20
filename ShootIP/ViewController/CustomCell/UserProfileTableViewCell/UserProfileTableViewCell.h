//
//  UserProfileTableViewCell.h
//  ShootIP
//
//  Created by milap kundalia on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgUserProfilePic;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *changeProfilePicBtn;
@property (strong, nonatomic) IBOutlet UILabel *lblShootIPsCount;
@property (strong, nonatomic) IBOutlet UIButton *btnShootIPs;
@property (strong, nonatomic) IBOutlet UILabel *lblAlbumCount;
@property (strong, nonatomic) IBOutlet UIButton *btnAlbum;
@property (strong, nonatomic) IBOutlet UILabel *lblLookoutsCount;
@property (strong, nonatomic) IBOutlet UIButton *btnLookouts;



@property (strong, nonatomic) IBOutlet UIButton *btnShootIpsList;
@property (strong, nonatomic) IBOutlet UIButton *btnAlbumsList;

@end
