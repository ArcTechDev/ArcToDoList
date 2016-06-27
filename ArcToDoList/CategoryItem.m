//
//  CategoryItem.m
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "CategoryItem.h"

@implementation CategoryItem

@synthesize itemId = _itemId;
@synthesize itemName = _itemName;
@synthesize isComplete = _isComplete;

+ (id)createCategoryItemWithName:(NSString *)name{
    
    CategoryItem *item = [[CategoryItem alloc] init];
    
    item.itemName = name;
    
    return item;
}

@end
