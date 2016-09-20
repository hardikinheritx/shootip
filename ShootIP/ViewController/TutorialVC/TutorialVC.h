//
//  TutorialVC.h
//  Mini Me Fantasy
//
//  Created by inheritx on 21/07/15.
//  Copyright (c) 2015 inheritx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialVC : UIViewController
{
    
    IBOutlet UIPageControl *pageController;
    IBOutlet UIScrollView *scrollView;
}
- (IBAction)changePage:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblText;
@property (strong, nonatomic) IBOutlet UIImageView *imgTutorialImage;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
