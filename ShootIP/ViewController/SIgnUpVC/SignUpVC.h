//
//  SIgnUpVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 1/4/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface SignUpVC : UIViewController<BSKeyboardControlsDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIButton *btnClearUsername;
    IBOutlet UIImageView *imgUserProfile;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextField *txtConfirmPassword;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtUsername;
    IBOutlet UIButton *btnUserProfile;
}

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

- (IBAction)actionSignUp:(id)sender;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionUserProfile:(id)sender;
- (IBAction)actionClearUsername:(id)sender;

@end
