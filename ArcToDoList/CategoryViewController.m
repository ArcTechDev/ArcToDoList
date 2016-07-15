//
//  CategoryViewController.m
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "CategoryViewController.h"
#import "ParentTableView.h"
#import "CategoryItem.h"
#import "CategoryCell.h"
#import "AccountManager.h"
#import "TaskViewController.h"


@interface CategoryViewController ()

@property (weak, nonatomic) IBOutlet ParentTableView *tableView;

@end

@implementation CategoryViewController{
    
    NSMutableArray *_categoryItems;
    CGFloat _cellHeight;
    FPPopoverController *_popoverController;
    UIView *_blurView;
}

@synthesize tableView = _tableView;

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [super initWithCoder:aDecoder]){
        
        _cellHeight = -1.0f;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

     _categoryItems = [[NSMutableArray alloc] init];
    
    /*
    for(int i=0; i<20; i++){
        
        [_categoryItems addObject:[CategoryItem createCategoryItemWithName:[NSString stringWithFormat:@"Thing to do %i", i]]];
    }
     */
    
    //pan left right gesture
    PanLeftRight *panLeftRight = [[PanLeftRight alloc] initWithTableView:_tableView WithPriority:0];
    panLeftRight.panRightSnapBackAnim = YES;
    panLeftRight.panLeftSnapBackAnim = YES;
    panLeftRight.delegate = self;
    [_tableView addGestureComponent:panLeftRight];
    
    //single tap gesture
    SingleTap *singleTap = [[SingleTap alloc] initWithTableView:_tableView WithPriority:0];
    singleTap.delegate = self;
    [_tableView addGestureComponent:singleTap];
    
    //double tap edit gesture
    DoubleTapEdit *doubleTapEdit = [[DoubleTapEdit alloc] initWithTableView:_tableView WithPriority:0];
    doubleTapEdit.delegate = self;
    [_tableView addGestureComponent:doubleTapEdit];
    
    //make sure single tap happen when double tap edit fail
    [singleTap requireGestureComponentToFail:doubleTapEdit];
    
    //long press move gesture
    LongPressMove *longPressMove = [[LongPressMove alloc] initWithTableView:_tableView WithPriority:0];
    longPressMove.delegate= self;
    [_tableView addGestureComponent:longPressMove];
    
    //pull down add new gesture
    PullDownAddNew *pullAddNew = [[PullDownAddNew alloc] initWithTableView:_tableView WithPriority:0];
    pullAddNew.delegate = self;
    [_tableView addGestureComponent:pullAddNew];
    
    //init first time
    [[ServerInterface sharedInstance] loadCategoryItemOnComplete:^(NSDictionary *values) {
        
        for(NSString *key in values.allKeys){
            
            CategoryItem *item = [CategoryItem createCategoryItemWithName:((NSDictionary *)values[key])[FPCatItemName]];
            item.itemId = key;
            item.priority = [(values[key])[FCategoryItemPriority] integerValue];
            item.taskCount = [values[key][FPCatItemTaskCount] integerValue];
            
            [_categoryItems addObject:item];
        
        }
        
        if(values.count > 0){
            
            [_categoryItems sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                
                CategoryItem *item1 = obj1;
                CategoryItem *item2 = obj2;
                
                if(item1.priority > item2.priority)
                    return NSOrderedDescending;
                else if(item1.priority < item2.priority)
                    return NSOrderedAscending;
                else
                    return NSOrderedSame;
            }];
            
            
            [_tableView reloadTableData];
        }
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to load category items");
    }];

    [self startListeningEvent];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenuTapped:event:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:leftItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
    [[[ServerInterface sharedInstance] refCategoryItems] removeAllObservers];
}

#pragma mark - Sort array


