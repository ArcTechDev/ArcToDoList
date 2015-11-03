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

@interface CategoryViewController ()

@property (weak, nonatomic) IBOutlet ParentTableView *tableView;

@end

@implementation CategoryViewController{
    
    NSMutableArray *_categoryItems;
    CGFloat _cellHeight;
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
    
    _categoryItems = [[NSMutableArray alloc] initWithObjects:
    
    [CategoryItem createCategoryItemWithName:@"Things to do"],
    [CategoryItem createCategoryItemWithName:@"Tomorrow"],
    [CategoryItem createCategoryItemWithName:@"Next week"],
    [CategoryItem createCategoryItemWithName:@"Extra"]
    
    , nil];
    
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

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:leftItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    //color mark
    UIColor *startColor = cell.startColorMark;
    float r,g,b,a;
    const CGFloat *colorComponent = CGColorGetComponents(startColor.CGColor);
    
    r = colorComponent[0] + ((1.0f - colorComponent[0])/_categoryItems.count) * index;
    g = colorComponent[1] + ((1.0f - colorComponent[1])/_categoryItems.count) * index;
    b = colorComponent[2] + ((1.0f - colorComponent[2])/_categoryItems.count) * index;
    a = colorComponent[3];
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    cell.colorView.backgroundColor = color;
    
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
    
    CategoryCell *cell = (CategoryCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    
    [cell.completeLabel setHidden:NO];
    
    
    cell.completeLabel.alpha = delta;
    
    if(delta >= 1){
        
        cell.completeLabel.textColor = [UIColor greenColor];
    }
    else{
        
        cell.completeLabel.textColor = [UIColor blackColor];
    }
}

- (BOOL)canPanLeftAtCellIndex:(NSInteger)index{
    
    return YES;
}

- (BOOL)canPanRightAtCellIndex:(NSInteger)index{
    
    return YES;
}

- (void)onPanLeftAtCellIndex:(NSInteger)index{
    
    NSLog(@"delete at index %li", (long)index);
    
    [_categoryItems removeObjectAtIndex:index];
    [_tableView deleteRowAtIndex:index withAnimation:UITableViewRowAnimationFade];
    
    [_tableView reloadData];
}

- (void)onPanRightAtCellIndex:(NSInteger)index{
    
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
    
    [_tableView reloadData];
}

#pragma mark - SingleTap delegate
- (void)onSingleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"on tap on index %li", (long)index);
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
    
    [_categoryItems exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
}

#pragma mark - PullDownAddNew delegate
- (void)addNewItemWithText:(NSString *)text{
    
    NSLog(@"add new item %@", text);
    [_categoryItems insertObject:[CategoryItem createCategoryItemWithName:text] atIndex:0];
    
    [_tableView insertNewRowAtIndex:0 withAnimation:UITableViewRowAnimationTop];
    
    [_tableView reloadData];
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
    item.itemName = name;
    
    CategoryCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    cell.titleLabel.text = name;
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
