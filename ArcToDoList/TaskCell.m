//
//  TaskCell.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

@synthesize titleLabel = _titleLabel;

- (void)setIsComplete:(BOOL)isComplete{
    
    if(isComplete){
        
        self.backgroundColor = self.completeColor;
    }
    else{
        
        self.backgroundColor = self.notCompleteColor;
    }
    
    _isComplete = isComplete;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
