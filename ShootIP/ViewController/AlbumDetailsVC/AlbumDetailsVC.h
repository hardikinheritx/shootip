//
//  AlbumDetailsVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/19/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumDetailsVC : UIViewController
{
    
    IBOutlet UITableView *tblAlbumDetail;
}

@property (strong, nonatomic) IBOutlet UILabel *lblTitleAlbumName;


- (IBAction)actionBack:(id)sender;

@end
