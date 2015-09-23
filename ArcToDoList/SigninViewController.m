//
//  SigninViewController.m
//  ToDoList
//
//  Created by User on 21/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "SigninViewController.h"
#import "AccountManager.h"


@interface SigninViewController ()

@end

@implementation SigninViewController

@synthesize googleLogInButton = _googleLogInButton;
@synthesize fbLogInButton = _fbLogInButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[AccountManager sharedManager] googlePlusLoginSetupWithLoginSuccessful:^(GTMOAuth2Authentication *auth, UserAccount *account){
        
        [self performSegueWithIdentifier:@"UserInfoFromSignin" sender:nil];
        
    }WithLoginFail:^(NSError *error){
        
        NSLog(@"log in google account fail %@", error);
    }];
    
    [[AccountManager sharedManager] facebookLoginSetupWithButton:_fbLogInButton WithLoginSuccessful:^(FBSDKLoginManagerLoginResult *result, UserAccount *account){
        
        [self performSegueWithIdentifier:@"UserInfoFromSignin" sender:nil];
        
    }WithLoginFail:^(NSError *error){
        
        NSLog(@"log in facebook account fail %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
