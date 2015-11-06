//
//  SubTaskCell.m
//  ArcToDoList
//
//  Created by User on 4/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "SubTaskCell.h"

@implementation SubTaskCell

@synthesize theDelegate = _theDelegate;

- (IBAction)onNotificationTap:(id)sender{
    
    NSLog(@"notification tap %li", self.parentIndex);
}

- (IBAction)onNoteTap:(id)sender{
    
    NSLog(@"note tap %li", self.parentIndex);
}

- (IBAction)onAttachmentTap:(id)sender{
    
    NSLog(@"attachment tap %li", self.parentIndex);
}

- (IBAction)onCatagorizeTap:(id)sender{
    
    NSLog(@"change tap %li", self.parentIndex);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
