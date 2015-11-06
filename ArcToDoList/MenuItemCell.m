//
//  MenuItemCell.m
//  ArcToDoList
//
//  Created by User on 6/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "MenuItemCell.h"

@implementation MenuItemCell

@synthesize titleLabel = _titleLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
