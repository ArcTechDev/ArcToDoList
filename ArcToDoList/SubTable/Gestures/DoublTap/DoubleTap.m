//
//  DoubleTap.m
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "DoubleTap.h"
#import "ParentTableViewCell.h"

@implementation DoubleTap{
    
    NSInteger _tappedCellIndex;
}

#pragma mark - override
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        [recognizer setNumberOfTapsRequired:2];
        [recognizer setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}

#pragma mark - internal
- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded && [self canBeganGesture:recognizer]){
        
        if([self.delegate respondsToSelector:@selector(onDoubleTapAtCellIndex:)]){
            
            [self.delegate onDoubleTapAtCellIndex:_tappedCellIndex];
        }
    }
}

- (BOOL)canBeganGesture:(UITapGestureRecognizer *)gestureRecognizer{
 
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
        
        _tappedCellIndex = cellIndex;
    }
    
    //if tableView is in edit mode
    if(_tableView.isOnEdit){
        
        //expand parent cell
        [_tableView expandForParentCellAtIndex:cellIndex];
        
        //this gesture do not began
        return NO;
    }
    
    //single tap only happen when tableView is not in edit mode, tap on parent cell and parent cell can not be expanded
    return YES;
}

@end
