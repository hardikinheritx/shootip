//
//  OtherUserProfileVC.h
//  ShootIP
//
//  Created by milap kundalia on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileVC.h"
@interface OtherUserProfileVC : ProfileVC

- (IBAction)btnBackAction:(id)sender;
@property (nonatomic,strong)NSString *strUserID;
@end
