//
//  Tap.m
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "SingleTap.h"
#import "ParentTableViewCell.h"

@implementation SingleTap{
    
    NSInteger _tappedCellIndex;
    
    BOOL _onHold;
}

#pragma mark - override
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [recognizer setNumberOfTapsRequired:1];
        [recognizer setNumberOfTouchesRequired:1];
        [recognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}


#pragma mark - internal
- (void)onTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded && [self canBeganGesture:recognizer]){
        
        if([self.delegate respondsToSelector:@selector(onSingleTapAtCellIndex:)]){
            
            [self.delegate onSingleTapAtCellIndex:_tappedCellIndex];
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
        
        [_tableView expandForParentCellAtIndex:cellIndex];
        
        //this gesture do not began
        return NO;
    }
    
    //ask tableView if cetain parent cell index can expand subcell
    if([_tableView canExpandParentCellAtIndex:cellIndex]){
        
        //expand parent cell
        [_tableView expandForParentCellAtIndex:cellIndex];
        
        //do not began this gesture if parent cell can be expanded
        return NO;
    }
    
    //single tap only happen when tableView is not in edit mode, tap on parent cell and parent cell can not be expanded
    return YES;
}


@end
