//
//  ChildTableViewCell.m
//  SubTableView
//
//  Created by User on 26/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ChildTableViewCell.h"

@implementation ChildTableViewCell

@synthesize parentIndex = _parentIndex;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
