//
//  PanToDeleteComplete.h
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"

@protocol PanLeftRightDelegate <NSObject>

@optional
/**
 * Call when pan left happen and touch release
 */
- (void)onPanLeftAtCellIndex:(NSInteger)index;

/**
 * Call when pan right happen and touch release
 */
- (void)onPanRightAtCellIndex:(NSInteger)index;

/**
 * Call when panning left with delta value
 * Delta is distance to complete pan left and is between 0~1
 */
- (void)onPanningLeftWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index;

/**
 * Call when panning right with delta value
 * Delta is distance to complete pan right and is between 0~1
 */
- (void)onPanningRightWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index;

/**
 * Return YES to allow pan left otherwise NO
 */
- (BOOL)canPanLeftAtCellIndex:(NSInteger)index;

/**
 * Return YES to allow pan right otherwise NO
 */
- (BOOL)canPanRightAtCellIndex:(NSInteger)index;


@end

enum PanLeftRightDirection{
    
    PanLeft,
    PanRight,
    PanBothLeftRight
};

@interface PanLeftRight : GestureComponent

/**
 * Tell component to perform snap back anim when
 * pan left happen.
 * Default NO
 */
@property (assign, nonatomic) BOOL panLeftSnapBackAnim;

/**
 * Tell component to perform snap back anim when
 * pan right happen.
 * Default NO
 */
@property (assign, nonatomic) BOOL panRightSnapBackAnim;

/**
 * Which directions are allowed
 * PanLeft, PanRight, PanBothLeftRight
 */
@property (assign, nonatomic) enum PanLeftRightDirection allowedDirection;

@end
