//
//  NotificationSettingViewController.h
//  ArcToDoList
//
//  Created by User on 20/7/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskItem.h"

@interface NotificationSettingViewController : UIViewController

@property (weak, nonatomic) TaskItem *task;
@property (copy, nonatomic) NSString *categoryId;

@end
