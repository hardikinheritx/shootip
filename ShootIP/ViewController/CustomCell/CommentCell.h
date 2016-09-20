//
//  CommentCell.h
//  ShootIP
//
//  Created by milap kundalia on 1/21/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView_Subclass.h"
@interface CommentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *viewBG;
@property (strong, nonatomic) IBOutlet UILabel *lblComment;
@property (strong, nonatomic) IBOutlet UIImageView_Subclass *imgUserProfilePic;

@end
