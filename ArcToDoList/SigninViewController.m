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
    
    _fbLogInButton.delegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    /*
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
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBSDKLogin button delegate
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    if (error == nil && !result.isCancelled && !(result.token == nil)) {
        
        [[AccountManager sharedInstance] facebookLoginSuccess:^(FIRUser *user) {
            
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
            
            return;
            
        } fail:^(NSError *error) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login error" message:@"There is an error while login with Facebook account!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            NSLog(error.description);
            
            return;
        }];
        
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login fail" message:@"Unable to login with Facebook account!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

    if(error != nil)
        NSLog(error.description);
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
    [[AccountManager sharedInstance] logoutSuccess:^{
        
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark - Google login/out
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error == nil) {
        
        [[AccountManager sharedInstance] googleLoginWithUser:user success:^(FIRUser *user) {
            
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
            
            return;
            
        } fail:^(NSError *error) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login error" message:@"There is an error while login with Google account!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            NSLog(error.localizedDescription);
            
            return;
        }];

        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login fail" message:@"Unable to login with Google account!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    NSLog(@"%@", error.description);
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    [[AccountManager sharedInstance] logoutSuccess:^{
        
    } fail:^(NSError *error) {
        
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
