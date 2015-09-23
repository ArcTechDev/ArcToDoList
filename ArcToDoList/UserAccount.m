//
//  UserAccount.m
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "UserAccount.h"

@implementation UserAccount{
    
    
}

@synthesize accountType = _accountType;

- (enum AccountType) getAccountType{
    
    return theAccountType;
}

/**
 * Subclass have to override this method
 */
- (void)queryProfileImageURLComplete:(void(^)(NSString *imageURL))complete Fail:(void(^)(NSError *error))fail{
    
}

/**
 * Subclass have to override this method
 */
- (void)queryProfileNameComplete:(void(^)(NSString *name))complete Fail:(void(^)(NSError *error))fail{
    
}

/**
 * Subclass have to override this method
 */
- (void)queryProfileEmailComplete:(void(^)(NSString *email))complete Fail:(void(^)(NSError *error))fail{
    
}

/**
 * Subclass have to override this method
 */
- (void)logout{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountLogoutNotify object:nil];
    
}

@end
