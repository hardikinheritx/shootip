//
//  PrivacyPolicyVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 3/16/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyPolicyVC : UIViewController<UIWebViewDelegate>
{
    
    IBOutlet UIWebView *webView;
}
- (IBAction)actionBack:(id)sender;

@end
