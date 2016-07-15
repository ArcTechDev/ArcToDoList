//
//  LongPressMove.h
//  SubTableViewDemo
//
//  Created by User on 29/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"

@protocol LongPressMoveDelegate <NSObject>

@optional
- (BOOL)canMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/**
 * Call when touch release, fromIndex is the index that first touch, toIndex is index
 * that touch release
 */
- (void)didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface LongPressMove : GestureComponent

@end
