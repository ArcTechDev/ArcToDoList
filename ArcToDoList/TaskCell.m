//
//  TaskCell.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell


- (void)awakeFromNib{
    
    self.completeLabel.text = @"\u2713";
    self.deleteLabel.text = @"\u2717";
    
    
}

- (void)setIsComplete:(BOOL)isComplete{
    
    if(isComplete){
        
        self.completeLabel.text = @"\u238b";
        self.titleLabel.textColor = [UIColor grayColor];
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
