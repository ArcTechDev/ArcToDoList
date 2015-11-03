//
//  Helper.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (UIColor *)transitColorForItemAtIndex:(NSInteger)index totalItemCount:(NSInteger)itemCount startColor:(UIColor *)startColor endColor:(UIColor *)endColor{
    
    float r,g,b,a;
    const CGFloat *startColorComponent = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endColorComponent = CGColorGetComponents(endColor.CGColor);
    r = startColorComponent[0] + ((endColorComponent[0] - startColorComponent[0])/itemCount) * index;
    g = startColorComponent[1] + ((endColorComponent[1] - startColorComponent[1])/itemCount) * index;
    b = startColorComponent[2] + ((endColorComponent[2] - startColorComponent[2])/itemCount) * index;
    a = startColorComponent[3];
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    return color;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
