//
//  CategoryCell.h
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface CategoryCell : ParentTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (assign, nonatomic) BOOL isComplete;
@property (strong, nonatomic) IBInspectable UIColor *completeColor;
@property (strong, nonatomic) IBInspectable UIColor *notCompleteColor;
@property (strong, nonatomic) IBInspectable UIColor *startColorMark;

@end
