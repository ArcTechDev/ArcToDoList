//
//  Tap.h
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"

@protocol SingleTapDelegate <NSObject>

@optional
/**
 * Call when tap on a cell with cell index
 */
- (void)onSingleTapAtCellIndex:(NSInteger)index;

@end

@interface SingleTap : GestureComponent


@end
