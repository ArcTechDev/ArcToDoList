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
}

@synthesize dayPicker = _dayPicker;
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    taskCellHeight = -1;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<20; i++){
        
        [_dataArray addObject:[TaskItem createTaskItemWithName:[NSString stringWithFormat:@"Task%i", i]]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
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
    
    UIColor *startColor = cell.startColorMark;
    UIColor *endColor = cell.endColorMark;
    float r,g,b,a;
    const CGFloat *startColorComponent = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endColorComponent = CGColorGetComponents(endColor.CGColor);
    
    r = startColorComponent[0] + ((endColorComponent[0] - startColorComponent[0])/_dataArray.count) * index;
    g = startColorComponent[1] + ((endColorComponent[1]  - startColorComponent[1])/_dataArray.count) * index;
    b = startColorComponent[2] + ((endColorComponent[2]  - startColorComponent[2])/_dataArray.count) * index;
    a = startColorComponent[3];
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    cell.titleLabel.textColor = color;
    
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
    
    if(taskCellHeight < 0){
        
        TaskCell *cell = (TaskCell *)[tableView cellViewFromNib:@"TaskCell" atViewIndex:0];
        
        taskCellHeight = cell.bounds.size.height;
    }
    
    return taskCellHeight;
}

- (CGFloat)tableView:(ParentTableView *)tableView subCellHeightForRowAtIndex:(NSInteger)index underParentIndex:(NSInteger)parentIndex{
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView childCellHeightForRowAtChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex{
    
    return 0;
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
