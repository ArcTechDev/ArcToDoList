//
//  ServerInterface.h
//  ArcToDoList
//
//  Created by User on 21/6/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FCategoryItems @"CatItems"
#define FCategoryItemCount @"CatItemCount"
#define FCategoryTotalItems @"CatTotalItems"
#define FPCatItemName @"ItemName"
#define FPCatItemTaskCount @"TaskCount"

@interface ServerInterface : NSObject

/**
 * Return reference of current user's category items
 */
@property (nonatomic, readonly) FIRDatabaseReference *refCategoryItems;

+ (instancetype)sharedInstance;

/**
 * Load all items from category
 */
- (void)loadCategoryItemOnComplete:(void(^)(NSDictionary *values))complete fail:(void(^)(NSError *error))fail;

/**
 * Add new item to category
 */
- (void)addCategoryItemWithText:(NSString *)text onComplete:(void(^)(NSString *itemId, NSString *text))complete fail:(void(^)(NSError *error))fail;

/**
 * Delete item in category
 */
- (void)deleteCategoryItemWithItemId:(NSString *)itemId onComplete:(void(^)(NSString *itemId))complete fail:(void(^)(NSError *error))fail;

/**
 * Modify item in category
 */
- (void)modifyCategoryItemWithItemId:(NSString *)itemId text:(NSString *)text onComplete:(void(^)(NSString *itemId, NSString *text))complete fail:(void(^)(NSError *error))fail;

@end
