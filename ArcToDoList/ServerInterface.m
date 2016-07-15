//
//  ServerInterface.m
//  ArcToDoList
//
//  Created by User on 21/6/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import "ServerInterface.h"



@implementation ServerInterface{
    
    FIRDatabaseReference *_ref;
}

static ServerInterface *_instance;

+ (instancetype)sharedInstance{
    
    if(_instance == nil){
        
        _instance = [[ServerInterface alloc] init];
    }
    
    return _instance;
}

- (id)init{
    
    if(self = [super init]){
        
        _ref = [[FIRDatabase database] reference];
    }
    
    return self;
}

- (FIRDatabaseReference *)refCategoryItems{
    
    return [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
}

- (FIRDatabaseReference *)refTaskItemsUnderCategoryItem:(NSString *)catId{
    
    return [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId]];
}

- (FIRDatabaseReference *)refCategoryItemUnderTasks{
    
    return [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid]];
}

- (void)loadCategoryItemOnComplete:(void(^)(NSDictionary *values))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    
    FIRDatabaseQuery *query = [catItemRef queryOrderedByChild:FCategoryItemPriority];
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            complete(snapshot.value);
        }
        else{
            
            complete(@{});
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        fail(error);
    }];
}

- (void)addCategoryItemWithText:(NSString *)text onComplete:(void(^)(NSString *itemId, NSString *text))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    
    NSString *catItemId = [catItemRef childByAutoId].key;
    
    [catItemRef updateChildValues:@{catItemId:@{FPCatItemName:text, FPCatItemTaskCount:[NSNumber numberWithInteger:0], FCategoryItemPriority:[NSNumber numberWithInteger:0]}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self updateCategoryItemCount:^{
            
            //complete(catItemId, text);
            
            [self sortCategoryItemWithStartPriority:0 ignoreItemId:catItemId incrementPriority:1 complete:^{
                
                complete(catItemId, text);
                
            } fail:^(NSError *error) {
                
                fail(error);
            }];
            
        } fail:^(NSError *error) {
            
            fail(error);
            
        }];
    }];
}

- (void)deleteCategoryItemWithItemId:(NSString *)itemId withItemPriority:(NSInteger)priority onComplete:(void(^)(NSString *itemId))complete fail:(void(^)(NSError *error))fail{
    
    
    FIRDatabaseReference *itemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid, itemId]];
    [itemRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
       
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self deleteAllTaskUnderCategoryItemId:itemId onComplete:^{
            
            [self updateCategoryItemCount:^{
                
                complete(itemId);
                
                [self sortCategoryItemWithStartPriority:priority ignoreItemId:itemId incrementPriority:-1 complete:^{
                    
                    complete(itemId);
                    
                } fail:^(NSError *error) {
                    
                    fail(error);
                }];
                
            } fail:^(NSError *error) {
                
                fail(error);
            }];
            
            
        } fail:^(NSError *error) {
            
            fail(error);
            
        }];
        
    }];
    
}

- (void)modifyCategoryItemWithItemId:(NSString *)itemId text:(NSString *)text onComplete:(void(^)(NSString *itemId, NSString *text))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid, itemId]];
    
    [catItemRef updateChildValues:@{FPCatItemName:text} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
       
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        complete(itemId, text);
    }];
}

- (void)modifyCategoryItemWithItemId:(NSString *)itemId withNewPriority:(NSInteger)priority onComplete:(void(^)(NSString *itemId, NSInteger newPriority))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid, itemId]];
    
    [catItemRef updateChildValues:@{FCategoryItemPriority:[NSNumber numberWithInteger:priority]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        complete(itemId, priority);
    }];

}

- (void)updateCategoryItemPriority:(NSDictionary *)data complete:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    /*
    FIRDatabaseReference *itemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    
    [itemRef runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        
        if([currentData.value isEqual:[NSNull null]]){
            
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        NSDictionary *dicData = currentData.value;
        
        for(NSString *key in data.allKeys){
            
            NSNumber *value  = dicData[key][FCategoryItemPriority];
            
            if(value != nil){
                
                [dicData[key] setValue:data[key] forKey:FCategoryItemPriority];
            }
        }
        
        [currentData setValue:dicData];
        
        complete();
        
        return [FIRTransactionResult successWithValue:currentData];
        
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        
        if(error != nil || !committed)
            fail(error);
    }];
     */
    
    for(NSString *key in data.allKeys){
        
        [self modifyCategoryItemWithItemId:key withNewPriority:[data[key] integerValue] onComplete:^(NSString *itemId, NSInteger newPriority) {
            
        } fail:^(NSError *error) {
            
        }];
    }
}

- (void)loadTaskItemUnderCategoryItem:(NSString *)catId withDate:(NSString *)date complete:(void(^)(NSDictionary *values, NSString *queryDate))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *taskItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId]];
    
    FIRDatabaseQuery *query = [[taskItemRef queryOrderedByChild:FPTaskItemDate] queryEqualToValue:date];
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            complete(snapshot.value, date);
        }
        else{
            
            complete(@{}, date);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        fail(error);
    }];

}

- (void)addTaskItemUnderCategoryItemId:(NSString *)catId withText:(NSString *)text withDate:(NSString *)date onComplete:(void(^)(NSString *taskId, NSString *text, NSString *date))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *taskItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId]];
    
    NSString *taskItemId = [taskItemRef childByAutoId].key;
    
    [taskItemRef updateChildValues:@{taskItemId:@{FPTaskItemName:text, FPTaskItemComplete:[NSNumber numberWithBool:NO], FPTaskItemDate:date}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self updateCategoryItemTaskCountWithItemId:catId WithOffset:1 onComplete:^{
            
            complete(taskItemId, text, date);
            
        } fail:^(NSError *error) {
            
            fail(error);
        }];
    }];
}

