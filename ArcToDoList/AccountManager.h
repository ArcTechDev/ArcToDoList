//
//  AccountManager.h
//  ArcToDoList
//
//  Created by User on 13/6/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)shouldLogin;
- (void)facebookLoginSuccess:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail;
- (void)googleLoginWithUser:(GIDGoogleUser *)user success:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail;
- (void)logoutSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

@end
