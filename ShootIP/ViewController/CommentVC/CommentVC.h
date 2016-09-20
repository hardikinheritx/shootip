//
//  CommentVC.h
//  ShootIP
//
//  Created by milap kundalia on 1/21/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
@interface CommentVC : UIViewController<HPGrowingTextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
    IBOutlet NSLayoutConstraint *viewCommentHeightConstraint;
    IBOutlet HPGrowingTextView *viewComment;
    IBOutlet UITableView *tblComments;
}
- (IBAction)btnBackAction:(id)sender;
- (IBAction)btnSendCommentAction:(id)sender;
@property (nonatomic,assign) BOOL isForPost;
@property (strong,nonatomic)NSString *strPostId;
@property (strong,nonatomic)NSString *strCommentCount;

@end
