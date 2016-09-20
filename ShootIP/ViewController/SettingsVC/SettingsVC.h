//
//  SettingsVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/12/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsListCell.h"
#import "ChangePasswordVC.h"


@interface SettingsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblSettingsList;

@property NSInteger switchValue;

- (IBAction)actionback:(id)sender;

@end
