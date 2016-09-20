//
//  NSString+Base64Check.m
//  Dreammary
//
//  Created by milap kundalia on 9/15/14.
//  Copyright (c) 2014 Milap Kundalia. All rights reserved.
//
//^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$
#import "NSString+Base64Check.h"

@implementation NSString (Base64Check)
- (BOOL)isBase64Data {
    if ([self length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet
                                            characterSetWithCharactersInString:
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="]
                                           invertedSet] ;
        }
        return [self rangeOfCharacterFromSet:invertedBase64CharacterSet
                                     options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}
@end
