//
//  NSString+StringHelper.h
//  Dreammary
//
//  Created by Virendra Jethwa on 1/3/14.
//  Copyright (c) 2014 Virendra Jethwa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (StringHelper)

- (CGFloat)getHeightOfTextForFontSize:(CGFloat)size;
- (CGFloat)getHeightOfTextForFontSize:(CGFloat)size withLabelWidth:(CGFloat)width;

@end
