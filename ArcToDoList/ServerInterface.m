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

- (void)loadCategoryItemOnComplete:(void(^)(NSDictionary *values))complete fail:(void(^)(NSError *error))fail{
    
    FIRDatabaseReference *catItemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid]];
    
    FIRDatabaseQuery *query = [catItemRef queryOrderedByKey];
    
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
    
    [catItemRef updateChildValues:@{catItemId:@{FPCatItemName:text, FPCatItemTaskCount:[NSNumber numberWithInteger:0]}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self updateCategoryItemCount:^{
            
            complete(catItemId, text);
            
        } fail:^(NSError *error) {
            
            fail(error);
            
        }];
    }];
}

- (void)deleteCategoryItemWithItemId:(NSString *)itemId onComplete:(void(^)(NSString *itemId))complete fail:(void(^)(NSError *error))fail{
    
    
    FIRDatabaseReference *itemRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/%@/%@",FCategoryItems, [FIRAuth auth].currentUser.uid, itemId]];
    [itemRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
       
        if(error != nil){
            
            fail(error);
            
            return;
        }
        
        [self updateCategoryItemCount:^{
            
            complete(itemId);
            
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
        
        complete();
    }];

}

@end
