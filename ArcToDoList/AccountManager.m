//
//  AccountManager.m
//  ArcToDoList
//
//  Created by User on 13/6/16.
//  Copyright © 2016 ArcTech. All rights reserved.
//

#import "AccountManager.h"

@implementation AccountManager

static AccountManager *_instance;

+ (instancetype)sharedInstance{
    
    if(_instance == nil){
        
        _instance = [[AccountManager alloc] init];
    }
    
    return _instance;
}

- (BOOL)shouldLogin{
    
    if([FIRAuth auth].currentUser != nil)
        return NO;
    else
        return YES;
}

- (void)facebookLoginSuccess:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail{
    
    if([FIRAuth auth].currentUser != nil){
        
        //if user already login, logout first
        [self logoutSuccess:^{
            
            [self doFacebookLoginSuccess:success fail:fail];
            
        } fail:^(NSError *error) {
            
            fail(error);
        }];
    }
    else{
        
        [self doFacebookLoginSuccess:success fail:fail];
    }
}

- (void)googleLoginWithUser:(GIDGoogleUser *)user success:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail{
    
    if([FIRAuth auth].currentUser != nil){
        
        //if user already login, logout first
        [self logoutSuccess:^{
            
            [self doGoogleLoginWithUser:user success:success fail:fail];
            
        } fail:^(NSError *error) {
            
            fail(error);
        }];
    }
    else{
        
        [self doGoogleLoginWithUser:user success:success fail:fail];
    }

}

- (void)logoutSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail{
    
    NSError *error;
    
    [[[FBSDKLoginManager alloc] init] logOut];
    [[GIDSignIn sharedInstance] signOut];
    
    if([[FIRAuth auth] signOut:&error])
        success();
    else
        fail(error);
    
    
}

- (void)doFacebookLoginSuccess:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail{
    
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                     .tokenString];
    
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                  
                                  if(error == nil){
                                      
                                      NSLog(@"Facebook login with user id:%@", user.uid);
                                      
                                      success(user);
                                  }else{
                                      
                                      fail(error);
                                      
                                      NSLog(error.description);
                                  }
                                  
                              }];

}

- (void)doGoogleLoginWithUser:(GIDGoogleUser *)user success:(void(^)(FIRUser *user))success fail:(void(^)(NSError *error))fail{
    
    GIDAuthentication *authentication = user.authentication;
    FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken accessToken:authentication.accessToken];
    
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        
        if(error == nil){
            
            NSLog(@"Google login with user id:%@", user.uid);
            
            success(user);
            
        }else{
            
            fail(error);
            
            NSLog(error.description);
            
        }
    }];
}

@end
