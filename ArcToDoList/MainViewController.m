//
//  MainViewController.m
//  ArcToDoList
//
//  Created by User on 23/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "MainViewController.h"
#import "AccountManager.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAccountLogout:) name:kAccountLogoutNotify object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[AccountManager sharedManager] tryGoogleAutoLoginWithSuccessful:^(GTMOAuth2Authentication *auth, UserAccount *account){
    
        [self performSegueWithIdentifier:@"UserInfoFromMain" sender:nil];
        
        
    } WithLoginFail:^(NSError *error){
        
        [[AccountManager sharedManager] tryFacebookAutoLoginWithSuccessful:^(FBSDKLoginManagerLoginResult *result, UserAccount *account){
        
            [self performSegueWithIdentifier:@"UserInfoFromMain" sender:nil];
            
        } WithLoginFail:^(NSError *error){
        
            [self performSegueWithIdentifier:@"Signin" sender:nil];
        }];
    
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onAccountLogout:(NSNotification *)notification{
    
    [self dismissViewControllerAnimated:YES completion:^{
    
        [self performSegueWithIdentifier:@"Signin" sender:nil];
    }];
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
