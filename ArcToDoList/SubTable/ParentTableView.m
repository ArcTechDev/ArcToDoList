//
//  ParentTableView.m
//  SubTableView
//
//  Created by User on 26/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableView.h"
#import "ParentTableViewCell.h"
#import "GestureComponent.h"

@implementation ParentTableView{
    
    ParentTableViewCell *_previouslySelectedCell;
    BOOL _isInitialized;
    BOOL _isOnEditing;
    
    //hold all gesture components
    NSMutableArray *_gestureComponents;
    
    //hold all object that want to listen event from UIScrollView
    NSMutableSet<id<UIScrollViewDelegate>> *_uiscrollViewDelegateListener;
    
    //determine whether tableView can be interacted
    BOOL _interactionEnable;
}

@synthesize theDelegate = _theDelegate;
@synthesize selectedRow = _selectedRow;
@synthesize allGestureComponents = _allGestureComponents;
@synthesize isOnEdit = _isOnEdit;

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [super initWithCoder:aDecoder]){
        
    }
    
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if(!_isInitialized){
        
        [self initialize];
        
        _isInitialized = YES;
    }
}

#pragma mark - init
- (void)initialize{
    
    _isOnEditing = NO;
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    [self initExpansionStates];
    
    //register notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)initExpansionStates{
    
    //init expand/collapse states for each parent cell
    _expansionStates = [[NSMutableArray alloc] initWithCapacity:[_theDelegate numberOfParentCellIsInTableView:self]];
    
    //set all states to NO
    for(int i=0; i<[_theDelegate numberOfParentCellIsInTableView:self]; i++){
        
        [_expansionStates addObject:@"NO"];
    }
}

