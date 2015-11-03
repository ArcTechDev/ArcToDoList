//
//  PullDownAddNew.h
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "GestureComponent.h"
#import "PDANCellHolder.h"

@protocol PullDownAddNewDelegate <NSObject>

@optional
- (void)addNewItemWithText:(NSString *)text;

@end

@interface PullDownAddNew : GestureComponent<PDANCellHolderDelegate>

@end
