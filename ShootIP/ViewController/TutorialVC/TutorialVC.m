//
//  TutorialVC.m
//  Mini Me Fantasy
//
//  Created by inheritx on 21/07/15.
//  Copyright (c) 2015 inheritx. All rights reserved.
//

#import "TutorialVC.h"
#import "AppDelegate.h"

@interface TutorialVC ()

@end

@implementation TutorialVC

#pragma mark - View Life Cycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    scrollView.contentSize = CGSizeMake(3*self.view.frame.size.width, scrollView.contentSize.height);
    pageController.currentPage = 0;
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageController.pageIndicatorTintColor=[UIColor blackColor];
    pageController.numberOfPages = scrollView.contentSize.width/self.view.frame.size.width;
    [pageController updateCurrentPageDisplay];
    
    for (int i=0; i<pageController.numberOfPages; i++)
    {
        CGRect rect = CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorial_page_%d",i+1]];
        [scrollView addSubview:imgView];
    }
    scrollView.bounces = YES;
}

#pragma mark - Custom Method -

- (IBAction)changePage:(id)sender
{
    pageController.currentPageIndicatorTintColor = [UIColor blackColor];
    
    CGFloat x = pageController.currentPage * scrollView.frame.size.width;
    [scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - UIScrollView Delegate Method -

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1;
    int pagefor = scrollView.contentOffset.x;
    
    if (pagefor > 2*scrollView.frame.size.width)

    {
        [APPDELEGATE PushToNextView:YES];
    }
    pageController.currentPage = page;
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