#pragma mark - Table interaction
- (void)expandForParentAtRow:(NSInteger)row {
    
    //get parent index
    NSUInteger parentIndex = [self parentIndexForRow:row];

    
    //return if state is already expanded
    if ([[_expansionStates objectAtIndex:parentIndex] boolValue]) {
        return;
    }
    
    // update expansionStates so backing data is ready before calling insertRowsAtIndexPaths
    [_expansionStates replaceObjectAtIndex:parentIndex withObject:@"YES"];
    [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    //set tableView to editing mode
    _isOnEditing = YES;
    
    //we need to adjust expanded sub cell in case it is out of screen
    [self adjustSubCellAtIndex:row+1];
    
    //tell delegate a parent cell has been expanded
    if([_theDelegate respondsToSelector:@selector(tableView:didExpandForParentCellAtIndex:withSubCellIndex:)]){
        
        [_theDelegate tableView:self didExpandForParentCellAtIndex:parentIndex withSubCellIndex:row+1];
    }
    
}

- (void)collapseForParentAtRow:(NSInteger)row {
    
    //return if number of parent cell is less or equal to 0
    if (![_theDelegate numberOfParentCellIsInTableView:self] > 0) {
        return;
    }
    
    //find parent index
    NSUInteger parentIndex = [self parentIndexForRow:row];

    //if it is already collapsed then return
    if (![[_expansionStates objectAtIndex:parentIndex] boolValue]) {
        return;
    }
    
    // update expansionStates so backing data is ready before calling deleteRowsAtIndexPaths
    [_expansionStates replaceObjectAtIndex:parentIndex withObject:@"NO"];
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    //set tableView to not editing mode
    _isOnEditing = NO;
    
    //tell delegate parent cell collapsed
    if([_theDelegate respondsToSelector:@selector(tableView:didCollapseForParentCellAtIndex:withSubCellIndex:)]){
        
        [_theDelegate tableView:self didCollapseForParentCellAtIndex:parentIndex withSubCellIndex:row+1];
    }
}

/**
 * Adjust expanded sub cell
 * it will automatically adjust all table position and make sure
 * sub cell do not out side of screen
 */
- (void)adjustSubCellAtIndex:(NSInteger)rowIndex{
    
    //sub cell index
    NSInteger row = rowIndex;
    
    //parent index of this sub cell
    NSUInteger parentIndex = [self parentIndexForRow:row];
    
    //default sub cell height is 44
    CGFloat cellheight = 44.0f;
    
    //get sub cell
    SubTableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    //sub cell origin y
    CGFloat cellOriginY = cell.frame.origin.y;
    
    //if sub cell not found we use parent cell's bottom edge as sub cell's origin y
    if(cell == nil){
        
        ParentTableViewCell *pCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:parentIndex inSection:0]];
        
        cellOriginY = pCell.frame.origin.y + pCell.bounds.size.height;
    }
    
    //ask delegate for sub cell height
    if([_theDelegate respondsToSelector:@selector(tableView:subCellHeightForRowAtIndex:underParentIndex:)]){
        
        cellheight = [_theDelegate tableView:self subCellHeightForRowAtIndex:row underParentIndex:parentIndex];
    }
    
    //find sub cell's bottom edge
    CGFloat cellBottomEdge = cellOriginY +cellheight;
    
    //find visible height
    CGFloat visibleHeight = self.contentOffset.y + self.bounds.size.height;
    
    //check if sub cell is out of screen if so scroll tableview make sub cell visible
    if(cellBottomEdge > visibleHeight){
        
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Table information
- (NSUInteger)rowForParentIndex:(NSUInteger)parentIndex{
    
    NSUInteger row = 0;
    NSUInteger currentParentIndex = 0;
    
    if(parentIndex == 0){
        
        return 0;
    }
    
    while (currentParentIndex < parentIndex) {
        BOOL expanded = [[_expansionStates objectAtIndex:currentParentIndex] boolValue];
        if (expanded) {
            row++;
        }
        currentParentIndex++;
        row++;
    }
    return row;
}

- (NSUInteger)parentIndexForRow:(NSUInteger)row{
    
    NSUInteger parentIndex = -1;
    
    NSUInteger i = 0;
    while (i <= row) {
        parentIndex++;
        i++;
        if ([[_expansionStates objectAtIndex:parentIndex] boolValue]) {
            i++;
        }
    }
    return parentIndex;
}

- (BOOL)isExpansionCell:(NSUInteger)row{
    
    if (row < 1) {
        return NO;
    }
    NSUInteger parentIndex = [self parentIndexForRow:row];
    NSUInteger parentIndex2 = [self parentIndexForRow:(row-1)];
    return (parentIndex == parentIndex2);
}

#pragma mark - internal
- (void)deviceOrientationDidChange:(NSNotification *)notification{
    
    [self reloadData];
    
    if(_uiscrollViewDelegateListener != nil){
        
        for(id go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(deviceOrientationDidChange)]){
                
                [go deviceOrientationDidChange];
            }
        }
    }
}

#pragma mark - getter
- (NSArray *)getGestureComponents{
    
    return _gestureComponents;
}

- (BOOL)getIsOnEdit{
    
    return _isOnEditing;

}

#pragma mark - setter
- (void)setInteractionEnable:(BOOL)interactionEnable{
    
    _interactionEnable = interactionEnable;
    
    self.userInteractionEnabled = _interactionEnable;
}

#pragma mark - public interface
- (void)collapseAllRows{
    
    if([_expansionStates containsObject:@"YES"]){
        
        NSInteger row = [_expansionStates indexOfObject:@"YES"];
        
        [_expansionStates replaceObjectAtIndex:row withObject:@"NO"];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        _isOnEditing = NO;
        
        if([_theDelegate respondsToSelector:@selector(tableView:didCollapseForParentCellAtIndex:withSubCellIndex:)]){
            
            [_theDelegate tableView:self didCollapseForParentCellAtIndex:row withSubCellIndex:row+1];
        }
    }
}

