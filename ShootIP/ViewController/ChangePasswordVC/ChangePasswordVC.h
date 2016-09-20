//
//  ChangePasswordVC.h
//  ShootIP
//
//  Created by Paras Modi on 1/12/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"



//@interface ChangePasswordVC : UIViewController<UITextFieldDelegate, BSKeyboardControlsDelegate>
@interface ChangePasswordVC : UIViewController<UITextFieldDelegate, BSKeyboardControlsDelegate>
{
    
    IBOutlet UIScrollView *scrollView;
}

@property (strong, nonatomic) IBOutlet UITextField *txtOldPwd;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPwd;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPwd;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

- (IBAction)actionback:(id)sender;

- (IBAction)actionSave:(id)sender;

@end
