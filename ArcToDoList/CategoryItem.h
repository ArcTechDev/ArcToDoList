//
//  CategoryItem.h
//  ArcToDoList
//
//  Created by User on 2/11/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryItem : NSObject

@property (copy, nonatomic) NSString *itemName;
@property (assign, nonatomic) BOOL isComplete;

+ (id)createCategoryItemWithName:(NSString *)name;

@end
