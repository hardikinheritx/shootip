//
//  NotificationListVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationListCell.h"

@interface NotificationListVC : UIViewController<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>
{
    
    IBOutlet UILabel *lblNoData;
}

@property (strong, nonatomic) IBOutlet UITableView *tblNotificationList;

@end
