//
//  LongPress.h
//  NPTableView
//
//  Created by User on 21/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"

@protocol LongPressDelegate <NSObject>

@optional
- (void)onLongPressAtCellIndex:(NSInteger)index;

@end

@interface LongPress : GestureComponent

@end
