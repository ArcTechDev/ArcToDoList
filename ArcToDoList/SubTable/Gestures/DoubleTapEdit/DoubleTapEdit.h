//
//  DoubleTapEdit.h
//  SubTableView
//
//  Created by User on 28/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"
#import "DTECellHolder.h"

@protocol DoubleTapEditDelegate <NSObject>

@optional
- (BOOL)canStartEditAtIndex:(NSInteger)index;
- (NSString *)nameForItemAtIndex:(NSInteger)index;
- (void)onDoubleTapEditCompleteAtIndex:(NSInteger)index withItemName:(NSString *)name;

@end

@interface DoubleTapEdit : GestureComponent<DTECellHolderDelegate>

@end
