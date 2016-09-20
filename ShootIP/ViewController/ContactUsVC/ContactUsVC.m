//
//  ContactUsVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 3/16/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "ContactUsVC.h"

@interface ContactUsVC ()

@end

@implementation ContactUsVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
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

- (IBAction)actionMailOpen:(id)sender
{
    NSString *subject = [NSString stringWithFormat:@""];
    
    /* define email address */
    NSString *mail = [NSString stringWithFormat:@"support@shootip.com"];
    
    /* define allowed character set */
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    
    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEncodingWithAllowedCharacters:set],
                                                [subject stringByAddingPercentEncodingWithAllowedCharacters:set]]];
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
