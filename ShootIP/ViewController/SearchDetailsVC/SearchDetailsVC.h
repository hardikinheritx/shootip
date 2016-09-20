//
//  SearchDetailsVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/18/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumCell.h"
#import "AlbumDetailsVC.h"
#import "VideoPostCell.h"

@interface SearchDetailsVC : UIViewController
{
    
    IBOutlet UITableView *tblSearch;
}

@property(strong,nonatomic)NSString *strTitleName;
@property(strong,nonatomic)IBOutlet UILabel *lblTitleName;

@property(assign)BOOL isAlbumSelect;

- (IBAction)actionback:(id)sender;
@end
