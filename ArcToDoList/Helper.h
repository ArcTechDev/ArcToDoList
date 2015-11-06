//
//  Helper.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface Helper : ParentTableViewCell

/** 
 * Get color at index, start color to end color is linear
 */
+ (UIColor *)transitColorForItemAtIndex:(NSInteger)index totalItemCount:(NSInteger)itemCount startColor:(UIColor *)startColor endColor:(UIColor *)endColor;

/**
 * Return a blur view
 */
+ (UIView *)blurViewFromView:(UIView *)fromView withBlurRadius:(CGFloat)radius;

@end