#pragma mark - Firebase listener
- (void)startListeningEvent{
    
    //Listen child added event
   [[[ServerInterface sharedInstance] refCategoryItems] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            for(CategoryItem *item in _categoryItems){
                
                if([item.itemId isEqualToString:snapshot.key])
                    return;
            }
            
            NSLog(@"child added event new value added key:%@, value:%@", snapshot.key, snapshot.value);
            
            
            NSString *itemName = ((NSDictionary *)snapshot.value)[FPCatItemName];
            CategoryItem *item = [CategoryItem createCategoryItemWithName:[itemName copy]];
            item.itemId = [snapshot.key copy];
            item.priority = [snapshot.value[FCategoryItemPriority] integerValue];
            
            [_categoryItems insertObject:item atIndex:0];
            
            [_tableView insertNewRowAtIndex:0 withAnimation:UITableViewRowAnimationTop];
            
            for(CategoryCell *cell in _tableView.visibleCells){
                
                NSInteger index = [_tableView indexPathForCell:cell].row;
                cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
       
        NSLog(@"Listen to child added event error:%@", error);
    }];
    
    //Listen child delete event
    [[[ServerInterface sharedInstance] refCategoryItems] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            NSUInteger index = 0;
            BOOL shouldRemove = NO;
            
            for(CategoryItem *item in _categoryItems){
                
                if([item.itemId isEqualToString:snapshot.key]){
                    
                    index = [_categoryItems indexOfObject:item];
                    shouldRemove = YES;
                    break;
                }
            }
            
            if(shouldRemove){
                
                [_categoryItems removeObjectAtIndex:index];
                [_tableView deleteRowAtIndex:index withAnimation:UITableViewRowAnimationFade];
                
                for(CategoryCell *cell in _tableView.visibleCells){
                    
                    NSInteger index = [_tableView indexPathForCell:cell].row;
                    cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
                }
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Listen to child delete event error:%@", error);
    }];
    
    //Listen child change event
    [[[ServerInterface sharedInstance] refCategoryItems] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            for(CategoryItem *item in _categoryItems){
                
                if([item.itemId isEqualToString:snapshot.key]){
                    
                    BOOL reloadTableData = NO;
                    
                    item.itemName = [((NSDictionary *)snapshot.value)[FPCatItemName] copy];
                    
                    if(item.priority != [snapshot.value[FCategoryItemPriority] integerValue])
                        reloadTableData = YES;
                    
                    item.priority = [snapshot.value[FCategoryItemPriority] integerValue];
                    
                    //will do task count
                    item.taskCount = [snapshot.value[FPCatItemTaskCount] integerValue];
                    
                    NSUInteger index = [_categoryItems indexOfObject:item];
                    
                    CategoryCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    
                    cell.titleLabel.text = item.itemName;
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", item.taskCount];
                    
                    if(reloadTableData){
                        
                        [_categoryItems sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                            
                            CategoryItem *item1 = obj1;
                            CategoryItem *item2 = obj2;
                            
                            if(item1.priority > item2.priority)
                                return NSOrderedDescending;
                            else if(item1.priority < item2.priority)
                                return NSOrderedAscending;
                            else
                                return NSOrderedSame;
                        }];
                        
                        
                        [_tableView reloadTableData];
                    }
                    
                    return;
                }
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Listen to child change event error:%@", error);
    }];
}

#pragma mark - Internal
- (void)onMenuTapped:(UIBarButtonItem *)sender event:(UIEvent *)event{
    
    MenuViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    controller.title = @"Menu";
    controller.delegate = self;
    
    if(_popoverController != nil){
        
        [_popoverController dismissPopoverAnimated:NO];
        _popoverController = nil;
    }
    
    _popoverController = [[FPPopoverController alloc] initWithViewController:controller delegate:self];
    _popoverController.arrowDirection = FPPopoverNoArrow;
    CGSize presentSize = CGSizeMake(self.view.bounds.size.width * 0.7f, self.view.bounds.size.height * 0.75f);
    _popoverController.contentSize = presentSize;
    
    //add blur
    _blurView = [Helper blurViewFromView:_tableView.superview withBlurRadius:2.5f];
    [_tableView.superview addSubview:_blurView];
    
    [_popoverController presentPopoverFromPoint:CGPointMake(0, 60)];
}

