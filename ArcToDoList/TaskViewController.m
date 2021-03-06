//
//  TaskViewController.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskViewController.h"
#import "DateHelper.h"
#import "ServerInterface.h"
#import "NotificationSettingViewController.h"

@interface TaskViewController ()

@property (weak, nonatomic) IBOutlet MZDayPicker *dayPicker;
@property (weak, nonatomic) IBOutlet ParentTableView *tableView;

@end

@implementation TaskViewController{
    
    NSMutableDictionary *dateOfTask;
    NSString *pickedDate;
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
    
    dateOfTask = [[NSMutableDictionary alloc] init];
    
    pickedDate = [DateHelper stringFromDate:[NSDate date] withFormate:DateFormateString];
    
    /*
    for(int i=0; i<20; i++){
        
        [_dataArray addObject:[TaskItem createTaskItemWithName:[NSString stringWithFormat:@"Task%i", i]]];
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
    
    [[ServerInterface sharedInstance] loadTaskItemUnderCategoryItem:_underCategoryItemId withDate:pickedDate complete:^(NSDictionary *values, NSString *queryDate) {
        
        
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        
        for(NSString *key in values.allKeys){
            
            TaskItem *item = [TaskItem createTaskItemWithName:values[key][FPTaskItemName] withDate:[DateHelper dateFromString:values[key][FPTaskItemDate] withFormate:DateFormateString]];
            item.itemId = key;
            item.isComplete = [values[key][FPTaskItemComplete] boolValue];
            item.priority = [values[key][FPTaskItemPriority] integerValue];
            
            [tasks addObject:item];
        }
        
        dateOfTask[queryDate] = tasks;
        
        [self sortTaskUnderDate:queryDate];
        
        [_tableView reloadTableData];
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to load task items");
    }];
    
    [self startListeningEvent];
    
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

- (void)dealloc{
    
    [[[ServerInterface sharedInstance] refTaskItemsUnderCategoryItem:_underCategoryItemId] removeAllObservers];
    [[[ServerInterface sharedInstance] refCategoryItemUnderTasks] removeAllObservers];
}

#pragma mark - Firebase listener
- (void)startListeningEvent{
    
    //Listen child added event
    [[[ServerInterface sharedInstance] refTaskItemsUnderCategoryItem:_underCategoryItemId] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            NSString *date = snapshot.value[FPTaskItemDate];
            NSMutableArray *tasks = dateOfTask[date];
            
            if(tasks == nil){
                
                tasks = [[NSMutableArray alloc] init];
                dateOfTask[date] = tasks;
            }
            
            for(TaskItem *task in tasks){
                
                if([task.itemId isEqualToString:snapshot.key])
                    return;
            }
            
            NSLog(@"child added event new value added key:%@, value:%@", snapshot.key, snapshot.value);
            
            
            TaskItem *item = [TaskItem createTaskItemWithName:snapshot.value[FPTaskItemName] withDate:[DateHelper dateFromString:snapshot.value[FPTaskItemDate] withFormate:DateFormateString]];
            item.itemId = [snapshot.key copy];
            
            [tasks insertObject:item atIndex:0];
            
            //we dont insert into table view when selected date is not equal to data's date
            if(![ pickedDate isEqualToString:date])
                return;
            
            [_tableView insertNewRowAtIndex:0 withAnimation:UITableViewRowAnimationTop];
            
            for(TaskCell *cell in _tableView.visibleCells){
                
                NSInteger index = [_tableView indexPathForCell:cell].row;
                
                if(!cell.isComplete)
                    cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Listen to child added event error:%@", error);
    }];
    
    //Listen child delete event
    [[[ServerInterface sharedInstance] refTaskItemsUnderCategoryItem:_underCategoryItemId] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            NSUInteger index = 0;
            BOOL shouldRemove = NO;
            NSString *date = snapshot.value[FPTaskItemDate];
            
            NSMutableArray *tasks = dateOfTask[date];
            
            for(TaskItem *item in tasks){
                
                if([item.itemId isEqualToString:snapshot.key]){
                    
                    index = [tasks indexOfObject:item];
                    shouldRemove = YES;
                    break;
                }
            }
            
            if(shouldRemove){
                
                [tasks removeObjectAtIndex:index];
                
                if([pickedDate isEqualToString:date]){
                    
                    [_tableView deleteRowAtIndex:index withAnimation:UITableViewRowAnimationFade];
                    
                    for(TaskCell *cell in _tableView.visibleCells){
                        
                        NSInteger index = [_tableView indexPathForCell:cell].row;
                        
                        if(!cell.isComplete)
                            cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
                    }
                }
                
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Listen to child delete event error:%@", error);
    }];
    
    //Listen child change event
    [[[ServerInterface sharedInstance] refTaskItemsUnderCategoryItem:_underCategoryItemId] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            NSString *date = snapshot.value[FPTaskItemDate];
            NSMutableArray *tasks = dateOfTask[date];
            
            for(TaskItem *item in tasks){
                
                if([item.itemId isEqualToString:snapshot.key]){
                    
                    item.taskItemName = [((NSDictionary *)snapshot.value)[FPTaskItemName] copy];
                    item.isComplete = [snapshot.value[FPTaskItemComplete] boolValue];
                    item.date = [DateHelper dateFromString:snapshot.value[FPTaskItemDate] withFormate:DateFormateString];
                    item.priority = [snapshot.value[FPTaskItemPriority] integerValue];
                    
                    [self sortTaskUnderDate:date];
                    
                    if([date isEqualToString:pickedDate]){
                        
                        NSUInteger index = [tasks indexOfObject:item];
                        
                        TaskCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                        
                        cell.titleLabel.text = item.taskItemName;
                        cell.isComplete = item.isComplete;
                        
                        [_tableView reloadTableData];
                    }
                    
                    break;
                }

            }
            
            
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Listen to child change event error:%@", error);
    }];
    
    //Listen category item delete event
    [[[ServerInterface sharedInstance] refCategoryItems] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if([snapshot.key isEqualToString:_underCategoryItemId]){
           
            if(self.navigationController){
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"All data that are under this category item has been removed! \n you will return to category items" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }];
                
                [alertController addAction:confirmAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        
    }];
}

#pragma mark - setup day picker
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
    
    if(dateOfTask == nil)
        return 0;
    
    NSMutableArray*tasks = dateOfTask[pickedDate];
    
    if(tasks == nil)
        return 0;
    
    return tasks.count;
}


- (UITableViewCell *)tableView:(ParentTableView *)tableView parentCellForRowAtIndex:(NSInteger)index{
    
    static NSString *taskCellId = @"TaskCell";
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellId];
    
    if(cell == nil){
        
        cell = (TaskCell *)[tableView cellViewFromNib:@"TaskCell" atViewIndex:0];
    }
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *item = [tasks objectAtIndex:index];
    
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
    
    cell.theDelegate = self;
    
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
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *item = [tasks objectAtIndex:index];
    
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
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    if(tasks != nil){
        
        for(TaskItem *item in tasks){
            
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

- (void)sortTaskUnderDate:(NSString *)date{
    
    NSMutableArray *tasks = dateOfTask[date];
    
    if(tasks == nil || tasks.count <= 0)
        return;
        
    [tasks sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        TaskItem *item1 = obj1;
        TaskItem *item2 = obj2;
        
        if(item1.priority > item2.priority)
            return NSOrderedDescending;
        else if(item1.priority < item2.priority)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
    }];
}

#pragma mark - SubTaskCell delegate
- (void)onNotificationForTaskIndex:(NSInteger)taskIndex{
    
    NSArray *tasks = dateOfTask[pickedDate];
    TaskItem *task = tasks[taskIndex];
    
    NotificationSettingViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSetting"];
    controller.task = task;
    controller.categoryId = _underCategoryItemId;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onNoteForTaskIndex:(NSInteger)taskIndex{
    
}

- (void)onAttachmentForTaskIndex:(NSInteger)taskIndex{
    
}

- (void)onCatagorizeForTaskIndex:(NSInteger)taskIndex{
    
}

#pragma mark - MZDayPicker delegate
- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day{
    
    pickedDate = [DateHelper stringFromDate:dayPicker.currentDate withFormate:DateFormateString];
    
    NSMutableArray *data = dateOfTask[pickedDate];
    
    if(data != nil){
        
        [_tableView reloadTableData];
        return;
    }
    
    
    [[ServerInterface sharedInstance] loadTaskItemUnderCategoryItem:_underCategoryItemId withDate:pickedDate complete:^(NSDictionary *values, NSString *queryDate) {
        
        NSMutableArray *tasks = dateOfTask[queryDate];
        
        if(tasks == nil)
            tasks = [[NSMutableArray alloc] init];
        
        for(NSString *key in values.allKeys){
            
            TaskItem *item = [TaskItem createTaskItemWithName:values[key][FPTaskItemName] withDate:[DateHelper dateFromString:values[key][FPTaskItemDate] withFormate:DateFormateString]];
            
            item.itemId = key;
            item.isComplete = [values[key][FPTaskItemComplete] boolValue];
            item.priority = [values[key][FPTaskItemPriority] integerValue];
            
            [tasks addObject:item];
        }
        
        dateOfTask[queryDate] = tasks;
        
        [self sortTaskUnderDate:queryDate];
        
        if([pickedDate isEqualToString:queryDate])
            [_tableView reloadTableData];
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to load task items");
    }];
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
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *task = [tasks objectAtIndex:index];
    
    NSString *sortDate = pickedDate;
    
    [[ServerInterface sharedInstance] deleteTaskItemUnderCategoryItemId:_underCategoryItemId withTaskId:task.itemId withDate:[DateHelper stringFromDate:task.date withFormate:DateFormateString] onComplete:^(NSString *taskId, NSString *date) {
        
        NSLog(@"delete task %@, %@", taskId, date);
        
        [self sortTaskUnderDate:sortDate];
        
        for(int i=0; i<tasks.count; i++){
            
            ((TaskItem *)tasks[i]).priority = i;
        }
        
        NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
        
        for(NSInteger i = 0; i < tasks.count; i++){
            
            TaskItem *item = [tasks objectAtIndex:i];
            
            [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
            
        }
        
        [[ServerInterface sharedInstance] updateTaskItemPriority:dic underCategoryItemId:_underCategoryItemId complete:^{
            
            
        } fail:^(NSError *error) {
            
            NSLog(@"unable to update task item after delete an task item");
        }];
        
        
    } fail:^(NSError *error) {
        
        NSLog(@"delete task fail");
    }];

}

- (void)onPanRightAtCellIndex:(NSInteger)index{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    NSString *datePicked = pickedDate;
    
    TaskItem *item = [tasks objectAtIndex:index];
    
    if(item.isComplete){
        
        NSLog(@"recover at index %li", (long)index);
        
        item.isComplete = NO;
        
        TaskCell *visualCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        visualCell.isComplete = NO;
        
        
        
        
        
        [[ServerInterface sharedInstance] changeTaskItemCompleteStateWithTaskId:item.itemId withState:NO underCategoryItemId:_underCategoryItemId complete:^(NSString *taskId) {
            
            [tasks removeObjectAtIndex:index];
            
            [tasks insertObject:item atIndex:0];
            
            
            for(int i=0; i<tasks.count; i++){
                
                ((TaskItem *)tasks[i]).priority = i;
            }
            
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            
            for(NSInteger i = 0; i < tasks.count; i++){
                
                TaskItem *item = [tasks objectAtIndex:i];
                
                [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
                
            }
            
            if([datePicked isEqualToString:pickedDate]){
                
                [_tableView moveRowAtIndex:index toIndex:0 onComplete:nil];
                
                for(TaskCell *cell in _tableView.visibleCells){
                    
                    NSInteger index = [_tableView indexPathForCell:cell].row;
                    
                    if(!cell.isComplete)
                        cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
                }

            }
            
            [[ServerInterface sharedInstance] updateTaskItemPriority:dic underCategoryItemId:_underCategoryItemId complete:^{
                
                
            } fail:^(NSError *error) {
                
                NSLog(@"unable to update task priority");
            }];
            
            
        } fail:^(NSError *error) {
            
            NSLog(@"unable to change task completion state %@", item.itemId);
        }];
        
        
    }
    else{
        
        NSLog(@"complete at index %li", (long)index);
        
        TaskItem *item = [tasks objectAtIndex:index];
        item.isComplete = YES;
        
        TaskCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.isComplete = YES;
        
        
        
        
        
        [[ServerInterface sharedInstance] changeTaskItemCompleteStateWithTaskId:item.itemId withState:YES underCategoryItemId:_underCategoryItemId complete:^(NSString *taskId) {
            
            [tasks removeObjectAtIndex:index];
            [tasks addObject:item];
            
            for(int i=0; i<tasks.count; i++){
                
                ((TaskItem *)tasks[i]).priority = i;
            }
            
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            
            for(NSInteger i = 0; i < tasks.count; i++){
                
                TaskItem *item = [tasks objectAtIndex:i];
                
                [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
                
            }
            
            if([datePicked isEqualToString:pickedDate]){
                
                [_tableView moveRowAtIndex:index toIndex:[tasks count]-1 onComplete:nil];
                
                for(TaskCell *cell in _tableView.visibleCells){
                    
                    NSInteger index = [_tableView indexPathForCell:cell].row;
                    
                    if(!cell.isComplete)
                        cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
                }
            }
            
            
            [[ServerInterface sharedInstance] updateTaskItemPriority:dic underCategoryItemId:_underCategoryItemId complete:^{
                
                
            } fail:^(NSError *error) {
                
                NSLog(@"unable to update task priority");
            }];

            
        } fail:^(NSError *error) {
           
            NSLog(@"unable to change task completion state %@", item.itemId);
        }];
        
    }
    
    /*
    //[_tableView reloadData];
    
    for(TaskCell *cell in _tableView.visibleCells){
        
        NSInteger index = [_tableView indexPathForCell:cell].row;
        
        if(!cell.isComplete)
            cell.titleLabel.textColor = [Helper transitColorForItemAtIndex:index totalItemCount:[self nonCompleteTaskCount] startColor:cell.startColorMark endColor:cell.endColorMark];
    }
    */
}

