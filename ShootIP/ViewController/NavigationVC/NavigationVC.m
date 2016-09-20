//
//  NavigationVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "NavigationVC.h"
#import "CaptureVideoVC.h"

@interface NavigationVC ()

@end

@implementation NavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
//    if ([self.topViewController isMemberOfClass:[CaptureVideoVC class]]){
//        return UIInterfaceOrientationMaskAll;
//    }
    if ([self.topViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabCon=(UITabBarController*)self.topViewController;
//        NSArray *array=[tabCon viewControllers];
//        UINavigationController *nav=[array objectAtIndex:2];
        UINavigationController *nav = (UINavigationController*)tabCon.selectedViewController;

        if([nav.visibleViewController isKindOfClass:[CaptureVideoVC class]])
        {
            return UIInterfaceOrientationMaskAll;
        }
         return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
            return UIInterfaceOrientationMaskPortrait;
    }
}
-(BOOL)shouldAutorotate{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
