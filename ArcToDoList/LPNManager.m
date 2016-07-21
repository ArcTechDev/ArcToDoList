//
//  LPNManager.m
//  ArcToDoList
//
//  Created by User on 20/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import "LPNManager.h"
#import "DateHelper.h"

@implementation LPNManager{
    
    __weak UIApplication *sharedApp;
}

static LPNManager *_instance;

+ (instancetype)sharedManager{
    
    if(_instance == nil)
        _instance = [[LPNManager alloc] init];
    
    return _instance;
}

- (id)init{
    
    if(self = [super init]){
        
        sharedApp = [UIApplication sharedApplication];
        
    }
    
    return self;
}

- (void)scheduleLocalNotificationForTaskId:(NSString *)taskId underCategoryItemId:(NSString *)catId withScheduleDate:(NSDate *)scheduleDate withDateFormate:(NSString *)dateFormate withAlertTitle:(NSString *)title withAlertBody:(NSString *)body onScheduleComplete:(void(^)(UILocalNotification *notification))complete fail:(void(^)(NSError *error))fail{
    
    [self getScheduledLocalNotificationForTaskId:taskId onComplete:^(UILocalNotification *notification) {
        
        if(notification == nil){
            
            UIUserNotificationType types = UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [sharedApp registerUserNotificationSettings:notificationSettings];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            notification.alertTitle = title;
            notification.alertBody = body;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.fireDate = scheduleDate;
            notification.timeZone = [NSTimeZone localTimeZone];

            
            NSDictionary *userInfo = @{LPN_TaskID:taskId, LPN_CategoryID:catId, LPN_ScheduledDate:[DateHelper stringFromDate:scheduleDate withFormate:dateFormate]};
            
            notification.userInfo = userInfo;
            
            
            [sharedApp scheduleLocalNotification:notification];
            
            NSLog(@"Schedule notification to date time %@", [scheduleDate descriptionWithLocale:[NSLocale currentLocale]]);
            
            complete(notification);
            
            return;
        }
        
        fail([NSError errorWithDomain:[NSString stringWithFormat:@"Task id %@ already scheduled a notification", taskId] code:-1 userInfo:nil]);
           
    }];
    
}

- (void)removeScheduledLocalNotificationWithTaskId:(NSString *)taskId onComplete:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    [self getScheduledLocalNotificationForTaskId:taskId onComplete:^(UILocalNotification *notification) {
       
        if(notification != nil){
            
            [sharedApp cancelLocalNotification:notification];
            
            complete();
            
            return;
        }
        
        fail([NSError errorWithDomain:@"Notification for task does not exist" code:-1 userInfo:nil]);
    }];
}

- (void)removeAllScheduledLocalNotificationUnderCategoryItemId:(NSString *)catId onComplete:(void(^)(void))complete{
    
    NSArray *notifications = [sharedApp scheduledLocalNotifications];
    
    NSMutableArray *removedNotifications = [[NSMutableArray alloc] init];
    
    for(UILocalNotification *no in notifications){
        
        NSString *nCatId = no.userInfo[LPN_CategoryID];
        
        if([nCatId isEqualToString:catId])
            [removedNotifications addObject:no];
    }
    
    if(removedNotifications.count > 0){
        
        for(UILocalNotification *no in removedNotifications){
            
            [sharedApp cancelLocalNotification:no];
        }
    }
    
    complete();
}

- (void)getScheduledLocalNotificationForTaskId:(NSString *)taskId onComplete:(void(^)(UILocalNotification *notification))complete{
    
    NSArray *notifications = [sharedApp scheduledLocalNotifications];
    
    for(UILocalNotification *no in notifications){
        
        NSString *nTaskId = no.userInfo[LPN_TaskID];
        
        if([nTaskId isEqualToString:taskId]){
            complete(no);
            return;
        }
    }
    
    complete(nil);
}

@end
