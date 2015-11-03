//
//  LongPressMove.m
//  SubTableViewDemo
//
//  Created by User on 29/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "LongPressMove.h"
#import "ParentTableViewCell.h"

@implementation LongPressMove{
    
    UIView *_snapshot;
    NSInteger _sourceIndex;
    BOOL _canMove;
}

- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        _canMove = NO;

        
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
    
    CGPoint location = [recognizer locationInView:_tableView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            
            ParentTableViewCell *cell = [_tableView findCellByTouchPoint:location];
            _sourceIndex = cell.parentIndex;
            
            
            _snapshot = [self customSnapshoFromView:cell];
            
            __block CGPoint center = cell.center;
            _snapshot.center = center;
            _snapshot.alpha = 0.0f;
            [_tableView addSubview:_snapshot];
            
            cell.alpha = 0.0f;
            cell.hidden = YES;
            
            [UIView animateWithDuration:0.25f animations:^{
                
                center.y = location.y;
                _snapshot.center = center;
                _snapshot.transform = CGAffineTransformMakeScale(1.55f, 1.55f);
                _snapshot.alpha = 0.98f;
                
            } completion:^(BOOL finished){
                
                _canMove = YES;
            }];
            
            break;
        }
        
        case UIGestureRecognizerStateChanged:{
            
            if(!_canMove){
                
                break;
            }
            
            CGPoint center = _snapshot.center;
            center.y = location.y;
            _snapshot.center = center;
            
            ParentTableViewCell *cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForRowAtPoint:location]];
            NSInteger destIndex = -1;
            
            if(cell != nil){
                
                destIndex = cell.parentIndex;
            }
            
            if(_sourceIndex != cell.parentIndex && destIndex >= 0){
                
                if([self.delegate respondsToSelector:@selector(canMoveItemFromIndex:toIndex:)]){
                    
                    if([self.delegate canMoveItemFromIndex:_sourceIndex toIndex:cell.parentIndex]){
                        
                        if([self.delegate respondsToSelector:@selector(willMoveItemFromIndex:toIndex:)]){
                            
                            
                            [self.delegate willMoveItemFromIndex:_sourceIndex toIndex:destIndex];
                            
                            [_tableView moveRowAtIndex:_sourceIndex toIndex:destIndex];
                            
                            _sourceIndex = destIndex;
                            
                            
                        }
                    }
                }
                
            }
            
            [self adjustView:recognizer];
            
            break;
        }
            
        default:{
            
            
            ParentTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sourceIndex inSection:0]];
            cell.hidden = NO;
            cell.alpha = 0.0f;
            
            
            [UIView animateWithDuration:0.25f animations:^{
                
                _snapshot.center = cell.center;
                _snapshot.transform = CGAffineTransformIdentity;
                _snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                _canMove = NO;
                
                cell.hidden = NO;
                cell.alpha = 1.0f;
                
                [_snapshot removeFromSuperview];
                _snapshot = nil;
                
                [_tableView reloadData];
            }];
            
            break;
        }
    }
    

}

- (void)adjustView:(UILongPressGestureRecognizer *)recognizer{
    
    if(_snapshot){
        
        CGPoint location = [recognizer locationInView:_tableView];
        NSInteger rows = [_tableView numberOfRowsInSection:0];
        
        CGFloat snapshotBottomEdge = location.y + _snapshot.bounds.size.height *0.5f;
        CGFloat visibleBottomEdge = _tableView.contentOffset.y + _tableView.bounds.size.height;
        
        if(snapshotBottomEdge > visibleBottomEdge){
            
            if((_sourceIndex+1) <= (rows-1)){
                
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_sourceIndex+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        
        CGFloat snapshotTopEdge = location.y - _snapshot.bounds.size.height *0.5f;
        CGFloat visibleTopEdge = _tableView.contentOffset.y;
        
        if(snapshotTopEdge < visibleTopEdge){
            
            if((_sourceIndex-1) >= 0){
                
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_sourceIndex-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
        
    }
}


- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
