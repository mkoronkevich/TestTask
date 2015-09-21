//
//  UITextView+FontSize.m
//  Generator
//
//  Created by Milana Koronkevich on 9/21/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "UITextView+FontSize.h"
#import "DeviceSize.h"

@implementation UITextView (FontSize)

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

@end
