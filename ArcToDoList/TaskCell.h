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
@property (strong, nonatomic) IBInspectable UIColor *completeColor;
@property (strong, nonatomic) IBInspectable UIColor *notCompleteColor;


@end
