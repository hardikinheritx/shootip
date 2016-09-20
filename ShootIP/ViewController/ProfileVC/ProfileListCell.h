//
//  HomePostCell.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface ProfileListCell : UITableViewCell {

}
@property (strong, nonatomic) IBOutlet UILabel *lblPostPlace;

@property (strong, nonatomic) IBOutlet UILabel *lblPostDate;

@property (strong, nonatomic) IBOutlet UIImageView *imgPostVideo;

@property (strong, nonatomic) IBOutlet EDStarRating *ImgStarRating;


@end
