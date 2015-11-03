//
//  TaskViewController.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZDayPicker.h"
#import "ParentTableView.h"
#import "TaskItem.h"
#import "TaskCell.h"

@interface TaskViewController : UIViewController<MZDayPickerDataSource, MZDayPickerDelegate, ParentTableViewDelegate>

@end
