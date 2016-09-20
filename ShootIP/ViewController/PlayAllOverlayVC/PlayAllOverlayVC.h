//
//  PlayAllOverlayVC.h
//  ShootIP
//
//  Created by Kandhal Bhutiya on 5/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  PlayAllOverlayVCDelegate;
@protocol PlayAllOverlayVCDelegate <NSObject>

-(void)goLocation;
-(void)actionLike;
-(void)donePlayer;
@end



@interface PlayAllOverlayVC : UIViewController
{
    
    BOOL iSOvelayViewShow;
    NSMutableDictionary *dictOfPost;
}
@property (nonatomic, strong) id<PlayAllOverlayVCDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIView *overlayVC;
@property (weak, nonatomic) IBOutlet UIView *lowerView;
@property (weak, nonatomic) IBOutlet UIView *upperView;
- (IBAction)actionGoLocation:(id)sender;
- (IBAction)actionLike:(id)sender;
- (IBAction)actionDonePlayer:(id)sender;
-(void)updateData:(NSMutableDictionary*)dictData;
@property (weak, nonatomic) IBOutlet UIView *viewLilke;


@property (weak, nonatomic) IBOutlet UIImageView *imgLikeDislikeView;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UILabel *lbllocation;
@end
