//
//  CategoryCell.m
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

@synthesize titleLabel = _titleLabel;
@synthesize completeLabel = _completeLabel;
@synthesize deleteLabel = _deleteLabel;
@synthesize colorView = _colorView;
@synthesize numberLabel = _numberLabel;
@synthesize isComplete = _isComplete;

- (void)awakeFromNib{
    
    _completeLabel.text = @"\u2713";
    _deleteLabel.text = @"\u2717";
    
    
}

- (void)setIsComplete:(BOOL)isComplete{
    
    if(isComplete){
        
        self.backgroundColor = self.completeColor;
        _completeLabel.text = @"\u238b";
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
