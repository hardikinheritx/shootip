//
//  NotificationListCell.h
//  ShootIP
//
//  Created by Paras Modi on 1/11/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationListCell : UITableViewCell {
    
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imgOfPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblNameOfPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblCountryOfPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblDescOfPlace;


@end