#pragma mark - FPPopoverController delegate
- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController shouldDismissVisiblePopover:(FPPopoverController *)visiblePopoverController{
    
    
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController{
    
    [_blurView removeFromSuperview];
    _popoverController = nil;
}

#pragma mark - MenuViewControllerDelegate
- (void)onProfileSelected{
    
    [_popoverController dismissPopoverAnimated:YES];
}

- (void)onColorSelected{
    
    [_popoverController dismissPopoverAnimated:YES];
}

- (void)onPrivacySelected{
    
    [_popoverController dismissPopoverAnimated:YES];
}

- (void)onLanguageSelected{
    
    [_popoverController dismissPopoverAnimated:YES];
}

- (void)onNotificationSelected{
    
    [_popoverController dismissPopoverAnimated:YES];
}

- (void)onSignOutSelected{
    
    [_popoverController dismissPopoverAnimated:YES completion:^{
        
        
        [[AccountManager sharedInstance] logoutSuccess:^{
            
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        } fail:^(NSError *error) {
            
            
        }];
        
        
    }];
}

#pragma mark - ParentTableView delegate

- (NSInteger)numberOfParentCellIsInTableView:(ParentTableView *)tableView{
    
    return _categoryItems.count;
}


- (UITableViewCell *)tableView:(ParentTableView *)tableView parentCellForRowAtIndex:(NSInteger)index{
    
    static NSString *cellId = @"CategoryCell";
    
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(cell == nil){
        
        cell = (CategoryCell *)[tableView cellViewFromNib:@"CategoryCell" atViewIndex:0];
    }
    
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    cell.isComplete = item.isComplete;
    cell.titleLabel.text = item.itemName;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", item.taskCount];
    
    cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
    
    return cell;
}


- (UITableViewCell *)tableView:(ParentTableView *)tableView subCellRowUnderParentIndex:(NSInteger)parentIndex{
    
    return nil;
}


- (NSInteger)numberOfChildrenCellUnderParentIndex:(NSInteger)parentIndex{
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView childCellForRowAtIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    return nil;
}

- (CGFloat)tableView:(ParentTableView *)tableView parentCellHeightForRowAtIndex:(NSInteger)index{
    
    if(_cellHeight < 0){
        
        CategoryCell *cell = (CategoryCell *)[tableView cellViewFromNib:@"CategoryCell" atViewIndex:0];
        
        _cellHeight = cell.bounds.size.height;
    }
    
    return _cellHeight;
}

#pragma mark - PanleftRight delegate
//handle panning left
- (void)onPanningLeftWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index{
    
    CategoryCell *cell = (CategoryCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    
    [cell.deleteLabel setHidden:NO];
    
    cell.deleteLabel.alpha = delta;
    
    if(delta >= 1){
        
        cell.deleteLabel.textColor = [UIColor redColor];
    }
    else{
        
        cell.deleteLabel.textColor = [UIColor blackColor];
    }
    
}

//handle panning right
- (void)onPanningRightWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index{
    
    //we dont have pan right
}

- (BOOL)canPanLeftAtCellIndex:(NSInteger)index{
    
    return YES;
}

- (BOOL)canPanRightAtCellIndex:(NSInteger)index{
    
    //we don't want cell to pan right in category view
    return NO;
}

- (void)onPanLeftAtCellIndex:(NSInteger)index{
    
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    [[ServerInterface sharedInstance] deleteCategoryItemWithItemId:item.itemId withItemPriority:item.priority onComplete:^(NSString *itemId) {
        
        NSLog(@"delete at index %li", (long)index);
        /*
        [_categoryItems removeObjectAtIndex:index];
        [_tableView deleteRowAtIndex:index withAnimation:UITableViewRowAnimationFade];
        
        //[_tableView reloadData];
        
        for(CategoryCell *cell in _tableView.visibleCells){
            
            NSInteger index = [_tableView indexPathForCell:cell].row;
            cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
        }
         */
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to delete item server error:%@", error);
    }];
    
}

- (void)onPanRightAtCellIndex:(NSInteger)index{
    /*
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    if(item.isComplete){
        
        NSLog(@"recover at index %li", (long)index);
        
        item.isComplete = NO;
        
        [_categoryItems removeObjectAtIndex:index];
        
        [_categoryItems insertObject:item atIndex:0];
        
        CategoryCell *visualCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        visualCell.isComplete = NO;
        
        [_tableView moveRowAtIndex:index toIndex:0];
    }
    else{
        
        NSLog(@"complete at index %li", (long)index);
        
        id obj = [_categoryItems objectAtIndex:index];
        ((CategoryItem *)obj).isComplete = YES;
        [_categoryItems removeObjectAtIndex:index];
        [_categoryItems addObject:obj];
        
        CategoryCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.isComplete = YES;
        
        
        [_tableView moveRowAtIndex:index toIndex:[_categoryItems count]-1];
    }
    
    //[_tableView reloadData];
    
    for(CategoryCell *cell in _tableView.visibleCells){
        
        NSInteger index = [_tableView indexPathForCell:cell].row;
        cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
    }
     */
}

#pragma mark - SingleTap delegate
- (void)onSingleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"on tap on index %li", (long)index);
    
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    if(item.isComplete)
        return;
    
    TaskViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskViewController"];
    controller.underCategoryItemId = item.itemId;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - LongPressMove delegate
- (BOOL)canMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    CategoryItem *item1 = [_categoryItems objectAtIndex:fromIndex];
    CategoryItem *item2 = [_categoryItems objectAtIndex:toIndex];
    
    if(item1.isComplete == item2.isComplete)
        return YES;
    
    return NO;
}

