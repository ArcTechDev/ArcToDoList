//
//  TaskCell.m
//  ArcToDoList
//
//  Created by User on 3/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "TaskCell.h"

@interface TaskCell ()

@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

@implementation TaskCell{
    
    BOOL _maskEnabled;
}

@synthesize maskView = _maskView;

- (void)awakeFromNib{
    
    _maskEnabled = NO;
    _maskView.hidden = YES;
    
    self.completeLabel.text = @"\u2713";
    self.deleteLabel.text = @"\u2717";
}

- (void)setIsComplete:(BOOL)isComplete{
    
    if(isComplete){
        
        self.completeLabel.text = @"\u238b";
        self.titleLabel.textColor = self.completeTextColor;
    }
    else{
        
        self.backgroundColor = self.notCompleteBackgroundColor;
    }
    
    _isComplete = isComplete;
}

- (void)setMaskEnable:(BOOL)yesOrNo{
    
    _maskEnabled = yesOrNo;
    
    if(_maskEnabled){
        
        _maskView.hidden = NO;
    }
    else{
        
        _maskView.hidden = YES;
    }
}

- (void)prepareForReuse{
    
    [self setMaskEnable:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
