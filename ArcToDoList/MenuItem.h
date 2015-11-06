//
//  MenuItem.h
//  ArcToDoList
//
//  Created by User on 6/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL selector;

+ (id)createMenuItemWithTitle:(NSString *)title withTarget:(id)target withSelector:(SEL)selector;

- (void)performAction;

@end
