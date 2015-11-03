//
//  DoubleTapEdit.m
//  SubTableView
//
//  Created by User on 28/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "DoubleTapEdit.h"
#import "ParentTableViewCell.h"

@implementation DoubleTapEdit{
    
    DTECellHolder *_cellHolder;
    NSInteger _tappedCellIndex;
    UIView *_maskView;
    BOOL _onEdit;
}

#pragma mark - override
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        _cellHolder = [DTECellHolder CellHolderWithNibName:@"DTECellHolder"];
        _cellHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _maskView = [[UIView alloc] initWithFrame:CGRectNull];
        _maskView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMaskView)];
        [_maskView addGestureRecognizer:gesture];
        _cellHolder.delegate = self;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        [recognizer setNumberOfTapsRequired:2];
        [recognizer setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}

- (void)deviceOrientationDidChange{
    
    if(_onEdit){
        
        _maskView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _tableView.bounds.size.height);
        
    }
}

#pragma mark - internal
- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded && [self canBeganGesture:recognizer]){
        
        if(_onEdit)
            return;
        
        if([self.delegate respondsToSelector:@selector(canStartEditAtIndex:)]){
            
            if(![self.delegate canStartEditAtIndex:_tappedCellIndex]){
                
                return;
            }
        }
        
        NSString *nameForItem = @"";
        
        if([self.delegate respondsToSelector:@selector(nameForItemAtIndex:)]){
            
            nameForItem =  [self.delegate nameForItemAtIndex:_tappedCellIndex];
        }
        
        if(_cellHolder.superview == nil){
            
            _cellHolder.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _cellHolder.bounds.size.height);
            [_tableView.superview addSubview:_cellHolder];
            
            _maskView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _tableView.bounds.size.height);
            [_tableView.superview addSubview:_maskView];
            
            [_tableView.superview bringSubviewToFront:_cellHolder];
        }
        
        [_tableView bringSubviewToFront:_cellHolder];
        
        _onEdit = YES;
        _tableView.interactionEnable = NO;
        
        [_cellHolder changeItemText:nameForItem];
        [_cellHolder startEdit];
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

#pragma mark - internal
- (void)onTapMaskView{
    
    [self endEditWithText:@""];
}

#pragma mark - DTECellHolder delegate
-(void)endEditWithText:(NSString *)text{
    
    _onEdit = NO;
    
    _tableView.interactionEnable = YES;
    
    [_maskView removeFromSuperview];
    [_cellHolder removeFromSuperview];
    
    if([text length] <= 0)
        return;
    
    if([self.delegate respondsToSelector:@selector(onDoubleTapEditCompleteAtIndex:withItemName:)]){
        
        [self.delegate onDoubleTapEditCompleteAtIndex:_tappedCellIndex withItemName:text];
    }
}

@end
