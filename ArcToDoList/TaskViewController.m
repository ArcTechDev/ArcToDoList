//
//  TaskViewController.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskViewController.h"

@interface TaskViewController ()

@property (weak, nonatomic) IBOutlet MZDayPicker *dayPicker;
@property (weak, nonatomic) IBOutlet ParentTableView *tableView;

@end

@implementation TaskViewController{
    
    NSMutableArray *_dataArray;
    CGFloat taskCellHeight;
    CGFloat subTaskCellHeight;
}

@synthesize dayPicker = _dayPicker;
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    taskCellHeight = -1;
    subTaskCellHeight = -1;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<20; i++){
        
        [_dataArray addObject:[TaskItem createTaskItemWithName:[NSString stringWithFormat:@"Task%i", i]]];
    }
    
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
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self setupDayPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupDayPicker{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    //NSInteger day = components.day;
    NSInteger month = components.month;
    NSInteger year = components.year;
    
    NSTimeInterval p7 = -7 * 86400;
    NSTimeInterval f7 = 7 * 86400;
    NSDate *currentDate = [NSDate date];
    NSDate *past7Date = [currentDate dateByAddingTimeInterval:p7];
    NSDate *future7Date = [currentDate dateByAddingTimeInterval:f7];
    
    _dayPicker.dataSource = self;
    _dayPicker.delegate = self;
    _dayPicker.month =month;
    _dayPicker.year = year;
    
    /*
    _dayPicker.activeDayColor = [UIColor redColor];
    _dayPicker.activeDayNameColor = [UIColor greenColor];
    _dayPicker.inactiveDayColor = [UIColor blackColor];
    
    _dayPicker.backgroundPickerColor = [UIColor brownColor];
    _dayPicker.bottomBorderColor = [UIColor purpleColor];
    
    _dayPicker.dayLabelFontSize = 40.0f;
    _dayPicker.dayNameLabelFontSize = 20.0f;
    
    _dayPicker.dayLabelZoomScale = 50.0f;
    */
    
    [_dayPicker setStartDate:past7Date endDate:future7Date];
    
    [_dayPicker setCurrentDate:currentDate animated:YES];
}


#pragma mark - ParentTableView delegate

- (NSInteger)numberOfParentCellIsInTableView:(ParentTableView *)tableView{
    
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(ParentTableView *)tableView parentCellForRowAtIndex:(NSInteger)index{
    
    static NSString *taskCellId = @"TaskCell";
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellId];
    
    if(cell == nil){
        
        cell = (TaskCell *)[tableView cellViewFromNib:@"TaskCell" atViewIndex:0];
    }
    
    TaskItem *item = [_dataArray objectAtIndex:index];
    
    cell.titleLabel.text = item.taskItemName;
    cell.isComplete = item.isComplete;
    
    
    if(!item.isComplete)
        cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
    
    if(_tableView.isOnEdit){
        
        if(_tableView.lastExpandParentIndex != index){
            
            [cell setMaskEnable:YES];
        }
        else{
            
            [cell setMaskEnable:NO];
        }
    }
    else{
        
        [cell setMaskEnable:NO];
    }

    
    return cell;
}


- (UITableViewCell *)tableView:(ParentTableView *)tableView subCellRowUnderParentIndex:(NSInteger)parentIndex{
    
    static NSString *subTaskCellId = @"SubTaskCell";
    
    SubTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:subTaskCellId];
    
    if(cell == nil){
        
        cell = (SubTaskCell *)[tableView cellViewFromNib:@"SubTaskCell" atViewIndex:0];
    }
    
    return cell;
}


- (NSInteger)numberOfChildrenCellUnderParentIndex:(NSInteger)parentIndex{
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView childCellForRowAtIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    return nil;
}

- (CGFloat)tableView:(ParentTableView *)tableView parentCellHeightForRowAtIndex:(NSInteger)index{
    
    if(taskCellHeight < 0){
        
        TaskCell *cell = (TaskCell *)[tableView cellViewFromNib:@"TaskCell" atViewIndex:0];
        
        taskCellHeight = cell.bounds.size.height;
    }
    
    return taskCellHeight;
}

- (CGFloat)tableView:(ParentTableView *)tableView subCellHeightForRowAtIndex:(NSInteger)index underParentIndex:(NSInteger)parentIndex{
    
    if(subTaskCellHeight < 0){
        
        SubTaskCell *cell = (SubTaskCell *)[tableView cellViewFromNib:@"SubTaskCell" atViewIndex:0];
        
        subTaskCellHeight = cell.bounds.size.height;
    }
    
    return subTaskCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView childCellHeightForRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    return 0;
}

- (BOOL)tableView:(ParentTableView *)tableView canExpandSubCellForRowAtIndex:(NSInteger)index{
    
    TaskItem *item = [_dataArray objectAtIndex:index];
    
    if(!item.isComplete)
        return YES;
    
    return NO;
}

