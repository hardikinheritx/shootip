//
//  NSString+StringHelper.m
//  Dreammary
//
//  Created by Virendra Jethwa on 1/3/14.
//  Copyright (c) 2014 Virendra Jethwa. All rights reserved.
//

#import "NSString+StringHelper.h"

@implementation NSString (StringHelper)
#define IOS_NEWER_OR_EQUAL_TO_7 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 7.0 )

- (CGFloat)getHeightOfTextForFontSize:(CGFloat)size {
    //Calculate the expected size based on the font and linebreak mode of the label
    CGFloat maxWidth;
//    if (IS_IPAD)
//    {
//        maxWidth = 694;
//    }else{
//         maxWidth = 292;
//    }
    
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
    
    UIFont *myFont=[UIFont fontWithName:@"OpenSans" size:size];
    CGSize expectedLabelSize;
    if(IOS_NEWER_OR_EQUAL_TO_7){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              myFont, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [self boundingRectWithSize:maximumLabelSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
        expectedLabelSize =  frame.size;
    }else{
        
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        expectedLabelSize = [self sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
#pragma GCC diagnostic pop
    }
    
    return expectedLabelSize.height;
}

- (CGFloat)getHeightOfTextForFontSize:(CGFloat)size withLabelWidth:(CGFloat)width {
    //Calculate the expected size based on the font and linebreak mode of the label
    //    CGFloat maxWidth = 292;
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(width,maxHeight);
    
    UIFont *myFont=[UIFont fontWithName:@"OpenSans" size:size];
    CGSize expectedLabelSize;
    if(IOS_NEWER_OR_EQUAL_TO_7){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              myFont, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [self boundingRectWithSize:maximumLabelSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
        expectedLabelSize =  frame.size;
    }else{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        expectedLabelSize = [self sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];

#pragma GCC diagnostic pop
    }

    return expectedLabelSize.height;
}

@end
