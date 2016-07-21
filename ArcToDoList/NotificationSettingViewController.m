//
//  NotificationSettingViewController.m
//  ArcToDoList
//
//  Created by User on 20/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import "NotificationSettingViewController.h"
#import "LPNManager.h"
#import "DateHelper.h"

@interface NotificationSettingViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitcher;

@end

@implementation NotificationSettingViewController{
    
    BOOL canControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    canControl = NO;
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.minimumDate = [NSDate date];
    _datePicker.timeZone = [NSTimeZone localTimeZone];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    [[LPNManager sharedManager] getScheduledLocalNotificationForTaskId:_task.itemId onComplete:^(UILocalNotification *notification) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(notification != nil){
                
                _notificationSwitcher.on = YES;
                
                [_datePicker setDate:[DateHelper dateFromString:notification.userInfo[LPN_ScheduledDate] withFormate:DateTimeFormateString] animated:YES];
                
            }
            else{
                
                _notificationSwitcher.on = NO;
                
                _datePicker.date = [NSDate date];
            }
            
            canControl = YES;
        });
        
    }];
    
}

- (void)scheduleNotification{
    
    [[LPNManager sharedManager] scheduleLocalNotificationForTaskId:_task.itemId underCategoryItemId:_categoryId withScheduleDate:_datePicker.date withDateFormate:DateTimeFormateString withAlertTitle:@"Task notification" withAlertBody:[NSString stringWithFormat:@"You have a task need to do %@", _task.taskItemName] onScheduleComplete:^(UILocalNotification *notification) {
        
        NSLog(@"notification has been scheduled");
        
    } fail:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
}

- (IBAction)notificationStateChanged:(id)sender{
    
    if(!canControl)
        return;
        
    UISwitch *switcher = sender;
    
    if(switcher.on){
        
        [self scheduleNotification];
    }
    else{
        
        [[LPNManager sharedManager] removeScheduledLocalNotificationWithTaskId:_task.itemId onComplete:^{
            
        } fail:^(NSError *error) {
            
            NSLog(@"%@", error);
        }];
    }
}

- (IBAction)notificationDateChanged:(id)sender{
    
    if(!canControl)
        return;
    
    if(_notificationSwitcher.on){
        
        [[LPNManager sharedManager] removeScheduledLocalNotificationWithTaskId:_task.itemId onComplete:^{
            
            [self scheduleNotification];
            
        } fail:^(NSError *error) {
            
            NSLog(@"%@", error);
        }];
    }
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
