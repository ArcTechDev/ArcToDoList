//
//  FacebookAccount.m
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "FacebookAccount.h"

@implementation FacebookAccount


- (id)init{
    
    if(self = [super init]){
        
        theAccountType = FacebookAccountType;
    }
    
    return self;
}

#pragma mark - override
- (void)queryProfileImageURLComplete:(void(^)(NSString *imageURL))complete Fail:(void(^)(NSError *error))fail{
    
 
        if([FBSDKAccessToken currentAccessToken]){
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                if (!error) {
                    
                    NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                    
                    complete(imageStringOfLoginUser);
                }
                else{
                    
                    fail(error);
                }
            }];
        }
        else{
            
            NSError *error = [NSError errorWithDomain:@"AccessToken not vaild" code:-1 userInfo:nil];
            
            fail(error);
        }
}


- (void)queryProfileNameComplete:(void(^)(NSString *name))complete Fail:(void(^)(NSError *error))fail{
    

    if([FBSDKAccessToken currentAccessToken]){
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"name"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                
                NSString *name = [result valueForKey:@"name"];
                
                complete(name);
            }
            else{
                
                fail(error);
            }
        }];
    }
    else{
        
        NSError *error = [NSError errorWithDomain:@"AccessToken not vaild" code:-1 userInfo:nil];
        
        fail(error);
    }
}


- (void)queryProfileEmailComplete:(void(^)(NSString *email))complete Fail:(void(^)(NSError *error))fail{
    
    if([FBSDKAccessToken currentAccessToken]){
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"email"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                
                NSString *email = [result valueForKey:@"email"];
                
                complete(email);
            }
            else{
                
                fail(error);
            }
        }];
    }
    else{
        
        NSError *error = [NSError errorWithDomain:@"AccessToken not vaild" code:-1 userInfo:nil];
        
        fail(error);
    }
}

- (void)logout{
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [[[FBSDKLoginManager alloc] init] logOut];
}

@end
