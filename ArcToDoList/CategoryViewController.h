//
//  CategoryViewController.h
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Helper.h"
#import "ParentTableView.h"
#import "PanLeftRight.h"
#import "SingleTap.h"
#import "DoubleTapEdit.h"
#import "PullDownAddNew.h"
#import "LongPressMove.h"

@interface CategoryViewController : UIViewController<ParentTableViewDelegate, PanLeftRightDelegate, SingleTapDelegate, DoubleTapEditDelegate, PullDownAddNewDelegate, LongPressMoveDelegate>

@end
