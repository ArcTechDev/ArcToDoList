//
//  TaskCell.h
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface TaskCell : ParentTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (assign, nonatomic) BOOL isComplete;
@property (strong, nonatomic) IBInspectable UIColor *completeColor;
@property (strong, nonatomic) IBInspectable UIColor *notCompleteColor;
@property (strong, nonatomic) IBInspectable UIColor *startColorMark;
@property (strong, nonatomic) IBInspectable UIColor *endColorMark;

@end
