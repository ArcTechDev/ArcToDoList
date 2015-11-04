//
//  CategoryCell.h
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"
#import "GenericCell.h"

@interface CategoryCell : GenericCell

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (assign, nonatomic) BOOL isComplete;
@property (strong, nonatomic) IBInspectable UIColor *completeBackgroundColor;
@property (strong, nonatomic) IBInspectable UIColor *notCompleteBackgroundColor;

@end
