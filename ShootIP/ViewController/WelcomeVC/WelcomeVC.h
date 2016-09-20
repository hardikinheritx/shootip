//
//  WelcomeVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeVC : UIViewController
{
    IBOutlet UILabel *lblAlreadyHaveAccount;
    
}


- (IBAction)actionSignUpWithFacebook:(id)sender;
- (IBAction)actionSignUpWithEmail:(id)sender;

@end
