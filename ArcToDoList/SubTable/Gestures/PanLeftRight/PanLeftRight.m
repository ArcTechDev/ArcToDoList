//
//  PanToDeleteComplete.m
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "PanLeftRight.h"
#import "ParentTableViewCell.h"


@implementation PanLeftRight{
 
    //cell we are going to work on
    __weak ParentTableViewCell *_tempCell;
    
    NSInteger _cellIndex;
    
    //cell original center
    CGPoint _cellOriginalCenter;
    
    //true if pan left happen
    BOOL _leftOnDragRelease;
    
    //true if pan right happen
    BOOL _rightOnDragRelease;
}

@synthesize panLeftSnapBackAnim = _panLeftSnapBackAnim;
@synthesize panRightSnapBackAnim = _panRightSnapBackAnim;
@synthesize allowedDirection = _allowedDirection;

#pragma mark - ovrride
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        _panLeftSnapBackAnim = NO;
        _panRightSnapBackAnim = NO;
        _allowedDirection = PanBothLeftRight;
        
        UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:recognizer WithDelegate:self];
        
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    //we only want gesture to happen when user move more on horizontal than vertical
    CGPoint translate = [gestureRecognizer translationInView:_tableView];
    
    //if finger move horizontal
    if(fabs(translate.x) > fabs(translate.y)){
        
        CGPoint location = [gestureRecognizer locationInView:_tableView];
        
        //find parent cell
        _tempCell = [_tableView findCellByTouchPoint:location];
        
        //parent cell index
        NSInteger cellIndex = -1;
        
        //if parent cell not found gesture do not began
        if(_tempCell == nil){
            
            return NO;
        }
        else{
            
            //find parent cell index in tableView
            cellIndex = [_tableView indexPathForCell:_tempCell].row;
        }
        
        if(translate.x < 0){
            
            if([self.delegate respondsToSelector:@selector(canPanLeftAtCellIndex:)]){
                
                if(![self.delegate canPanLeftAtCellIndex:cellIndex]){
                    
                    return NO;
                }
            }
        }
        else if(translate.x > 0){
            
            if([self.delegate respondsToSelector:@selector(canPanRightAtCellIndex:)]){
                
                if(![self.delegate canPanRightAtCellIndex:cellIndex]){
                    
                    return NO;
                }
            }
        }
        
        //if tableView is in edit mode
        if(_tableView.isOnEdit){
            
            //expand parent cell
            [_tableView expandForParentCellAtIndex:cellIndex];
            
            //this gesture do not began
            return NO;
        }
        
        //began gesture
        return YES;
    }
    else{
        
        _tempCell = nil;
        
        return NO;
    }
}

#pragma mark - internal
- (void)onPan:(UIPanGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan && _tempCell != nil){
        
        //get index of cell
        _cellIndex = _tempCell.parentIndex;

        //store cell's original center
        _cellOriginalCenter = _tempCell.center;
    }
    
    if(recognizer.state == UIGestureRecognizerStateChanged && _tempCell != nil){
        
        //get translation in cell
        CGPoint translate = [recognizer translationInView:_tempCell];
        
        BOOL allowGesture = NO;
        
        //check direction
        if(_allowedDirection == PanLeft){
            
            if(translate.x > 0.0f){
                
                allowGesture = NO;
            }
            else{
                
                allowGesture = YES;
            }
        }
        else if(_allowedDirection == PanRight){
            
            if(translate.x < 0.0f){
                
                allowGesture = NO;
            }
            else{
                
                allowGesture = YES;
            }
        }
        else{
            
            allowGesture = YES;
        }
        
        if(!allowGesture){
            
            _tempCell.center = _cellOriginalCenter;
            
            return;
        }
        
        //move cell
        _tempCell.center = CGPointMake(_cellOriginalCenter.x + translate.x, _cellOriginalCenter.y);
        
        //determine if drag distance is long enough to delete
        _leftOnDragRelease = _tempCell.frame.origin.x < -_tempCell.bounds.size.width/2;
        
        //determine if drag distance is long enough to complete
        _rightOnDragRelease = _tempCell.frame.origin.x > _tempCell.bounds.size.width/2;
        
        //panning left
        if(_tempCell.frame.origin.x < 0){
            
            if([self.delegate respondsToSelector:@selector(onPanningLeftWithDelta:AtCellIndex:)]){
                
                //find out delta
                CGFloat delta = MIN(1.0f, fabs(_tempCell.frame.origin.x / (_tempCell.bounds.size.width / 2.0f)));
                
                //tell delegate panning left
                [self.delegate onPanningLeftWithDelta:delta AtCellIndex:_cellIndex];
                                                          
            }
        }
        else if(_tempCell.frame.origin.x > 0){//panning right
            
            if([self.delegate respondsToSelector:@selector(onPanningRightWithDelta:AtCellIndex:)]){
                
                //find out delta
                CGFloat delta = MIN(1.0f, fabs(_tempCell.frame.origin.x / (_tempCell.bounds.size.width / 2.0f)));
                
                //tell delegate panning right
                [self.delegate onPanningRightWithDelta:delta AtCellIndex:_cellIndex];
                
            }
        }
        
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        
        CGRect originalFrame = CGRectMake(0, _tempCell.frame.origin.y, _tempCell.frame.size.width, _tempCell.frame.size.height);
        
        if(_leftOnDragRelease){
            
            if(_panLeftSnapBackAnim){
                
                //retrun to original frame
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     _tempCell.frame = originalFrame;
                                 }completion:^(BOOL finished){
                                     
                                     if(finished){
                                         
                                         //tell delegate pan left
                                         if([self.delegate respondsToSelector:@selector(onPanLeftAtCellIndex:)]){
                                             
                                             [self.delegate onPanLeftAtCellIndex:_cellIndex];
                                         }
                                     }
                                     
                                 }
                 ];
            }
            
            
            
        }
        else if(_rightOnDragRelease){
            
            if(_panRightSnapBackAnim){
                
                //retrun to original frame
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     _tempCell.frame = originalFrame;
                                 }completion:^(BOOL finished){
                                     
                                     if(finished){
                                         
                                         //tell delegate pan right
                                         if([self.delegate respondsToSelector:@selector(onPanRightAtCellIndex:)]){
                                             
                                             [self.delegate onPanRightAtCellIndex:_cellIndex];
                                         }
                                     }
                                     
                                 }
                 ];
            }
            
            
        }
        else
        {
            // if the cell is not complete pan right or left, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 _tempCell.frame = originalFrame;
                             }
             ];
        }
        
        _tempCell = nil;
        _cellOriginalCenter = CGPointZero;
        _leftOnDragRelease = NO;
        _rightOnDragRelease = NO;
    }
}

@end
