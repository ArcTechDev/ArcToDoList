//
//  TaskViewController.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"
#import "MZDayPicker.h"
#import "ParentTableView.h"
#import "TaskItem.h"
#import "TaskCell.h"
#import "PanLeftRight.h"
#import "SingleTap.h"
#import "DoubleTapEdit.h"
#import "PullDownAddNew.h"
#import "LongPressMove.h"

@interface TaskViewController : UIViewController<MZDayPickerDataSource, MZDayPickerDelegate, ParentTableViewDelegate, PanLeftRightDelegate, SingleTapDelegate, DoubleTapEditDelegate, PullDownAddNewDelegate, LongPressMoveDelegate>

@end
