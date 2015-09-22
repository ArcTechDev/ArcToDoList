//
//  SigninViewController.m
//  ToDoList
//
//  Created by User on 21/9/15.
//  Copyright (c) 2015 ArcTech. All rights reserved.
//

#import "SigninViewController.h"


@interface SigninViewController ()

@end

@implementation SigninViewController

@synthesize googleLogInButton = _googleLogInButton;
@synthesize fbLogInButton = _fbLogInButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self googelPlusLoginSetup];
    [self fbLoginSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Google plus login setup
- (void)googelPlusLoginSetup{
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    signIn.clientID = kClientId;
    
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, nil];
    
    signIn.delegate = self;
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error{
    
    NSLog(@"Google login Received error %@ and auth object %@",error, auth);
}

#pragma mark - Facebook login setup
- (void)fbLoginSetup{
    
    _fbLogInButton.delegate = self;
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"Facebook login Received error %@ and result %@", error, result);
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
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
