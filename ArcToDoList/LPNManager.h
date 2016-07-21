//
//  LPNManager.h
//  ArcToDoList
//
//  Created by User on 20/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LPN_TaskID @"TaskId"
#define LPN_CategoryID @"CatId"
#define LPN_ScheduledDate @"ScheduleDate"

@interface LPNManager : NSObject

+ (instancetype)sharedManager;

- (void)scheduleLocalNotificationForTaskId:(NSString *)taskId underCategoryItemId:(NSString *)catId withScheduleDate:(NSDate *)scheduleDate withDateFormate:(NSString *)dateFormate withAlertTitle:(NSString *)title withAlertBody:(NSString *)body onScheduleComplete:(void(^)(UILocalNotification *notification))complete fail:(void(^)(NSError *error))fail;
- (void)removeScheduledLocalNotificationWithTaskId:(NSString *)taskId onComplete:(void(^)(void))complete fail:(void(^)(NSError *error))fail;
- (void)removeAllScheduledLocalNotificationUnderCategoryItemId:(NSString *)catId onComplete:(void(^)(void))complete;
- (void)getScheduledLocalNotificationForTaskId:(NSString *)taskId onComplete:(void(^)(UILocalNotification *notification))complete;

@end