- (BOOL)expandForParentCellAtIndex:(NSInteger)index{
    
    UITableViewCell *selectedPCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    //if it is parent cell
    if([selectedPCell isKindOfClass:[ParentTableViewCell class]]){
        
        ParentTableViewCell *pCell = (ParentTableViewCell *)selectedPCell;
        
        if([_theDelegate respondsToSelector:@selector(tableView:canExpandSubCellForRowAtIndex:)]){
            
            if([_theDelegate tableView:self canExpandSubCellForRowAtIndex:pCell.parentIndex]){
                
                _selectedRow = [pCell parentIndex];
                
                if(![[_expansionStates objectAtIndex:[pCell parentIndex]] boolValue]){
                    
                    /*
                     if(_isOnEditing){
                     
                     [self collapseAllRows];
                     }
                     else{
                     
                     // clicked a collapsed cell
                     [self collapseAllRows];
                     [self expandForParentAtRow:[pCell parentIndex]];
                     }
                     */
                    
                    // clicked a collapsed cell
                    [self collapseAllRows];
                    [self expandForParentAtRow:[pCell parentIndex]];
                    
                    _previouslySelectedCell = pCell;
                    
                    return YES;
                }
                else{
                    
                    // clicked an already expanded cell
                    [self collapseForParentAtRow:[pCell parentIndex]];
                    _previouslySelectedCell = nil;
                     
                    return NO;
                }
            }
            
        }
        
    }
    
    return NO;
}

- (BOOL)canExpandParentCellAtIndex:(NSInteger)index{
    
    if([_theDelegate respondsToSelector:@selector(tableView:canExpandSubCellForRowAtIndex:)]){
        
        return [_theDelegate tableView:self canExpandSubCellForRowAtIndex:index];
    }
    
    return NO;
}

- (UITableViewCell *)cellViewFromNib:(NSString *)nibName atViewIndex:(NSUInteger)viewIndex{
    
    if(!nibName)
        return nil;
    
    if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]){
        
        NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        UITableViewCell *cellView = [viewArray objectAtIndex:viewIndex];
        
        return cellView;
    }
    
    return nil;
}

- (void)addListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    if(_uiscrollViewDelegateListener == nil){
        
        _uiscrollViewDelegateListener = [[NSMutableSet alloc] init];
    }
    
    [_uiscrollViewDelegateListener addObject:listener];
}

- (void)removeListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    if(_uiscrollViewDelegateListener != nil)
        [_uiscrollViewDelegateListener removeObject:listener];
}

- (void)addGestureComponent:(GestureComponent *)component{
    
    if(_gestureComponents == nil){
        
        _gestureComponents = [[NSMutableArray alloc] init];
    }
    
    if(component == nil){
        
        NSLog(@"Add component can not be nil");
        return;
    }
    
    BOOL exist = NO;
    
    for(GestureComponent *c in _gestureComponents){
        
        if([c isKindOfClass:[component class]]){
            
            exist = YES;
            break;
        }
    }
    
    if(exist){
        
        NSLog(@"Component you add is already exist");
        return;
    }
    
    [_gestureComponents addObject:component];
    
    NSArray *sortedComponents;
    
    sortedComponents = [_gestureComponents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        
        GestureComponent *c1 = obj1;
        GestureComponent *c2 = obj2;
        
        NSInteger result = c2.priority - c1.priority;
        
        if(result > 0){
            
            return NSOrderedAscending;
        }
        else if(result < 0){
            
            return NSOrderedDescending;
        }
        else{
            
            return NSOrderedSame;
        }
    }];
    
    _gestureComponents = [[NSMutableArray alloc] initWithArray:sortedComponents];
}

- (void)removeGestureComponent:(GestureComponent *)component{
    
    if(component == nil)
        return;
    
    //remove gesture
    [self removeGestureRecognizer:component.gestureRecognizer];
    
    //remove component
    [_gestureComponents removeObject:component];
}

- (void)removeGestureComponentByClass:(Class)componentClass{
    
    GestureComponent *removedComponent;
    
    //go through gesture components and find it
    for(GestureComponent *component in _gestureComponents){
        
        if([component isKindOfClass:componentClass]){
            
            removedComponent = component;
            
            break;
        }
    }
    
    //remove it
    [self removeGestureComponent:removedComponent];
}

