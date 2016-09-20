//
//  LoginVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface LoginVC : UIViewController<BSKeyboardControlsDelegate>
{
    IBOutlet UIView *viewForgotPasswordPopup;
    IBOutlet UIView *viewForgotPassword;
    IBOutlet UITextField *txtForgotPasswordEmailId;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtEmail;
}

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

- (IBAction)actionSignIn:(id)sender;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionForgotPasswordClicked:(id)sender;
- (IBAction)actionSend:(id)sender;
- (IBAction)actionCloseForgotPasswordPopup:(id)sender;

@end
