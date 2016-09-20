//
//  PlayAllOverlayVC.m
//  ShootIP
//
//  Created by Kandhal Bhutiya on 5/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "PlayAllOverlayVC.h"
#import "PlaceVC.h"

@interface PlayAllOverlayVC ()

@end

@implementation PlayAllOverlayVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *dismissGestureRecognition = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissDoubleTap:)];
    dismissGestureRecognition.numberOfTapsRequired = 1;
    [_overlayVC addGestureRecognizer:dismissGestureRecognition];
    dictOfPost =[[NSMutableDictionary alloc]init];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*NSLog(@"LIke View is %@",_viewLilke);
    NSLog(@"Self View is %@",self.view);
    NSLog(@"Upper View is %@",_upperView);*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleDismissDoubleTap:(UIGestureRecognizer*)tap
{
    
    [UIView animateWithDuration:0.4 animations:^{
        
        if (_upperView.frame.origin.y == -40)
        {
            iSOvelayViewShow = YES;
            _upperView.frame=CGRectMake(_upperView.frame.origin.x, 0,_upperView.frame.size.width ,_upperView.frame.size.height);
            [_upperView layoutIfNeeded];
            _lowerView.frame=CGRectMake(_lowerView.frame.origin.x, _overlayVC.frame.size.height-40,_lowerView.frame.size.width ,_lowerView.frame.size.height);
            [_lowerView layoutIfNeeded];
        }else
        {
            iSOvelayViewShow = NO;
            _upperView.frame=CGRectMake(_upperView.frame.origin.x, -40,_upperView.frame.size.width ,_upperView.frame.size.height);
            [_upperView layoutIfNeeded];
            _lowerView.frame=CGRectMake(_lowerView.frame.origin.x, _overlayVC.frame.size.height+40,_lowerView.frame.size.width ,_lowerView.frame.size.height);
            [_lowerView layoutIfNeeded];
            
        }
    }];
    
}
- (void) orientationChanged:(NSNotification *)note
{
//    UIDevice * device = note.object;
//    
//    switch(device.orientation)
//    {
//            
//        case UIDeviceOrientationPortrait:
//        {
//            NSLog(@"UIDeviceOrientationPortrait");
//            
//            _overlayVC.frame=CGRectMake(0, 0,[APPDELEGATE window].frame.size.width ,[APPDELEGATE window].frame.size.height);
//            
//            //            if (iSOvelayViewShow == YES)
//            //            {
//            //                _lowerView.frame= CGRectMake(_lowerView.frame.origin.x, [APPDELEGATE window].frame.size.height-40, [APPDELEGATE window].frame.size.width,40);
//            //                _upperView.frame= CGRectMake(_upperView.frame.origin.x, _upperView.frame.origin.y, [APPDELEGATE window].frame.size.width, 40);
//            //
//            //            }else
//            //            {
//            //            _lowerView.frame= CGRectMake(_lowerView.frame.origin.x, [APPDELEGATE window].frame.size.height+40, [APPDELEGATE window].frame.size.width,40);
//            //            _upperView.frame= CGRectMake(_upperView.frame.origin.x, _upperView.frame.origin.y-40, [APPDELEGATE window].frame.size.width, 40);
//            //            }
//            break;
//        }
//        case UIDeviceOrientationPortraitUpsideDown:
//        {
//            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
//            
//            _overlayVC.frame=CGRectMake(0, 0,[APPDELEGATE window].frame.size.width ,[APPDELEGATE window].frame.size.height);
//            //
//            //            if (iSOvelayViewShow == YES)
//            //            {
//            //                _lowerView.frame= CGRectMake(_lowerView.frame.origin.x, [APPDELEGATE window].frame.size.height-40, [APPDELEGATE window].frame.size.width,40);
//            //                _upperView.frame= CGRectMake(_upperView.frame.origin.x, _upperView.frame.origin.y, [APPDELEGATE window].frame.size.width, 40);
//            //
//            //            }else
//            //            {
//            //                _lowerView.frame= CGRectMake(_lowerView.frame.origin.x, [APPDELEGATE window].frame.size.height+40, [APPDELEGATE window].frame.size.width,40);
//            //                _upperView.frame= CGRectMake(_upperView.frame.origin.x, _upperView.frame.origin.y-40, [APPDELEGATE window].frame.size.width, 40);
//            //            }
//            //            break;
//        }
//        case UIDeviceOrientationLandscapeLeft:
//        {
//            _overlayVC.frame=CGRectMake(0, 0,[APPDELEGATE window].frame.size.height ,[APPDELEGATE window].frame.size.width);
//
////            NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
////            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
////            NSLog(@"UIDeviceOrientationLandscapeLeft");
////            //            [self handleDismissDoubleTap:nil];
////            
////            if (iSOvelayViewShow == YES)
////            {
////                //
////                _upperView.frame=CGRectMake(0, 0,_overlayVC.frame.size.width,40);
////                [_upperView layoutIfNeeded];
////                _lowerView.frame=CGRectMake(0, _overlayVC.frame.size.height-40,_overlayVC.frame.size.width,40);
////                [_lowerView layoutIfNeeded];
////            }else
////            {
////                _upperView.frame=CGRectMake(0, -40,_overlayVC.frame.size.width ,40);
////                [_upperView layoutIfNeeded];
////                _lowerView.frame=CGRectMake(0, _overlayVC.frame.size.height+40,_overlayVC.frame.size.width ,40);
////                [_lowerView layoutIfNeeded];
////            }
////            break;
//            
//        }
//        case UIDeviceOrientationLandscapeRight:
//        {
//            _overlayVC.frame=CGRectMake(0, 0,[APPDELEGATE window].frame.size.height ,[APPDELEGATE window].frame.size.width);
//
////            NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
////            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
////            NSLog(@"UIDeviceOrientationLandscapeRight");
////            
////            //            [self handleDismissDoubleTap:nil];
////            if (iSOvelayViewShow == YES)
////            {
////                //
////                _upperView.frame=CGRectMake(0, 0,_overlayVC.frame.size.width,40);
////                [_upperView layoutIfNeeded];
////                _lowerView.frame=CGRectMake(0, _overlayVC.frame.size.height-40,_overlayVC.frame.size.width,40);
////                [_lowerView layoutIfNeeded];
////            }else
////            {
////                _upperView.frame=CGRectMake(0, -40,_overlayVC.frame.size.height ,_upperView.frame.size.width);
////                [_upperView layoutIfNeeded];
////                _lowerView.frame=CGRectMake(0, _overlayVC.frame.size.height+40,_overlayVC.frame.size.width ,40);
////                [_lowerView layoutIfNeeded];
////            }
//            break;
//        }
//        default:
//            break;
//    };
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)removeViewFromParent
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
-(void)updateData:(NSMutableDictionary*)dictData
{
   
    
        //NSLog(@"%@",dictData);
        //NSLog(@"update called data for it :");
        //NSLog(@"updateData");
        dictOfPost = dictData;
        //    NSString *strLocation =[NSString stringWithFormat:@"%@,%@",[dictOfPost objectForKey:@"city"],[dictOfPost objectForKey:@"country"]];
        NSString *strLocation;
        if ([dictData objectForKey:@"city"])
        {
            strLocation =[NSString stringWithFormat:@"%@, %@",[dictOfPost objectForKey:@"place"],[dictOfPost objectForKey:@"city"]];
        }else
        {
            strLocation =[NSString stringWithFormat:@"%@",[dictOfPost objectForKey:@"place"]];
        }
        
        
        NSString *strDescription =[NSString stringWithFormat:@"%@",[dictOfPost  objectForKey:@"post_description"]];
        NSLog(@"Description : %@",strDescription);
    
        NSString *strLikeDislikeStatus = [NSString stringWithFormat:@"%@",[dictOfPost  objectForKey:@"likebyme"]];;
        _lbllocation.text = strLocation;
        _lblDescription.text = strDescription;
        
        if([strLikeDislikeStatus isEqualToString:@"0"])
        {
            _imgLikeDislikeView.image = [UIImage imageNamed:@"icn_tumbup"];
            //                [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup"] forState:UIControlStateNormal];
        }
        else
        {
            _imgLikeDislikeView.image = [UIImage imageNamed:@"icn_tumbup_sel"];
            
            //                [_btnLikeDislike setImage:[UIImage imageNamed:@"icn_tumbup_sel"] forState:UIControlStateNormal];
        }

    
}



- (IBAction)actionGoLocation:(id)sender
{
    if ([_delegate respondsToSelector:@selector(goLocation)])
    {
        [self removeViewFromParent];
        [_delegate goLocation];
    }
}

- (IBAction)actionLike:(id)sender
{
 
    if ([_delegate respondsToSelector:@selector(actionLike)])
    {
//        NSString *strLikeDislikeStatus = [NSString stringWithFormat:@"%@",[dictOfPost  objectForKey:@"likebyme"]];;
//        if([strLikeDislikeStatus isEqualToString:@"0"])
//        {
//            self.imgLikeDislikeView.image = [UIImage imageNamed:@"icn_tumbup_sel"];
//        }
//        else
//        {
//            self.imgLikeDislikeView.image = [UIImage imageNamed:@"icn_tumbup"];
//
//
//        }

        [_delegate actionLike];
    }
}

- (IBAction)actionDonePlayer:(id)sender
{
    if ([_delegate respondsToSelector:@selector(donePlayer)])
    {
        [self removeViewFromParent];
        [_delegate donePlayer];
    }
}
@end
