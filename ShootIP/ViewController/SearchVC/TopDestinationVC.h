//
//  TopDestinationVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/13/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopDestinationListCell.h"
#import "SearchVC.h"

@interface TopDestinationVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblTopDestination;

- (IBAction)actionSearch:(id)sender;

@end
