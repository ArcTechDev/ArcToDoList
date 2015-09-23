//
//  GooglePlusAccount.m
//  ArcToDoList
//
//  Created by User on 22/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "GooglePlusAccount.h"

@implementation GooglePlusAccount

- (id)init{
    
    if(self = [super init]){
        
        theAccountType = GooglePlusAccountType;
    }
    
    return self;
}

#pragma mark - override
- (void)queryProfileImageURLComplete:(void(^)(NSString *imageURL))complete Fail:(void(^)(NSError *error))fail{
    
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *person, NSError *error) {
        
                if (error) {
                    //GTMLoggerError(@"Error: %@", error);
                    NSLog(@"Error: %@", error);
                    
                    fail(error);
                }
                else {
                    // Retrieve the display name and "about me" text
                   
                    GTLPlusPersonImage *personImage = person.image;
                    
                    complete(personImage.url);
                }
            }];
}


- (void)queryProfileNameComplete:(void(^)(NSString *name))complete Fail:(void(^)(NSError *error))fail{
    
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *person, NSError *error) {
        
        if (error) {
            //GTMLoggerError(@"Error: %@", error);
            NSLog(@"Error: %@", error);
            
            fail(error);
        }
        else {
            // Retrieve the display name and "about me" text
            
            complete([NSString stringWithFormat:@"%@ %@", person.name.familyName, person.name.givenName]);
        }
    }];
}


- (void)queryProfileEmailComplete:(void(^)(NSString *email))complete Fail:(void(^)(NSError *error))fail{
    
     GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    complete(signIn.authentication.userEmail);
}

- (void)logout{
    
     GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    [signIn signOut];
    
    [super logout];
}

@end
