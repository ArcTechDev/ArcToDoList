//
//  Helper.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface Helper : ParentTableViewCell

+ (UIColor *)transitColorForItemAtIndex:(NSInteger)index totalItemCount:(NSInteger)itemCount startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
+ (UIView *)blurViewFromView:(UIView *)fromView withBlurRadius:(CGFloat)radius;

@end
