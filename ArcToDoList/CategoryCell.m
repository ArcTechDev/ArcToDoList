//
//  CategoryCell.m
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

@synthesize colorView = _colorView;
@synthesize numberLabel = _numberLabel;
@synthesize isComplete = _isComplete;

- (void)awakeFromNib{
    
    self.completeLabel.text = @"\u2713";
    self.deleteLabel.text = @"\u2717";
    
    
}

- (void)setIsComplete:(BOOL)isComplete{
    
    if(isComplete){
        
        self.completeLabel.text = @"\u238b";
    }
    else{
        
        self.backgroundColor = self.notCompleteBackgroundColor;
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
