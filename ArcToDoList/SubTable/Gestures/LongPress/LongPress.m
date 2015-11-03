//
//  LongPress.m
//  NPTableView
//
//  Created by User on 21/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "LongPress.h"
#import "ParentTableViewCell.h"

@implementation LongPress{
    
    NSInteger _pressedCellIndex;
}

#pragma mark - override
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    //find parent cell
    ParentTableViewCell *cell = [_tableView findCellByTouchPoint:[gestureRecognizer locationOfTouch:0 inView:_tableView]];
    
    //parent cell index
    NSInteger cellIndex = -1;
    
    //if parent cell not found gesture do not began
    if(cell == nil){
        
        return NO;
    }
    else{
        
        //find parent cell index in tableView
        cellIndex = [_tableView indexPathForCell:cell].row;
        
        _pressedCellIndex = cellIndex;
    }
    
    //if tableView is in edit mode
    if(_tableView.isOnEdit){
        
        //expand parent cell
        [_tableView expandForParentCellAtIndex:cellIndex];
        
        //this gesture do not began
        return NO;
    }
    
    return YES;
}

- (void)onLongPress:(UILongPressGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        if([self.delegate respondsToSelector:@selector(onLongPressAtCellIndex:)]){
            
            [self.delegate onLongPressAtCellIndex:_pressedCellIndex];
        }
    }
}

@end