- (void)deleteTaskItemUnderCategoryItemId:(NSString *)catId withTaskId:(NSString *)taskId withDate:(NSString *)date onComplete:(void(^)(NSString *taskId, NSString *date))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *taskItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId, taskId]];
    
    [taskItemRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref){
    
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self updateCategoryItemTaskCountWithItemId:catId WithOffset:-1 onComplete:^{
            
            complete(taskId, date);
            
        } fail:^(NSError *error) {
            
            fail(error);
        }];
    }];
}

- (void)modifyTaskItemUnderCatergoryItemId:(NSString *)catId withTaskId:(NSString *)taskId withText:(NSString *)text withDate:(NSString *)date onComplete:(void(^)(NSString *taskId, NSString *date, NSString *text))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *taskItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId, taskId]];
    
    [taskItemRef updateChildValues:@{FPTaskItemName:text} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        complete(taskId, date, text);
    }];

}

#pragma mark - Internal
- (void)updateCategoryItemCount:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *itemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    FIRDatabaseReference *itemCountRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItemCount, [FIRAuth auth].currentUser.uid]];
    
    //get total item coun in category
    [itemRef runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        
        if([currentData.value isEqual:[NSNull null]])
            return [FIRTransactionResult successWithValue:currentData];
        
        NSUInteger itemCount = ((NSMutableDictionary *)currentData.value).count;
        
        
        //update total category item count
        [itemCountRef runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
            
            NSMutableDictionary *itemCountData;
            
            if([currentData.value isEqual:[NSNull null]]){
                
                itemCountData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:1], FCategoryTotalItems, nil];
                
                [currentData setValue:itemCountData];
                
                return [FIRTransactionResult successWithValue:currentData];
            }
            else{
                
                itemCountData = currentData.value;
            }
            
            [itemCountData setValue:[NSNumber numberWithUnsignedInteger:itemCount] forKey:FCategoryTotalItems];
            
            [currentData setValue:itemCountData];
            
            return [FIRTransactionResult successWithValue:currentData];
            
        } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
            
            if(error != nil || !committed){
                
                fail(error);
                
                return;
            }
            
            complete();
        }];
        
        return [FIRTransactionResult successWithValue:currentData];
        
        
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        
        if(error != nil || !committed){
            
            fail(error);
            
            return;
        }
        
        //complete();
    }];

}

- (void)sortCategoryItemWithStartPriority:(NSInteger)sPriority ignoreItemId:(NSString *)itemId incrementPriority:(NSInteger)pIncrement complete:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *itemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    FIRDatabaseQuery *query = [[itemRef queryOrderedByChild:FCategoryItemPriority] queryStartingAtValue:[NSNumber numberWithInteger:sPriority]];
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            /*
            NSDictionary *dic = snapshot.value;
            
            for(NSString *key in dic.allKeys){
                
                if(![key isEqualToString:itemId]){
                    
                    NSDictionary *data = dic[key];
                    NSInteger p = [data[FCategoryItemPriority] integerValue];
                    
                    [[itemRef child:key] updateChildValues:@{FCategoryItemPriority:[NSNumber numberWithInteger:p+pIncrement]}];
                }
            }
             */
            
            [itemRef runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                
                if([currentData.value isEqual:[NSNull null]]){
                    
                    return [FIRTransactionResult successWithValue:currentData];
                }
                
                NSDictionary *dicData = currentData.value;
                
                for(NSString *key in dicData.allKeys){
                    
                    NSInteger priority = [dicData[key][FCategoryItemPriority] integerValue];
                    
                    if(![key isEqualToString:itemId]){
                        
                        if(priority >= sPriority)
                            [dicData[key] setValue:[NSNumber numberWithInteger:priority+pIncrement] forKey:FCategoryItemPriority];
                    }
                }
                
                [currentData setValue:dicData];
                
                complete();
                
                return [FIRTransactionResult successWithValue:currentData];
                
            } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                
                if(error != nil || !committed)
                    fail(error);
            }];
            
            //complete();
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"sort error:%@", error);
        
        fail(error);
    }];
}

- (void)updateCategoryItemTaskCountWithItemId:(NSString *)catId WithOffset:(NSInteger)offset onComplete:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid, catId]];
    
    [catItemRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(![snapshot.value isEqual:[NSNull null]]){
            
            
            NSDictionary *dic = snapshot.value;
            
            NSInteger  taskCount = [dic[FPCatItemTaskCount] integerValue];
            
            taskCount = MAX(0, taskCount + offset);
            
            
            [catItemRef updateChildValues:@{FPCatItemTaskCount:[NSNumber numberWithInteger:taskCount]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                
                if(error != nil){
                    
                    fail(error);
                    
                    return;
                }
                
                complete();
            }];

            
        }
        else{
            
            NSError *errorNotExist = [NSError errorWithDomain:@"Data not exist" code:-2 userInfo:nil];
            
            fail(errorNotExist);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
       
        NSLog(@"sort error:%@", error);
        
        fail(error);
    }];
    
    
}

- (void)deleteAllTaskUnderCategoryItemId:(NSString *)catId onComplete:(void(^)(void))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FTaskItems, [FIRAuth auth].currentUser.uid, catId]];
    
    [catItemRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
       
        complete();
    }];
}



@end
