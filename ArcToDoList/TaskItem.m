//
//  TaskItem.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskItem.h"

@implementation TaskItem

@synthesize taskItemName = _taskItemName;
@synthesize isComplete = _isComplete;

+ (id)createTaskItemWithName:(NSString *)name{
    
    TaskItem *item = [[TaskItem alloc] init];
    
    item.taskItemName = name;
    
    return item;
}

@end
