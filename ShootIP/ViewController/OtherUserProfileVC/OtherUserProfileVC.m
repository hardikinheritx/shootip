//
//  OtherUserProfileVC.m
//  ShootIP
//
//  Created by milap kundalia on 1/27/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "OtherUserProfileVC.h"

@interface OtherUserProfileVC ()

@end

@implementation OtherUserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    super.strOtherUserID=_strUserID;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    
   [super viewWillAppear:animated];

    [APPDELEGATE myTab].tabBar.hidden=YES;
    [APPDELEGATE imagefooter].hidden=YES;

    [self.view layoutIfNeeded ];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"OtherUser Profile Screen"];
    [APPDELEGATE setDropOffScreen:@"OtherUser Profile Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)GetUserDetails{
//    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
//    [dict setObject:[USERDEFAULTS objectForKey:KEYUSERID] forKey:KEYUSERID];
//    [dict setObject:[USERDEFAULTS objectForKey:KEYAUTHTOKEN] forKey:KEYAUTHTOKEN];
//    [dict setObject:super.strOtherUserID forKey:@"other_user_id"];
//
//    [SVProgressHUD show];
//    [[ServerConnection sharedConnectionWithDelegate:self] requestWithURL:APIUSERDETAILS method:@"POST" data:dict withImages:nil withVideo:nil];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"editPostSegue"])
//    {
//        NewPostVC *newPostVC = segue.destinationViewController;
//        newPostVC.performEdit=@"Edit";
//        newPostVC.dictPostDetails=(NSDictionary *)sender;
//    }
//    else if ([segue.identifier isEqualToString:@"CommentSegue"])
//    {
//        CommentVC *objComment = segue.destinationViewController;
//        objComment.isForPost=YES;
//        objComment.strPostId=(NSString *)sender;
//    }
//    else if ([segue.identifier isEqualToString:@"mapSegue"])
//    {
//        MapVC *objMap = segue.destinationViewController;
//        objMap.dictMap=(NSDictionary *)sender;
//    }
//    else if ([segue.identifier isEqualToString:@"placeSegue"])
//    {
//        PlaceVC *objPlaceVC = segue.destinationViewController;
//        objPlaceVC.dictPlaceDetail=(NSDictionary *)sender;
//    }
//    else if ([segue.identifier isEqualToString:@"LookoutsSegue"])
//    {
//        LookoutsVC *objLookOut = segue.destinationViewController;
//        objLookOut.strOtherUserID=_strOtherUserID;
//    }
//}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
