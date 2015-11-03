//
//  AccountManager.h
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccount.h"
#import "GooglePlusAccount.h"
#import "FacebookAccount.h"

typedef void(^googlePlusLoginSuccessful)(GTMOAuth2Authentication *auth, UserAccount *account);
typedef void(^googlePlusLoginFail)(NSError *error);
typedef void(^facebookLoginSuccessful)(FBSDKLoginManagerLoginResult *result, UserAccount *account);
typedef void(^facebookLoginFail)(NSError *error);

@interface AccountManager : NSObject<GPPSignInDelegate, FBSDKLoginButtonDelegate>

@property (getter=getCurrentUserAccount, nonatomic) UserAccount *userAccount;

+ (AccountManager *)sharedManager;

- (void)tryGoogleAutoLoginWithSuccessful:(googlePlusLoginSuccessful)successful WithLoginFail:(googlePlusLoginFail)fail;
- (void)tryFacebookAutoLoginWithSuccessful:(facebookLoginSuccessful)successful WithLoginFail:(facebookLoginFail)fail;

/**
 * setup google + login
 */
- (void)googlePlusLoginSetupWithLoginSuccessful:(googlePlusLoginSuccessful)successful WithLoginFail:(googlePlusLoginFail)fail;

/**
 * setup facebook login
 */
- (void)facebookLoginSetupWithButton:(FBSDKLoginButton *)fbButton WithLoginSuccessful:(facebookLoginSuccessful)successful WithLoginFail:(facebookLoginFail)fail;

@end
