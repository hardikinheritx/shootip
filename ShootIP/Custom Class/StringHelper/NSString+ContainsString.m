//
//  NSString+ContainsString.m
//  Yomko_Xcode5
//
//  Created by milap kundalia on 1/27/15.
//  Copyright (c) 2015 inheritx. All rights reserved.
//

#import "NSString+ContainsString.h"

@implementation NSString (ContainsString)

- (BOOL)myContainsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.location != NSNotFound;
}
@end
