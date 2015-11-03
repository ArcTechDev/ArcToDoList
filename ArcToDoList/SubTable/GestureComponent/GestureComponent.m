//
//  GestureComponent.m
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"

@implementation GestureComponent{
    
    NSInteger _priority;
}

@synthesize priority = _priority;
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize delegate = _delegate;

#pragma mark - init
- (id)initWithTableView:(ParentTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super init]){
        
        _tableView = tableView;
        _priority = priority;
        
        [tableView addListenerForScrollViewDelegate:self];
    }
    
    return self;
}

#pragma mark - getter
- (NSInteger)getPriority{
    
    return  _priority;
}

- (UIGestureRecognizer *)getGestureRecognizer{
    
    return _gestureRecognizer;
}

#pragma mark - public interface
- (void)deviceOrientationDidChange{
    
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer WithDelegate:(id<UIGestureRecognizerDelegate>)delegate{
    
    if(gestureRecognizer != nil){
        
        gestureRecognizer.delegate = delegate;
        
        _gestureRecognizer = gestureRecognizer;
        
        [_tableView addGestureRecognizer:gestureRecognizer];
    }
}

- (void)requireGestureComponentToFail:(GestureComponent *)component{
    
    [_gestureRecognizer requireGestureRecognizerToFail:component.gestureRecognizer];
}

#pragma mark - override
- (void)dealloc{
    
    if(_gestureRecognizer != nil){
        
        if(_tableView != nil){
            
            [_tableView removeGestureComponent:self];
        }
    }
}

@end