- ( void)willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    //swap priority
    CategoryItem *item1 = [_categoryItems objectAtIndex:fromIndex];
    CategoryItem *item2 = [_categoryItems objectAtIndex:toIndex];
    
    NSInteger tempPriority = item1.priority;
    item1.priority = item2.priority;
    item2.priority = tempPriority;
    
    [_categoryItems exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    
}

- (void)didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    
    if(fromIndex == toIndex)
        return;
    
    NSLog(@"...............");
    for(CategoryItem *i in _categoryItems){
        
        NSLog(@"priority:%ld", i.priority);
        
    }
    NSLog(@"...............");
    
    NSInteger startIndex = fromIndex;
    NSInteger endIndex = toIndex;
    
    if(startIndex > endIndex){
        
        NSInteger tempIndex = startIndex;
        startIndex = endIndex;
        endIndex = tempIndex;
    }
    
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    
    
    for(NSInteger i = 0; i < _categoryItems.count; i++){
        
        CategoryItem *item = [_categoryItems objectAtIndex:i];
        
        [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
        
    }
    
    
    [[ServerInterface sharedInstance] updateCategoryItemPriority:dic complete:^{
        
    } fail:^(NSError *error) {
       
        NSLog(@"unable to update category item priority");
    }];
    
}

#pragma mark - PullDownAddNew delegate
- (void)addNewItemWithText:(NSString *)text{
    
    [[ServerInterface sharedInstance] addCategoryItemWithText:text onComplete:^(NSString *itemId, NSString *text) {
        
        NSLog(@"add new item %@", text);
        
        /*
        CategoryItem *item = [CategoryItem createCategoryItemWithName:text];
        item.itemId = itemId;
        
        [_categoryItems insertObject:item atIndex:0];
        
        [_tableView insertNewRowAtIndex:0 withAnimation:UITableViewRowAnimationTop];
        
        //[_tableView reloadData];
        
        for(CategoryCell *cell in _tableView.visibleCells){
            
            NSInteger index = [_tableView indexPathForCell:cell].row;
            cell.colorView.backgroundColor = [Helper transitColorForItemAtIndex:index totalItemCount:_categoryItems.count startColor:cell.startColorMark endColor:cell.endColorMark];
        }
         */
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to add item server error:%@", error);
    }];
    
}

#pragma mark - DoubleTapEdit delegate
- (BOOL)canStartEditAtIndex:(NSInteger)index{
    
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    return !item.isComplete;
}
- (NSString *)nameForItemAtIndex:(NSInteger)index{
    
    return ((CategoryItem *)[_categoryItems objectAtIndex:index]).itemName;
}

- (void)onDoubleTapEditCompleteAtIndex:(NSInteger)index withItemName:(NSString *)name{
    
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    
    [[ServerInterface sharedInstance] modifyCategoryItemWithItemId:item.itemId text:name onComplete:^(NSString *itemId, NSString *text) {
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to modify item server error:%@", error);
    }];
    
    /*
    CategoryItem *item = [_categoryItems objectAtIndex:index];
    item.itemName = name;
    
    CategoryCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    cell.titleLabel.text = name;
     */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
