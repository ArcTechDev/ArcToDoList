//
//  MenuItem.m
//  ArcToDoList
//
//  Created by User on 6/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem{
    
}

@synthesize title = _title;
@synthesize target = _target;
@synthesize selector = _selector;

+ (id)createMenuItemWithTitle:(NSString *)title withTarget:(id)target withSelector:(SEL)selector{
    
    MenuItem *item = [[MenuItem alloc] init];
    
    item.title = title;
    item.target = target;
    item.selector = selector;
    
    return item;
}

- (void)performAction{
    
    if(_target != nil && _selector != nil){
        
        [_target performSelector:_selector withObject:nil];
    }
}

@end