- (id)findGestureComponentByClass:(Class)componentClass{
    
    //go through gesture components and find it
    for(GestureComponent *component in _gestureComponents){
        
        if([component isKindOfClass:componentClass]){
            
            return component;
        }
    }
    
    return nil;
}

- (ParentTableViewCell *)findCellByTouchPoint:(CGPoint)point{
    
    CGPoint adjustPoint = CGPointMake(point.x, self.contentOffset.y+ point.y);
    
    for(UITableViewCell *go in self.visibleCells){
        
        CGRect rect = CGRectMake(go.frame.origin.x, go.frame.origin.y + self.contentOffset.y, go.frame.size.width, go.frame.size.height);
        
        if(CGRectContainsPoint(rect, adjustPoint)){
            
            if([go isKindOfClass:[ParentTableViewCell class]])
                return (ParentTableViewCell *)go;
            else
                return nil;
        }
    }
    
    return nil;
}

- (void)insertNewRowAtIndex:(NSInteger)index withAnimation:(UITableViewRowAnimation)anim;{
    
    [self collapseAllRows];
    
    [_expansionStates insertObject:@"NO" atIndex:0];
    
    //update parent index
    for(ParentTableViewCell *cell in [self visibleCells]){
        
        if(cell.parentIndex >= index)
            cell.parentIndex += 1;
    }
    
    [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}

- (void)deleteRowAtIndex:(NSInteger)index withAnimation:(UITableViewRowAnimation)anim{
    
    [self collapseAllRows];
    
    [_expansionStates removeObjectAtIndex:index];
    
    //update parent index
    for(ParentTableViewCell *cell in [self visibleCells]){
        
        if(cell.parentIndex >= index)
            cell.parentIndex -= 1;
    }
    
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:anim];
}

- (void)moveRowAtIndex:(NSInteger)targetIndex toIndex:(NSInteger)destIndex{
    
    [self collapseAllRows];
    
    int offset = 0;
    if(targetIndex < destIndex){
        
        offset = -1;
        
        //update parent index
        for(ParentTableViewCell *cell in [self visibleCells]){
            
            if(cell.parentIndex > targetIndex && cell.parentIndex <= destIndex){
                
                cell.parentIndex += offset;
            }
        }
    }
    else if(targetIndex > destIndex){
        
        offset = 1;
        
        //update parent index
        for(ParentTableViewCell *cell in [self visibleCells]){
            
            if(cell.parentIndex < targetIndex && cell.parentIndex >= destIndex){
                
                cell.parentIndex += offset;
            }
        }
    }
    
    
    
    ParentTableViewCell *targetCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
    targetCell.parentIndex = destIndex;
    
    
    [self moveRowAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:destIndex inSection:0]];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(![_theDelegate numberOfParentCellIsInTableView:self] > 0){
        
        return 0;
    }
    
    // returns sum of parent cells and expanded cells
    NSInteger parentCount = [_theDelegate numberOfParentCellIsInTableView:self];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:_expansionStates];
    NSUInteger expandedParentCount = [countedSet countForObject:@"YES"];
    
    return parentCount + expandedParentCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //todo determine if it is parent cell or child cell then ask delegate for cell
    
    NSInteger row = indexPath.row;
    NSUInteger parentIndex = [self parentIndexForRow:row];
    BOOL isParentCell = ![self isExpansionCell:row];
    
    if(isParentCell){
        
        ParentTableViewCell *cell =  (ParentTableViewCell *)[_theDelegate tableView:self parentCellForRowAtIndex:parentIndex];
        cell.parentIndex = parentIndex;
        
        return cell;
    }
    else{
        
        SubTableViewCell *subCell = (SubTableViewCell *)[_theDelegate tableView:self subCellRowUnderParentIndex:parentIndex];
        subCell.parentIndex = parentIndex;
        subCell.delegate = self;
        [subCell reloadData];
        
        return subCell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    NSUInteger parentIndex = [self parentIndexForRow:row];
    BOOL isParentCell = ![self isExpansionCell:row];
    
    if(isParentCell){
        
        if([_theDelegate respondsToSelector:@selector(tableView:parentCellHeightForRowAtIndex:)]){
            
            return [_theDelegate tableView:self parentCellHeightForRowAtIndex:parentIndex];
        }
        
        return 44.0f;
    }
    else{
        
        if([_theDelegate respondsToSelector:@selector(tableView:subCellHeightForRowAtIndex:underParentIndex:)]){
            
            return [_theDelegate tableView:self subCellHeightForRowAtIndex:row underParentIndex:parentIndex];
        }
        
        return 44.0f;
    }
}

