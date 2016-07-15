//
//  TaskItem.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskItem.h"
#import "DateHelper.h"

@implementation TaskItem

@synthesize itemId = _itemId;
@synthesize taskItemName = _taskItemName;
@synthesize isComplete = _isComplete;
@synthesize date = _date;

+ (id)createTaskItemWithName:(NSString *)name{
    
    TaskItem *item = [[TaskItem alloc] init];
    
    item.taskItemName = name;
    
    return item;
}

+ (id)createTaskItemWithName:(NSString *)name withDate:(NSDate *)date{
    
    TaskItem *item = [[TaskItem alloc] init];
    
    item.taskItemName = name;
    item.date = date;
    
    return item;
}

- (NSString *)stringOfDate{
    
    return [DateHelper stringFromDate:_date withFormate:DateFormateString];
}

@end
