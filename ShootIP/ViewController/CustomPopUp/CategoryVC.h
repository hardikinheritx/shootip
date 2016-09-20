//
//  CategoryVC.h
//  ShootIP
//
//  Created by Dhaval Shah on 2/10/16.
//  Copyright © 2016 Dhaval Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryTableViewCell.h"
#import "CategoryVC.h"

@protocol CategoryVCDelegate<NSObject>

- (void)getDataFromCategory:(NSDictionary*)getCategoryDict;
- (void)downloadFailedWithCategory;

@end

@interface CategoryVC : UIViewController
{
    IBOutlet UITableView *tblCategoryListing;
    __weak IBOutlet UIView *viewPopUp;
}

- (IBAction)actionCloseCategoryListing:(id)sender;
@property (strong, nonatomic) id<CategoryVCDelegate>delegate;

@end
