//
//  SearchVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/7/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchListCell.h"
#import "SearchDetailsVC.h"

@interface SearchVC : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UIButton *btnSearchHashtag;
    IBOutlet UIButton *btnSearchAlbum;
    IBOutlet UIButton *btnSearchPlace;
    
}


@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) IBOutlet UIImageView *imgTab;
@property (strong, nonatomic) IBOutlet UITableView *tblSearch;
@property (strong,nonatomic)NSMutableArray *arraySearchList;
@property (strong,nonatomic)NSMutableArray *arrayUserSearchList;

@property NSInteger OldIndexTab;

@property NSInteger CurrentIndexTab;

- (IBAction)actionTab:(id)sender;



@end
