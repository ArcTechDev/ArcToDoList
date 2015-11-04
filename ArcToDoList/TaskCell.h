//
//  TaskCell.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"
#import "GenericCell.h"

@interface TaskCell : GenericCell

@property (assign, nonatomic) BOOL isComplete;

@property (strong, nonatomic) IBInspectable UIColor *completeBackgroundColor;
@property (strong, nonatomic) IBInspectable UIColor *notCompleteBackgroundColor;
@property (strong, nonatomic) IBInspectable UIColor *completeTextColor;


@end
