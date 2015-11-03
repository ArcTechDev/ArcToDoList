//
//  TaskItem.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskItem : NSObject

@property (copy, nonatomic) NSString *taskItemName;
@property (assign, nonatomic) BOOL isComplete;

+ (id)createTaskItemWithName:(NSString *)name;

@end