- (void)tableView:(ParentTableView *)tableView willExpandForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex{
    
   }

- (void)tableView:(ParentTableView *)tableView willCollapseForParentCellAtIndex:(NSInteger)index withSubCellIndex:(NSInteger)subIndex{
    
    
}

- (void)tableViewWillEnterEditMode:(ParentTableView *)tableView{
    
    for(TaskCell *cell in tableView.visibleCells){
        
        if(cell != nil && [cell isKindOfClass:[TaskCell class]]){
            
            if(cell.parentIndex != tableView.lastExpandParentIndex)
                [cell setMaskEnable:YES];
            else
                [cell setMaskEnable:NO];
        }
    }
}

- (void)tableViewWillExitEditMode:(ParentTableView *)tableView{
    
    for(TaskCell *cell in tableView.visibleCells){
        
        if(cell != nil && [cell isKindOfClass:[TaskCell class]]){
            
            [cell setMaskEnable:NO];
        }
    }
}

#pragma mark - Internal
- (NSInteger)nonCompleteTaskCount{
    
    int retVal = 0;
    
    if(_dataArray != nil){
        
        for(TaskItem *item in _dataArray){
            
            if(!item.isComplete){
                
                retVal++;
            }
            else{
                
                break;
            }
        }
    }
    
    return retVal;
}

#pragma mark - PanleftRight delegate
//handle panning left
- (void)onPanningLeftWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index{
    
    TaskCell *cell = (TaskCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    
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
    
    TaskCell *cell = (TaskCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    
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
    
    [_dataArray removeObjectAtIndex:index];
    [_tableView deleteRowAtIndex:index withAnimation:UITableViewRowAnimationFade];
    
    //[_tableView reloadData];
    
    for(TaskCell *cell in _tableView.visibleCells){
        
        NSInteger index = [_tableView indexPathForCell:cell].row;
        
        if(!cell.isComplete)
            cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
    }
}

- (void)onPanRightAtCellIndex:(NSInteger)index{
    
    TaskItem *item = [_dataArray objectAtIndex:index];
    
    if(item.isComplete){
        
        NSLog(@"recover at index %li", (long)index);
        
        item.isComplete = NO;
        
        [_dataArray removeObjectAtIndex:index];
        
        [_dataArray insertObject:item atIndex:0];
        
        TaskCell *visualCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        visualCell.isComplete = NO;
        
        [_tableView moveRowAtIndex:index toIndex:0];
    }
    else{
        
        NSLog(@"complete at index %li", (long)index);
        
        id obj = [_dataArray objectAtIndex:index];
        ((TaskItem *)obj).isComplete = YES;
        [_dataArray removeObjectAtIndex:index];
        [_dataArray addObject:obj];
        
        TaskCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.isComplete = YES;
        
        
        [_tableView moveRowAtIndex:index toIndex:[_dataArray count]-1];
    }
    
    //[_tableView reloadData];
    
    for(TaskCell *cell in _tableView.visibleCells){
        
        NSInteger index = [_tableView indexPathForCell:cell].row;
        
        if(!cell.isComplete)
            cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
    }
}

#pragma mark - SingleTap delegate
- (void)onSingleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"on tap on index %li", (long)index);
    
}

#pragma mark - LongPressMove delegate
- (BOOL)canMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    TaskItem *item1 = [_dataArray objectAtIndex:fromIndex];
    TaskItem *item2 = [_dataArray objectAtIndex:toIndex];
    
    if(item1.isComplete == item2.isComplete)
        return YES;
    
    return NO;
}

- ( void)willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    [_dataArray exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
}

#pragma mark - PullDownAddNew delegate
- (void)addNewItemWithText:(NSString *)text{
    
    NSLog(@"add new item %@", text);
    [_dataArray insertObject:[TaskItem createTaskItemWithName:text] atIndex:0];
    
    [_tableView insertNewRowAtIndex:0 withAnimation:UITableViewRowAnimationTop];
    
    //[_tableView reloadData];
    
    for(TaskCell *cell in _tableView.visibleCells){
        
        NSInteger index = [_tableView indexPathForCell:cell].row;
        
        if(!cell.isComplete)
            cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
    }
}

#pragma mark - DoubleTapEdit delegate
- (BOOL)canStartEditAtIndex:(NSInteger)index{
    
    TaskItem *item = [_dataArray objectAtIndex:index];
    
    return !item.isComplete;
}
- (NSString *)nameForItemAtIndex:(NSInteger)index{
    
    return ((TaskItem *)[_dataArray objectAtIndex:index]).taskItemName;
}

- (void)onDoubleTapEditCompleteAtIndex:(NSInteger)index withItemName:(NSString *)name{
    
    TaskItem *item = [_dataArray objectAtIndex:index];
    item.taskItemName = name;
    
    TaskCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
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