#pragma mark - UITableView delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *selectedPCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([selectedPCell isKindOfClass:[ParentTableViewCell class]]){
        
        ParentTableViewCell *pCell = (ParentTableViewCell *)selectedPCell;
        
        
        if([_theDelegate respondsToSelector:@selector(tableView:canExpandSubCellForRowAtIndex:)]){
            
            if([_theDelegate tableView:self canExpandSubCellForRowAtIndex:pCell.parentIndex]){
                
                _selectedRow = [pCell parentIndex];
                
                if([[_expansionStates objectAtIndex:[pCell parentIndex]] boolValue]){
                    
                    // clicked an already expanded cell
                    [self collapseForParentAtRow:indexPath.row];
                    _previouslySelectedCell = nil;
                }
                else{
                    
 
                   // if(_isOnEditing){
                     
                   //   [self collapseAllRows];
                   //  }
                   //  else{
                     
                     // clicked a collapsed cell
                   //    [self collapseAllRows];
                   //     [self expandForParentAtRow:[pCell parentIndex]];
                   //  }
 
                    
                    // clicked a collapsed cell
                    [self collapseAllRows];
                    [self expandForParentAtRow:[pCell parentIndex]];
                    
                    _previouslySelectedCell = pCell;
                }
            }
        }
        

      //  if([_theDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndex:)]){
            
      //      [_theDelegate tableView:self didSelectRowAtIndex:[pCell parentIndex]];
      //  }
        
    }
}
*/

#pragma mark - SubTableViewDelegate
- (NSInteger)numberOfChildrenCellUnderParentIndex:(NSInteger)parentIndex{
    
    return [_theDelegate numberOfChildrenCellUnderParentIndex:parentIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView childCellForRowAtIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    return [_theDelegate tableView:tableView childCellForRowAtIndex:childIndex underParentIndex:parentIndex];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    /*
    if([_theDelegate respondsToSelector:@selector(tableView:didSelectRowAtChildIndex:underParentIndex:)]){
        
        [_theDelegate tableView:tableView didSelectRowAtChildIndex:childIndex underParentIndex:parentIndex];
    }
     */
    
    //we dont want to child cell to be selected
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:childIndex inSection:0] animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView childCellHeightForRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    if([_theDelegate respondsToSelector:@selector(tableView:childCellHeightForRowAtChildIndex:underParentIndex:)]){
        
        return [_theDelegate tableView:tableView childCellHeightForRowAtChildIndex:childIndex underParentIndex:parentIndex];
    }
    
    return 44.0f;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidScroll:)]){
                
                [go scrollViewDidScroll:scrollView];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
                
                [go scrollViewWillBeginDragging:scrollView];
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]){
                
                [go scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
                
                [go scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    
    BOOL scrollToTop = YES;
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewShouldScrollToTop:)]){
                
                scrollToTop = scrollToTop && [go scrollViewShouldScrollToTop:scrollView];
            }
        }
    }
    
    return scrollToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
                
                [go scrollViewDidScrollToTop:scrollView];
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]){
                
                [go scrollViewWillBeginDecelerating:scrollView];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
                
                [go scrollViewDidEndDecelerating:scrollView];
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
                
                [go scrollViewDidEndScrollingAnimation:scrollView];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
