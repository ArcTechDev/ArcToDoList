//
//  ServerInterface.h
//  ArcToDoList
//
//  Created by User on 21/6/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FCategoryItems @"CatItems"
#define FCategoryItemPriority @"CatItemPriority"
#define FCategoryItemCount @"CatItemCount"
#define FCategoryTotalItems @"CatTotalItems"
#define FPCatItemName @"ItemName"
#define FPCatItemTaskCount @"TaskCount"

#define FTaskItems @"TaskItems"
#define FPTaskItemName @"TaskItemName"
#define FPTaskItemComplete @"TaskItemComplete"
#define FPTaskItemDate @"TaskItemDate"

@interface ServerInterface : NSObject

/**
 * Return reference of current user's category items
 */
@property (nonatomic, readonly) FIRDatabaseReference *refCategoryItems;

+ (instancetype)sharedInstance;

- (FIRDatabaseReference *)refTaskItemsUnderCategoryItem:(NSString *)catId;

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
- (void)deleteCategoryItemWithItemId:(NSString *)itemId withItemPriority:(NSInteger)priority onComplete:(void(^)(NSString *itemId))complete fail:(void(^)(NSError *error))fail;

/**
 * Modify item text in category
 */
- (void)modifyCategoryItemWithItemId:(NSString *)itemId text:(NSString *)text onComplete:(void(^)(NSString *itemId, NSString *text))complete fail:(void(^)(NSError *error))fail;

/**
 * Modify item priority in category
 */
- (void)modifyCategoryItemWithItemId:(NSString *)itemId withNewPriority:(NSInteger)priority onComplete:(void(^)(NSString *itemId, NSInteger newPriority))complete fail:(void(^)(NSError *error))fail;

/**
 * update item priority in a range in category
 * supply dictionary with itemId as key, priority(NSNumber) as value
 */
- (void)updateCategoryItemPriority:(NSDictionary *)data complete:(void(^)(void))complete fail:(void(^)(NSError *error))fail;

/**
 * Load all task item under certain category item
 */
- (void)loadTaskItemUnderCategoryItem:(NSString *)catId withDate:(NSString *)date complete:(void(^)(NSDictionary *values, NSString *queryDate))complete fail:(void(^)(NSError *error))fail;

/**
 * Add task item under certain category item
 */
- (void)addTaskItemUnderCategoryItemId:(NSString *)catId withText:(NSString *)text withDate:(NSString *)date onComplete:(void(^)(NSString *taskId, NSString *text, NSString *date))complete fail:(void(^)(NSError *error))fail;

/**
 * Delete task item under certain category item
 */
- (void)deleteTaskItemUnderCategoryItemId:(NSString *)catId withTaskId:(NSString *)taskId withDate:(NSString *)date onComplete:(void(^)(NSString *taskId, NSString *date))complete fail:(void(^)(NSError *error))fail;

@end
