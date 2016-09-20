//
//  TermsServiceVC.m
//  ShootIP
//
//  Created by Dhaval Shah on 3/16/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import "TermsServiceVC.h"

@interface TermsServiceVC ()

@end

@implementation TermsServiceVC

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TermsAndService" ofType:@"html"]isDirectory:NO]]];
    webView.delegate=self;
}

#pragma mark - Action -

- (IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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


@end
