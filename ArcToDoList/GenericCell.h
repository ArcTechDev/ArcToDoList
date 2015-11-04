//
//  GenericCell.h
//  ArcToDoList
//
//  Created by User on 4/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ParentTableViewCell.h"

@interface GenericCell : ParentTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;

@property (strong, nonatomic) IBInspectable UIColor *startColorMark;
@property (strong, nonatomic) IBInspectable UIColor *endColorMark;

@end
