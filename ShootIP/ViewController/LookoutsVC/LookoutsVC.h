//
//  LookoutsVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/11/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookoutsListCell.h"

@interface LookoutsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblLookoutsList;

@property(strong,nonatomic)NSArray *arrayLookoutsListInfo;

@property(strong,nonatomic)NSMutableArray *mutablearrayLookoutsListInfo;
@property(strong,nonatomic)NSString *strOtherUserID;


- (IBAction)actionback:(id)sender;

@end
