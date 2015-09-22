//
//  AccountManager.m
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "AccountManager.h"



@implementation AccountManager{
    
    UserAccount *currentUserAccount;
    
    googlePlusLoginSuccessful googlePlusSigninSuccessful;
    googlePlusLoginFail googlePlusSigninFail;
    facebookLoginSuccessful facebookSigninSuccessful;
    facebookLoginFail facebookSigninFail;
}

@synthesize userAccount = _userAccount;

static AccountManager *instance;

+ (AccountManager *)sharedManager{
    
    if(instance == nil){
        
        instance = [[AccountManager alloc]  init];
    }
    
    return instance;
}

#pragma mark - Getter
- (UserAccount *)getCurrentUserAccount{
    
    return currentUserAccount;
}

#pragma mark - public interface
- (void)googlePlusLoginSetupWithLoginSuccessful:(googlePlusLoginSuccessful)successful WithLoginFail:(googlePlusLoginFail)fail{
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    signIn.clientID = kClientId;
    
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, nil];
    
    signIn.delegate = self;
    
    googlePlusSigninSuccessful = successful;
    googlePlusSigninFail = fail;
    
    //uncomment to make auto sign in
    [signIn trySilentAuthentication];
}

- (void)facebookLoginSetupWithButton:(FBSDKLoginButton *)fbButton WithLoginSuccessful:(facebookLoginSuccessful)successful WithLoginFail:(facebookLoginFail)fail{
    
    fbButton.delegate = self;
    fbButton.readPermissions =  @[@"email"];
    
    facebookSigninSuccessful = successful;
    facebookSigninFail = fail;
    
    //auto sign in
    if([FBSDKAccessToken currentAccessToken]){
        
        FacebookAccount *fAccount = [[FacebookAccount alloc] init];
        
        currentUserAccount = fAccount;
        
        if(facebookSigninSuccessful != nil)
            facebookSigninSuccessful(nil, fAccount);
    }
    
}

#pragma mark - Google+ login callback
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error{
    
    NSLog(@"Google login Received error %@ and auth object %@",error, auth);
    
    if(error != nil){
        
        if(googlePlusSigninFail != nil)
            googlePlusSigninFail(error);
    }
    else{
        
        GooglePlusAccount *gAccount = [[GooglePlusAccount alloc] init];
        
        currentUserAccount = gAccount;
        
        if(googlePlusSigninSuccessful != nil)
            googlePlusSigninSuccessful(auth, gAccount);
    }
}

#pragma mark - Facebook login/logout callback
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"Facebook login Received error %@ and result %@", error, result);
    
    if(error != nil){
        
        if(facebookSigninFail != nil)
            facebookSigninFail(error);
    }
    else{
        
        FacebookAccount *fAccount = [[FacebookAccount alloc] init];
        
        currentUserAccount = fAccount;
        
        if(facebookSigninSuccessful != nil)
            facebookSigninSuccessful(result, fAccount);
    }
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

@end
