//
//  UserAccount.h
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>


enum AccountType{
    
    UnknowAccountType,
    GooglePlusAccountType,
    FacebookAccountType
};


@interface UserAccount : NSObject{
    
@protected
    enum AccountType theAccountType;
}

@property (getter=getAccountType, nonatomic) enum AccountType accountType;

/**
 * Subclass have to override this method
 */
- (void)queryProfileImageURLComplete:(void(^)(NSString *imageURL))complete Fail:(void(^)(NSError *error))fail;

/**
 * Subclass have to override this method
 */
- (void)queryProfileNameComplete:(void(^)(NSString *name))complete Fail:(void(^)(NSError *error))fail;

/**
 * Subclass have to override this method
 */
- (void)queryProfileEmailComplete:(void(^)(NSString *email))complete Fail:(void(^)(NSError *error))fail;

/**
 * Subclass have to override this method
 */
- (void)logout;

@end
