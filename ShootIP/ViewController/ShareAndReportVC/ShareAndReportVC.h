//
//  ShareAndReportVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 2/22/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareAndReportVC : UIViewController <FBSDKSharingDelegate>
{
    
}

@property(strong,nonatomic)NSMutableDictionary *getPostData;

- (IBAction)actionShareOnFacebook:(id)sender;
- (IBAction)actionShareOnTwitter:(id)sender;
- (IBAction)actionReportAbuse:(id)sender;
- (IBAction)actionClose:(id)sender;
@property (nonatomic,strong)FBSDKShareVideoContent *content;



@end
