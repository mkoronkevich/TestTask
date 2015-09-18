//
//  UITextField+FontSize.m
//  Generator
//
//  Created by Milana Koronkevich on 9/17/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "UITextField+FontSize.h"
#import "DeviceSize.h"

#define ACCEPTABLE_CHARECTERS @"0123456789"

@implementation UITextField (FontSize)

- (void)adjustFont {
    UIFont *currentFont = self.font;
    CGFloat sizeScale = 1.0;
    
    if( IS_IPHONE_5 ) {
        sizeScale = 1.1;
    } else if( IS_IPHONE_6 ) {
        sizeScale = 1.3;
    } else if( IS_IPHONE_6P ) {
        sizeScale = 1.5;
    } else if( IS_IPAD ) {
        sizeScale = 2.0;
    }
    
    self.font = [currentFont fontWithSize:currentFont.pointSize * sizeScale];
}

- (BOOL)decimalCharacters:(NSString *)string {
    NSCharacterSet *charecterSet = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    NSString *filteredString = [[string componentsSeparatedByCharactersInSet:charecterSet] componentsJoinedByString:@""];
    
    return [string isEqualToString:filteredString];
}

@end