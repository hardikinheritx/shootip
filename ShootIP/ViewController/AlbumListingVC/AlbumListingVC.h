//
//  AlbumListingVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumListingVC : UIViewController
{
    IBOutlet UITableView *tblAlbumListing;
}
- (IBAction)actionBack:(id)sender;

@property (nonatomic,strong)NSString *strOtherUserID;

@end
