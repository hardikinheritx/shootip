//
//  CustomAnnotationView.h
//  
//
//  Created by Prashant Sanghavi on 09/12/15.
//  Copyright © 2015 inheritx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetUiImageViewProperty;

@interface CustomAnnotationView : UIView


@property (strong, nonatomic) IBOutlet UIView *lblAddressView;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) NSString *strEventID;

@end
