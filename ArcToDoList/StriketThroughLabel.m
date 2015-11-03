//
//  StriketThroughLabel.m
//  ArcToDoList
//
//  Created by User on 24/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "StriketThroughLabel.h"

@implementation StriketThroughLabel{
    
    BOOL isStriketThrough;
    BOOL setup;
    CALayer *striketThroughLayer;
    
}

const float STRIKEOUT_THICKNESS = 2.0f;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if(!setup){
        
        striketThroughLayer = [CALayer layer];
        striketThroughLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        striketThroughLayer.hidden = YES;
        [self.layer addSublayer:striketThroughLayer];
        
        setup = YES;
    }
    
    [self resizeStrikeThrough];
}

-(void)resizeStrikeThrough {
    
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    striketThroughLayer.frame = CGRectMake(0, self.bounds.size.height/2,
                                           textSize.width, STRIKEOUT_THICKNESS);
}

#pragma mark - property setter
-(void)setStrikethrough:(BOOL)strikethrough {
    isStriketThrough = strikethrough;
    striketThroughLayer.hidden = !strikethrough;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
