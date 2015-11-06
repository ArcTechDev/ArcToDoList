//
//  Helper.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "Helper.h"
#import "GPUImage.h"

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

+ (UIView *)blurViewFromView:(UIView *)fromView withBlurRadius:(CGFloat)radius{
    
    // Make an image from the input view.
    //UIGraphicsBeginImageContextWithOptions(fromView.bounds.size, NO, 1);
    UIGraphicsBeginImageContext(fromView.bounds.size);
    [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = radius;
    UIImage *outputImage = [filter imageByFilteringImage:image];
    
    UIView *blurView = [[UIImageView alloc] initWithImage:outputImage];
    
    return blurView;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
