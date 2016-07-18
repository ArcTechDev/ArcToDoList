//
//  TaskItem.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskItem : NSObject

@property (copy, nonatomic) NSString *itemId;
@property (copy, nonatomic) NSString *taskItemName;
@property (assign, nonatomic) BOOL isComplete;
@property (nonatomic) NSDate *date;
@property (assign, nonatomic) NSInteger priority;

+ (id)createTaskItemWithName:(NSString *)name;
+ (id)createTaskItemWithName:(NSString *)name withDate:(NSDate *)date;
- (NSString *)stringOfDate;

@end
