//
//  PullDownAddNew.m
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "PullDownAddNew.h"
#import "ParentTableViewCell.h"


@implementation PullDownAddNew{
    
    PDANCellHolder *_cellHolder;
    UIView *_maskView;
    BOOL _pullDownInProgress;
    BOOL _onEdit;
    CGFloat defaultRowHeight;
}

#pragma mark - override
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        defaultRowHeight = -1;
        
        _cellHolder = [PDANCellHolder CellHolderWithNibName:@"PDANCellHolder"];
        _cellHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _maskView = [[UIView alloc] initWithFrame:CGRectNull];
        _maskView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMaskView)];
        [_maskView addGestureRecognizer:gesture];
        _cellHolder.delegate = self;
    }
    
    return self;
}

- (void)deviceOrientationDidChange{
    
    if(_onEdit){
        
        _maskView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _tableView.bounds.size.height);
        
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(_onEdit)
        return;
    
    
    
    _pullDownInProgress = scrollView.contentOffset.y < 0.0f;
    
    ParentTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    if(cell == nil){
        
        _pullDownInProgress = NO;
    }
    
    if(_pullDownInProgress && _tableView.isOnEdit){
        
        [_tableView collapseAllRows];
    }
    
    if(_pullDownInProgress && defaultRowHeight < 0){
        
        defaultRowHeight = cell.bounds.size.height;
    
    }
    
    if(_pullDownInProgress && _cellHolder.superview == nil){
        
        _cellHolder.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _cellHolder.bounds.size.height);
        [_tableView.superview addSubview:_cellHolder];
    }
    
    if(_pullDownInProgress && scrollView.contentOffset.y <= 0.0f){
        
        CGFloat cellHolderY = MIN(0.0f, (-scrollView.contentOffset.y) - defaultRowHeight);
        _cellHolder.frame = CGRectMake(0, cellHolderY, _cellHolder.bounds.size.width, defaultRowHeight);
        
        [_cellHolder changeItemText:-scrollView.contentOffset.y > defaultRowHeight ? @"Release to Add Item" : @"Pull to Add Item"];
        
        _cellHolder.alpha = MIN(1.0f, -scrollView.contentOffset.y / defaultRowHeight);
    }
    else{
        
        _pullDownInProgress = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if(_pullDownInProgress && -scrollView.contentOffset.y > defaultRowHeight){
        
        _onEdit = YES;
        
        _tableView.interactionEnable = NO;
        
        _cellHolder.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _cellHolder.bounds.size.height);
        
        _maskView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _tableView.bounds.size.height);
        
        [_tableView.superview insertSubview:_maskView atIndex:1];
        [_tableView.superview bringSubviewToFront:_cellHolder];
        [_cellHolder startEdit];
    }
    else{
        
        [_cellHolder removeFromSuperview];
    }
    
    _pullDownInProgress = NO;
}

#pragma mark - internal
- (void)onTapMaskView{
    
    [self endEditWithText:@""];
}

#pragma mark - PDANCellHolder delegate
- (void)endEditWithText:(NSString *)text{
    
    _onEdit = NO;
    
    _tableView.interactionEnable = YES;
    
    [_maskView removeFromSuperview];
    [_cellHolder removeFromSuperview];
    
    if([text length] <= 0)
        return;
    
    if([self.delegate respondsToSelector:@selector(addNewItemWithText:)]){
        
        [self.delegate addNewItemWithText:text];
    }
}

@end