#pragma mark - SingleTap delegate
- (void)onSingleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"on tap on index %li", (long)index);
    
}

#pragma mark - LongPressMove delegate
- (BOOL)canMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *item1 = [tasks objectAtIndex:fromIndex];
    TaskItem *item2 = [tasks objectAtIndex:toIndex];
    
    if(item1.isComplete == item2.isComplete)
        return YES;
    
    return NO;
}

- ( void)willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    //swap priority
    TaskItem *item1 = [tasks objectAtIndex:fromIndex];
    TaskItem *item2 = [tasks objectAtIndex:toIndex];
    
    NSInteger tempPriority = item1.priority;
    item1.priority = item2.priority;
    item2.priority = tempPriority;
    
    [tasks exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
}

- (void)didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    if(fromIndex == toIndex)
        return;
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < tasks.count; i++){
        
        TaskItem *item = [tasks objectAtIndex:i];
        
        [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
        
    }
    
    
    [[ServerInterface sharedInstance] updateTaskItemPriority:dic underCategoryItemId:_underCategoryItemId complete:^{
        
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to update task item priority");
    }];
}

#pragma mark - PullDownAddNew delegate
- (void)addNewItemWithText:(NSString *)text{
    
    [self sortTaskUnderDate:pickedDate];
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    for(TaskItem *item in tasks){
        
        item.priority += 1;
    }
    
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    
    
    for(NSInteger i = 0; i < tasks.count; i++){
        
        TaskItem *item = [tasks objectAtIndex:i];
        
        [dic setValue:[NSNumber numberWithInteger:item.priority] forKey:item.itemId];
        
    }
    
    [[ServerInterface sharedInstance] updateTaskItemPriority:dic underCategoryItemId:_underCategoryItemId complete:^{
       
        [[ServerInterface sharedInstance] addTaskItemUnderCategoryItemId:_underCategoryItemId withText:text withDate:pickedDate onComplete:^(NSString *taskId, NSString *text, NSString *date) {
            
            NSLog(@"add new task %@, %@, %@", taskId, text, date);
            
        } fail:^(NSError *error) {
            
            NSLog(@"unable to add task server error:%@", error);
        }];
        
    } fail:^(NSError *error) {
        
        NSLog(@"unable to update task item priority");
    }];
    
    
    
}

#pragma mark - DoubleTapEdit delegate
- (BOOL)canStartEditAtIndex:(NSInteger)index{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *item = [tasks objectAtIndex:index];
    
    return !item.isComplete;
}
- (NSString *)nameForItemAtIndex:(NSInteger)index{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    return ((TaskItem *)[tasks objectAtIndex:index]).taskItemName;
}

- (void)onDoubleTapEditCompleteAtIndex:(NSInteger)index withItemName:(NSString *)name{
    
    NSMutableArray *tasks = dateOfTask[pickedDate];
    
    TaskItem *item = [tasks objectAtIndex:index];
    
    [[ServerInterface sharedInstance] modifyTaskItemUnderCatergoryItemId:_underCategoryItemId withTaskId:item.itemId withText:name withDate:[DateHelper stringFromDate:item.date withFormate:DateFormateString] onComplete:^(NSString *taskId, NSString *date, NSString *text) {
        
        NSLog(@"edit task name %@, %@, %@", taskId, date, text);
        
    } fail:^(NSError *error) {
        
        NSLog(@"edit task name fail");
    }];
    
    /*
    item.taskItemName = name;
    
    TaskCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
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
